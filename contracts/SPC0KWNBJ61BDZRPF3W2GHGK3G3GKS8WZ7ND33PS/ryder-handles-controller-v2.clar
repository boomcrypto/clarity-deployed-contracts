;; @contract Ryder Handles Controller
;; @version 2

(define-data-var contract-owner principal tx-sender)
(define-map community-treasuries (buff 20) principal)

(define-data-var approval-pubkey (buff 33) 0x00)
(define-data-var price-in-ustx uint u9999999)

;; between name-preorder and name-register must be less than 3 days.
(define-constant name-preorder-claimability-ttl u432)

(define-map name-preorders
  { hashed-salted-fqn: (buff 20), buyer: principal }
  { created-at: uint, claimed: bool, price: uint })

(define-map renewal-signatures (buff 65) bool)

;; error codes
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-max-renewal-reached (err u500))
(define-constant err-signature-already-used (err u501))
(define-constant err-invalid-claim (err u502))
(define-constant err-too-early (err u503))

(define-constant err-name-already-claimed (err u2011))
(define-constant err-name-claimability-expired (err u2012))
(define-constant err-preorder-already-exists (err u2016))
(define-constant err-hash-malformated (err u2017))

;; preorder a name by registering a hash of the salted name
;; tx-sender has to pay registration fees here
;; returns the blockheight before the name has to be revealed
(define-public (name-preorder (hashed-salted-fqn (buff 20)) (buyer (optional principal)))
  (let ((price (var-get price-in-ustx))
        (preorder-key { hashed-salted-fqn: hashed-salted-fqn, buyer: (default-to tx-sender buyer) })
        (former-preorder
            (map-get? name-preorders preorder-key)))
    ;; ensure eventual former pre-order expired
    (asserts!
      (or (is-none former-preorder)
          (>= block-height (+ name-preorder-claimability-ttl
                              (unwrap-panic (get created-at former-preorder)))))
      err-preorder-already-exists)
    ;; ensure that the hashed fqn is 20 bytes long
    (asserts! (is-eq (len hashed-salted-fqn) u20) err-hash-malformated)
    ;; ensure that user will be paying. First to escrow, then to community on reveal
    (try! (pay-fees price none))
    ;; store the pre-order
    (map-set name-preorders
      preorder-key
      { created-at: block-height, claimed: false, price: price })
    (ok (+ block-height name-preorder-claimability-ttl))))

;; @desc register an ordered name, this is the second tx of the registration flow
;; @event: tx-sender sends 1 stx
;; @event: community-handles burns 1 stx
;; @event: community-handles sends name nft to tx-sender
(define-public (name-register (namespace (buff 20))
                              (name (buff 48))                            
                              (salt (buff 20))
                              (approval-signature (buff 65))
                              (owner principal)
                              (zonefile-hash (buff 20)))
  (let ((hashed-salted-fqn (hash160 (concat (concat (concat name 0x2e) namespace) salt)))
        (preorder-key { hashed-salted-fqn: hashed-salted-fqn, buyer: owner })
        (preorder (unwrap!
          (map-get? name-preorders preorder-key)
          err-not-found))
        (hash (sha256 (concat (concat (concat name 0x2e) namespace) salt))))
    ;; Name must be approved by current approver
    (asserts! (secp256k1-verify hash approval-signature (var-get approval-pubkey)) err-not-authorized)
    ;; The preorder entry must be unclaimed
    (asserts!
        (not (get claimed preorder))
        err-name-already-claimed)        
    ;; Less than 24 hours must have passed since the name was preordered
    (asserts!
        (< block-height (+ (get created-at preorder) name-preorder-claimability-ttl))
        err-name-claimability-expired)
    (map-set renewal-signatures approval-signature true)
    (map-set name-preorders preorder-key (merge preorder {claimed: true}))
    (try! (pay-fees-from-escrow (get price preorder) namespace))
    (try! (stx-transfer? u1 tx-sender (as-contract tx-sender)))
    (try! (as-contract (contract-call? .community-handles-v2 name-register namespace name owner zonefile-hash)))
    (ok true)))


