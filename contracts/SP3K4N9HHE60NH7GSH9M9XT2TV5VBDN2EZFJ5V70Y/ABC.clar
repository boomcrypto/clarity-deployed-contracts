
;; constants
;; The address for contract owner who deployed this contract.
(define-constant contract-owner tx-sender)
;; Errors
(define-constant ERR_CONTRACT_OWNER_ONLY u0)
(define-constant ERR_TOKEN_OWNER_ONLY u3)

;; Implement the `ft-trait` trait defined in the `ft-trait` contract
;; (impl-trait .ft-trait.sip-010-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token sbc)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance sbc owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply sbc)))

;; returns the token name
(define-read-only (get-name)
  (ok "SBC TOKEN"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "SBC"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))


;; Checks if sender is contract owner
(define-private (is-sender-contract-owner)
   (is-eq tx-sender contract-owner)
)

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? sbc amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-read-only (get-token-uri)
  (ok (some u"https://sbp-public.s3.amazonaws.com/json/sbc.json")))

;; UTILITIES
;; Checks if caller is contract owner
(define-private (is-caller-contract-owner)
   (is-eq contract-caller contract-owner)
)

;; Mints new tokens, only accessible by contract owner.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-caller-contract-owner) (err ERR_CONTRACT_OWNER_ONLY))
    (ft-mint? sbc amount recipient)
  )
)

;; Mint this token to a few people when deployed
(ft-mint? sbc u100000000 'SP3VFN286CGN9N7D1R5M5D4VPDAYCJHCZSSM98BVS)