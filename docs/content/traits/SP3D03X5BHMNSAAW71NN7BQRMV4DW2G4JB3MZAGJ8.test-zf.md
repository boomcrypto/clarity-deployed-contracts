---
title: "Trait test-zf"
draft: true
---
```
;; BNS Zonefile Management Contract

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NO-ZONEFILE-FOUND (err u101))
(define-constant ERR-NO-NAME (err u102))
(define-constant ERR-NO-NAMESPACE (err u103))
(define-constant ERR-NAME-REVOKED (err u104))
(define-constant ERR-MIGRATION-IN-PROGRESS (err u105))
(define-constant ERR-INVALID-PERIOD (err u106))

;; Data Maps

;; zonefile map: Stores zonefile information for each name in a namespace
;; Key: {name: (buff 48), namespace: (buff 20)}
;; Value: {owner: principal, zonefile: (optional (buff 8192)), revoked: bool}
(define-map zonefile {name: (buff 48), namespace: (buff 20)} 
    {
        owner: principal,
        zonefile: (optional (buff 8192)),
        revoked: bool
    }
)

;; Read-only Functions

;; Resolve a name to its zonefile
;; This function checks ownership and validity before returning the zonefile
(define-read-only (resolve-name (name (buff 48)) (namespace (buff 20))) 
    (let 
        (
            (name-resolve (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 can-resolve-name namespace name) ERR-NO-NAME))
            (current-zonefile (unwrap! (map-get? zonefile {name: name, namespace: namespace}) ERR-NO-ZONEFILE-FOUND))
        ) 
        ;; Check if the name is in a valid grace period
        (asserts! 
            (if (is-eq u0 (get renewal name-resolve))
                ;; If true it means that the name is in a managed namespace or the namespace does not require renewals
                true
                ;; If false then calculate valid period
                (<= burn-block-height (get renewal name-resolve))
            )
            ERR-INVALID-PERIOD
        )
        ;; Check that the name is not revoked
        (asserts! (not (get revoked current-zonefile)) ERR-NAME-REVOKED)
        (ok 
            (if (is-eq (get owner name-resolve) (get owner current-zonefile)) 
                ;; If the name owner matches the zonefile owner, return the zonefile
                (get zonefile current-zonefile)
                ;; If owners don't match, return none
                none
            )
        )
    )
)

;; Public Functions

;; Update the zonefile for a name
;; This function allows authorized users to update the zonefile of a name
(define-public (update-zonefile (name (buff 48)) (namespace (buff 20)) (new-zonefile (optional (buff 8192))))
    (let 
        (
            ;; Retrieve namespace and name properties
            (namespace-properties (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-namespace-properties namespace)))
            (namespace-props (get properties namespace-properties))
            ;; Retrieve name properties from BNS-V2 contract
            (name-properties (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace) ERR-NO-NAME))
            (name-owner (get owner name-properties))
            (renewal (get renewal-height name-properties))
            (current-zonefile (map-get? zonefile {name: name, namespace: namespace}))
            (zonefile-owner (get owner current-zonefile))
        ) 
        ;; Check if the name is in a valid grace period
        (asserts! 
            (if (is-eq (get lifetime namespace-props) u0)
                ;; It's always in a valid period 
                true
                ;; Check if it's within the grace period
                (<= burn-block-height (+ renewal u5000))
            )
            ERR-INVALID-PERIOD
        )
        ;; Check if the zonefile exists
        (match current-zonefile 
            c-zonefile 
            ;; If it does check that the name is not revoked
            (asserts! (not (get revoked c-zonefile)) ERR-NAME-REVOKED)
            ;; If it doesn't then continue
            true
        )
        
        ;; Check authorization based on namespace manager
        (match (get namespace-manager namespace-props)
            manager 
            ;; If managed, check if contract-caller is the manager
            (asserts! (is-eq contract-caller manager) ERR-NOT-AUTHORIZED)
            ;; If not managed, check if contract-caller is the owner
            (asserts! (is-eq contract-caller name-owner) ERR-NOT-AUTHORIZED)
        )
        ;; Update the zonefile map
        (map-set zonefile {name: name, namespace: namespace} 
            {
                ;; Update owner to the current owner
                owner: name-owner,
                ;; Set new zonefile or CID
                zonefile: new-zonefile,
                ;; Set revoked to false since it's being updated
                revoked: false
            }
        )
        (print 
            {
                topic: "update-zonefile", 
                name: name,
                namespace: namespace,
                new-zonefile: new-zonefile
            }
        )
        (ok true)
    )
)

;; Revoke a name
;; This function allows authorized users to revoke a name
(define-public (revoke-name (name (buff 48)) (namespace (buff 20)))
    (let
        (
            ;; Retrieve namespace and name properties
            (namespace-properties (try! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-namespace-properties namespace)))
            (namespace-props (get properties namespace-properties))
            (name-properties (unwrap! (contract-call? 'SP2QEZ06AGJ3RKJPBV14SY1V5BBFNAW33D96YPGZF.BNS-V2 get-bns-info name namespace) ERR-NO-NAME))
            (name-owner (get owner name-properties))
        )
        ;; Check authorization based on namespace manager
        (match (get namespace-manager namespace-props)
            manager 
            ;; If managed, check if contract-caller is the manager
            (asserts! (is-eq contract-caller manager) ERR-NOT-AUTHORIZED)
            ;; If not managed, check if contract-caller is the owner or namespace import principal
            (asserts! (or (is-eq contract-caller name-owner) (is-eq contract-caller (get namespace-import namespace-props))) ERR-NOT-AUTHORIZED)
        )
        ;; Update the zonefile information to revoke the name
        (map-set zonefile {name: name, namespace: namespace} 
            {
                ;; Update owner to the current owner
                owner: name-owner,
                ;; Clear the zonefile
                zonefile: none,
                ;; Set revoked to true
                revoked: true
            }
        )
        (print 
            {
                topic: "revoke-name", 
                name: name,
                namespace: namespace,
                zonefile: 0x
            }
        )
        (ok true)
    )
)
```