;; renew a name
;; a new signature is required for each renewal
;; @param name; the name to renew
;; @param salt; the salt used by the approver
;; @param approval-signature; signed hash by the approver
;; @param new-owner;
;; @param zonefile-hash;
(define-public (name-renewal (namespace (buff 20))
                             (name (buff 48))
                             (salt (buff 20))
                             (approval-signature (buff 65))
                             (new-owner (optional principal))
                             (zonefile-hash (optional (buff 20))))
  (let ((price (var-get price-in-ustx))
        (owner tx-sender)
        (hash (sha256 (concat (concat (concat name 0x2e) namespace) salt))))
      ;; signature must be correct
      (asserts! (secp256k1-verify hash approval-signature (var-get approval-pubkey)) err-not-authorized)
      ;; signature must be unused
      (asserts! (is-none (map-get? renewal-signatures approval-signature)) err-signature-already-used) 
      (map-set renewal-signatures approval-signature true)
      (try! (pay-fees price (some namespace)))
      (try! (contract-call? .community-handles-v2 name-renewal namespace name new-owner zonefile-hash))
      (ok true)))

(define-private (pay-fees (price uint) (namespace-or-escrow (optional (buff 20))))
  (let ((amount-controller-admin (/ (* price u70) u100))
        (amount-community (- price amount-controller-admin))
        (controller-admin (var-get contract-owner))        
        (community-treasury (match namespace-or-escrow
                              namespace (default-to controller-admin (map-get? community-treasuries namespace))
                              (as-contract tx-sender))))
    (and (> amount-controller-admin u0)
        (try! (stx-transfer? amount-controller-admin tx-sender controller-admin)))
    (and (> amount-community u0)
        (try! (stx-transfer? amount-community tx-sender community-treasury)))
    (ok true)))

(define-private (pay-fees-from-escrow (price uint) (namespace (buff 20)))
    (let ((amount-controller-admin (/ (* price u70) u100))
          (amount-community (- price amount-controller-admin))
          (community-treasury (default-to (var-get contract-owner) (map-get? community-treasuries namespace))))
        (and (> amount-community u0)
            (try! (as-contract (stx-transfer? amount-community tx-sender community-treasury))))
        (ok true)))

;;
;; admin functions
;;
(define-public (set-price (amount-in-ustx uint))
    (begin
        (try! (is-contract-owner))
        (var-set price-in-ustx amount-in-ustx)
        (ok true)))

(define-public (set-community-treasury (namespace (buff 20)) (new-treasury principal))
   (begin
        (try! (is-contract-owner))
        (map-set community-treasuries namespace new-treasury)
        (ok true)))

(define-public (set-approval-pubkey (new-pubkey (buff 33)))
   (begin
        (try! (is-contract-owner))
        (var-set approval-pubkey new-pubkey)
        (ok true)))


(define-public (set-contract-owner (new-owner principal))
    (begin
        (try! (is-contract-owner))
        (var-set contract-owner new-owner)
        (ok true)))

;; hand over control of namespace to new controller
;; can only be called by contract owner of this contract
(define-public (set-namespace-controller (namespace (buff 20)) (new-controller principal))
    (begin
        (try! (is-contract-owner))
        (try! (as-contract (contract-call? .community-handles-v2 set-namespace-controller namespace new-controller)))
        (ok true)))

;;
;; utilities
;;

;; @desc retrieve unused fees from escrow
;; If name-register wasn't called successfully the community amount is in escrow
;; and can be claimed by the controller-admin
(define-public (claim-fees (hashed-salted-fqn (buff 20)) (owner principal))
    (let ((preorder-key { hashed-salted-fqn: hashed-salted-fqn, buyer: owner })
          (preorder (unwrap!
            (map-get? name-preorders preorder-key)
            err-not-found))
          (price (get price preorder))
          (amount-controller-admin (/ (* price u70) u100))
          (amount-community (- price amount-controller-admin)))
      (asserts! (not (get claimed preorder)) err-invalid-claim)
      (asserts! (> block-height (+ (get created-at preorder) name-preorder-claimability-ttl)) err-too-early)

      (and (> amount-community u0)
           (map-set name-preorders preorder-key (merge preorder {claimed: true}))
           (try! (as-contract (stx-transfer? amount-community tx-sender (var-get contract-owner)))))
      (ok true)))

(define-private (is-contract-owner)
    (ok (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)))

(define-read-only (get-contract-owner)
    (var-get contract-owner))
