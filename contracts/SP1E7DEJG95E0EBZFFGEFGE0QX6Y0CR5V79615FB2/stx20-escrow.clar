
;; title: STX-20 Sales Contract
;; version: 0.1.0
;; summary: Allows for secure sales of an STX-20 token.
;; description:
;;   The seller of the STX-20 token sends the amount of the token that they
;;   wish to sell to this contract. The buyer also specifies the amount of STX
;;   they would like to sell the tokens for.
;;   The buyer first must separately verify that the contract owns the token.
;;   They can do this using https://stx20.com. Once this is confirmed, the
;;   the buyer can call the `buy-now` function. This function handles
;;   trasnferring the STX to the seller and the STX-20 tokens to the buyer. If
;;   either of those steps fail, then the whole transaction is reverted.

;; Save the seller's (the deployer of this contract) address
(define-constant seller tx-sender)
;; "tSTXS1" in hex
(define-constant memo 0x745354585331)
;; This amount is specified in uSTX
(define-constant sales-price u1000000) ;; 1 STX

;; Error codes
(define-constant ERR_STX_TRANSFER_FAILED (err u101))
(define-constant ERR_ALREADY_TRANSFERRED (err u102))

;; Track whether the token has already been transferred.
(define-data-var transferred bool false)

(define-public (buy-now)
  (let ((buyer tx-sender))
    ;; Verify that a transfer has not already occurred.
    (asserts! (not (var-get transferred)) ERR_ALREADY_TRANSFERRED)
    ;; Set the transferred flag to true.
    (var-set transferred true)
    ;; Transfer the sales price to the seller.
    (unwrap! (stx-transfer? sales-price tx-sender seller) ERR_STX_TRANSFER_FAILED)
    ;; Transfer the STX-20 tokens to the buyer.
    (as-contract (stx-transfer-memo? u1 tx-sender buyer memo))
  )
)