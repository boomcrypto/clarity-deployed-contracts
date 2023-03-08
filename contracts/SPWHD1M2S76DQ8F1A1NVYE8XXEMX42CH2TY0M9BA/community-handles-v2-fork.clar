
;; community-handles-v2-fork
;; fork of community-handles-v2 contract, which adds methods for 
;; namespace-update-function-price and 
;; namespace-revoke-function-price-edition for added flexibility

(define-constant err-not-authorized (err u403))
(define-constant internal-price-high u999999999999999999999999999999)
(define-constant name-salt 0x00)
(define-fungible-token danger-zone-token)

(define-map namespace-controller (buff 20) principal)

;; variables for iteration functions
(define-data-var ctx-bulk-registration-namespace (buff 20) 0x00)

;; @desc preorder the namespace on-chain
;; @param hashed-salted-namespace; ripdem160 hash of namespace concat with salt
;; @param stx-to-burn; namespace price in ustx
(define-public (namespace-preorder (hashed-salted-namespace (buff 20)) (stx-to-burn uint))
    (contract-call? 'SP000000000000000000002Q6VF78.bns
        namespace-preorder hashed-salted-namespace stx-to-burn))

;; @desc reveal the namespace
;; @param namespace; namespace to register
;; @param salt; salt used during preorder
;; @param lifetime; number of blocks until a name expires
;; @param controller; optional principal set as the first namespace controller
;;          defaults to contract-caller
(define-public (namespace-reveal (namespace (buff 20)) (salt (buff 20)) (lifetime uint) (controller (optional principal)))
    (begin
        (map-set namespace-controller namespace (default-to contract-caller controller))
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

;; desc update price function
(define-public (namespace-update-function-price (namespace (buff 20))
                                        (p-func-base uint)
                                        (p-func-coeff uint)
                                        (p-func-b1 uint)
                                        (p-func-b2 uint)
                                        (p-func-b3 uint)
                                        (p-func-b4 uint)
                                        (p-func-b5 uint)
                                        (p-func-b6 uint)
                                        (p-func-b7 uint)
                                        (p-func-b8 uint)
                                        (p-func-b9 uint)
                                        (p-func-b10 uint)
                                        (p-func-b11 uint)
                                        (p-func-b12 uint)
                                        (p-func-b13 uint)
                                        (p-func-b14 uint)
                                        (p-func-b15 uint)
                                        (p-func-b16 uint)
                                        (p-func-non-alpha-discount uint)
                                        (p-func-no-vowel-discount uint))
    (begin
       (try! (is-contract-caller-namespace-controller namespace))
       (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace p-func-base p-func-coeff p-func-b1 p-func-b2 p-func-b3 p-func-b4 p-func-b5 p-func-b6 p-func-b7 p-func-b8 p-func-b9 p-func-b10 p-func-b11 p-func-b12 p-func-b13 p-func-b14 p-func-b15 p-func-b16 p-func-non-alpha-discount p-func-no-vowel-discount))))
       (ok true)))

;; @desc revoke ability to change price for namespace
;; @param namespace controlled namespace
(define-public (namespace-revoke-function-price-edition (namespace (buff 20)))
    (begin
        (try! (is-contract-caller-namespace-controller namespace))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-revoke-function-price-edition namespace))))
        (ok true)))

;; @desc register name for 1 ustx by namespace controller only
;; @param namespace; controlled namespace
;; @param name; name in the controlled namespace
;; @param zonefile-hash; hash of the attachment/zonefile for the name
;; @param owner; principal owning the name after registration 
(define-public (name-register (namespace (buff 20))
                              (name (buff 48))
                              (owner principal)
                              (zonefile-hash (buff 20)))
    (let ((hash (hash160 (concat (concat (concat name 0x2e) namespace) name-salt))))
        (try! (is-contract-caller-namespace-controller namespace))
        (try! (to-uint-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hash u1)))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u1 u1))))
        (try! (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name name-salt zonefile-hash)))
        (try! (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name owner (some zonefile-hash))))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace internal-price-high u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1))))        
        (ok true)))

;; @desc renew a name for 1 ustx by namespace controller only
;; @param namespace; controlled namespace
;; @param name; name in the controlled namespace
;; @param new-owner; optional new owner of name after renewal
;; @param zonefile-hash; optional new zonefile hash after renewal
(define-public (name-renewal (namespace (buff 20))
                             (name (buff 48))
                             (new-owner (optional principal))
                             (zonefile-hash (optional (buff 20))))
    (let ((original-owner tx-sender))
        (try! (is-contract-caller-namespace-controller namespace))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u0 u1 u1))))
        (try! (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal namespace name u1 new-owner zonefile-hash)))
        (try! (as-contract (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price namespace internal-price-high u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1))))
        (ok true)))


;; iterator for bulk-name-register
(define-private (bulk-name-register-iter (entry {name: (buff 48), owner: principal, zonefile-hash: (buff 20)}) (prev (response bool uint)))
    (let ((namespace (var-get ctx-bulk-registration-namespace))
          (name (get name entry))
          (hash (hash160 (concat (concat (concat name 0x2e) namespace) name-salt))))
        (try! prev)
        (try! (to-uint-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hash u1)))
        (try! (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name name-salt (get zonefile-hash entry))))
        (try! (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (get owner entry) (some (get zonefile-hash entry)))))
        (ok true)))

;; @desc register multiple namens for 1 ustx by namespace controller only
;; @param namespace; controlled namespace
;; @param names; list of names with owner and hash of the attachment/zonefile for the name
(define-public (bulk-name-register (namespace (buff 20)) (names (list 1000 {name: (buff 48), owner: principal, zonefile-hash: (buff 20)})))
    (begin
        (try! (is-contract-caller-namespace-controller namespace))
        (var-set ctx-bulk-registration-namespace namespace)
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

(define-private (is-contract-caller-namespace-controller (namespace (buff 20)))
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
        (try! (is-contract-caller-namespace-controller namespace))
        (try! (ft-mint? danger-zone-token u1 tx-sender))
        (try! (ft-burn? danger-zone-token u1 tx-sender))
        (map-set namespace-controller namespace new-controller)
        (ok true)))