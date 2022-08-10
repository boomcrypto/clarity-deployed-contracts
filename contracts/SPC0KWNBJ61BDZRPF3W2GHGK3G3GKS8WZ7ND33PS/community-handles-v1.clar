;; @contract Community Handles
;; @version 1

(define-constant err-not-authorized (err u403))
(define-constant internal-price-high u999999999999999999999999999999)
(define-constant salt 0x00)

(define-map namespace-controller (buff 20) principal)

;; variables for iteration functions
(define-data-var ctx-bulk-registration-namespace (buff 20) 0x00)

;; @desc register the namespace on-chain
;; @param namespace; namespace to register
;; @param stx-to-burn; namespace price in ustx
;; @param lifetime; number of blocks until a name expires
(define-public (namespace-setup (namespace (buff 20)) (stx-to-burn uint) (lifetime uint))
    (let ((hashed-salted-namespace (hash160 (concat namespace salt))))
        (map-set namespace-controller namespace contract-caller)
        (try! (contract-call? 'SP000000000000000000002Q6VF78.bns
                namespace-preorder hashed-salted-namespace stx-to-burn))    
        (try! (contract-call? 'SP000000000000000000002Q6VF78.bns
                                namespace-reveal
                                namespace
                                salt
                                internal-price-high u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1
                                lifetime
                                (as-contract tx-sender)))        
        (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns
                                namespace-ready namespace)))
        (ok true)))

;; @desc register name for 1 ustx by namespace controller only
;; @param namespace; controlled namespace
;; @param name; name in the controlled namespace
;; @param zonefile-hash; hash of the attachment/zonefile for the name
;; @param owner; principal owning the name after registration 
(define-public (name-register (namespace (buff 20))
                              (name (buff 48))
                              (zonefile-hash (buff 20))
                              (owner principal))
    (let ((hash (hash160 (concat (concat (concat name 0x2e) namespace) salt))))
        (try! (is-namespace-controller namespace))
        (try! (stx-transfer? u1 tx-sender (as-contract tx-sender)))
        (try! (as-contract (to-uint-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hash u1))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u1 u1))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name salt zonefile-hash))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name owner (some zonefile-hash)))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace internal-price-high u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1))))        
        (ok true)))

;; iterator for bulk-name-register
(define-private (bulk-name-register-iter (entry {name: (buff 48), owner: principal, zonefile-hash: (buff 20)}) (prev (response bool uint)))
    (let ((namespace (var-get ctx-bulk-registration-namespace))
          (name (get name entry))
          (hash (hash160 (concat (concat (concat name 0x2e) namespace) salt)))
          (zonefile-hash (get zonefile-hash entry)))
        (try! prev)
        (try! (as-contract (to-uint-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hash u1))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name salt zonefile-hash))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (get owner entry) (some zonefile-hash)))))
        (ok true)))

;; @desc register multiple namens for 1 ustx by namespace controller only
;; @param namespace; controlled namespace
;; @param names; list of names with owner and hash of the attachment/zonefile for the name
(define-public (bulk-name-register (namespace (buff 20)) (names (list 1000 {name: (buff 48), owner: principal, zonefile-hash: (buff 20)})))
    (begin
        (try! (is-namespace-controller namespace))
        (var-set ctx-bulk-registration-namespace namespace)
        (try! (stx-transfer? (len names) tx-sender (as-contract tx-sender)))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u1 u1))))
        (try! (fold bulk-name-register-iter names (ok true)))
        (var-set ctx-bulk-registration-namespace 0x00)
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace internal-price-high u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1))))
        (ok true)))

;; convert response to standard uint response with uint error
;; (response uint int) (response uint uint)
(define-private (to-uint-response (value (response uint int)))
    (match value
           success (ok success)
           error (err (to-uint error))))

;; convert response to standard bool response with uint error
;; (response bool int) (response bool uint)
(define-private (to-bool-response (value (response bool int)))
    (match value
           success (ok success)
           error (err (to-uint error))))

(define-private (is-namespace-controller (namespace (buff 20)))
    (ok (asserts! (is-eq (map-get? namespace-controller namespace) (some contract-caller)) err-not-authorized)))

(define-read-only (get-namespace-controller (namespace (buff 20)))
    (map-get? namespace-controller namespace))

;; @desc set new namespace controller, by current namespace owner only
;;
;; It is the responsibility of the namespace controller to
;; ensure that the new controller can manage the namespace.
;; Otherwise, it might happen that new names can NOT be registered anymore.
;;
;; @param namespace; controlled namespace by contract caller
;; @param new-controller; new namespace controller
(define-public (set-namespace-controller (namespace (buff 20)) (new-controller principal))
    (begin
        (try! (is-namespace-controller namespace))
        (map-set namespace-controller namespace new-controller)
        (ok true)))
