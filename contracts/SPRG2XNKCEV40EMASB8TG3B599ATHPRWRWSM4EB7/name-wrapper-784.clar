;; Source code for the name wrapper contract.
;; 
;; This contract is not meant to be deployed as a standalone contract in
;; the BNSx protocol. Instead, it is deployed for each individual name that
;; is upgraded to BNSx.
;; 
;; The purpose of this contract is to own a BNS legacy name, and only allow
;; owners of the equivalent name on BNSx to control the legacy name.
;; 
;; For example, if a wrapper contract owns `name.btc`, and Alice owns `name.btc`
;; on BNSx, then only Alice can interact with this contract.

(define-constant ERR_NO_NAME (err u10000))
(define-constant ERR_NAME_TRANSFER (err u10001))
(define-constant ERR_UNAUTHORIZED (err u10002))
(define-constant ERR_NOT_WRAPPED (err u10003))

(define-data-var wrapper-id-var (optional uint) none)

;; Unwrap the legacy BNS name from this contract.
;; 
;; When unwrapping, the BNSx name is burned. This ensures that there is a 1-to-1
;; mapping between BNSx and BNS legacy names.
;; 
;; @throws if called by anyone other than the BNSx name owner
;; 
;; @param recipient; the name owner can optionally transfer the BNS legacy name to
;; a different account. If `none`, recipient defauls to `tx-sender`.
(define-public (unwrap (recipient (optional principal)))
  (let
    (
      (props (try! (get-name-info)))
      (new-owner (default-to tx-sender recipient))
      (owner (get owner props))
    )
    (asserts! (is-eq tx-sender owner) ERR_UNAUTHORIZED)
    (try! (contract-call? 'SPRG2XNKCEV40EMASB8TG3B599ATHPRWRWSM4EB7.bnsx-registry burn (get id props)))
    (unwrap! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer (get namespace props) (get name props) new-owner none)) ERR_NAME_TRANSFER)
    (ok props)
  )
)

;; Helper method to fetch the BNS legacy name owned by this contract.
(define-read-only (get-own-name)
  (ok (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal (as-contract tx-sender)) ERR_NO_NAME))
)

;; Helper method to fetch information about the BNSx name that is equivalent to the
;; legacy name owned by this contract. For example, if this contract owns `name.btc`,
;; it returns the properties of `name.btc` on BNSx.
(define-read-only (get-name-info)
  (let
    (
      (name (try! (get-own-name)))
      (props (unwrap! (contract-call? 'SPRG2XNKCEV40EMASB8TG3B599ATHPRWRWSM4EB7.bnsx-registry get-name-properties name) ERR_NOT_WRAPPED))
    )
    (ok props)
  )
)

;; Helper method to return the owner of the BNSx name that is equivalent to this
;; contract's legacy name
(define-read-only (get-owner)
  (ok (get owner (try! (get-name-info))))
)

;; Helper method to interact with legacy BNS to update the zonefile for this name
;; 
;; @throws if called by anyone other than the BNSx name owner
(define-public (name-update (namespace (buff 20)) (name (buff 48)) (zonefile-hash (buff 20)))
  (let
    (
      (props (try! (get-name-info)))
    )
    (asserts! (is-eq tx-sender (get owner props)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get namespace props) namespace) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get name props) name) ERR_UNAUTHORIZED)
    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns name-update namespace name zonefile-hash))
      r (ok true)
      e (err (to-uint e))
    )
  )
)

(define-read-only (get-wrapper-id)
  (var-get wrapper-id-var)
)

(define-private (register-self)
  (let
    (
      (self (as-contract tx-sender))
      (id (try! (contract-call? 'SPRG2XNKCEV40EMASB8TG3B599ATHPRWRWSM4EB7.wrapper-migrator register-wrapper self)))
    )
    (var-set wrapper-id-var (some id))
    (ok id)
  )
)

(try! (register-self))