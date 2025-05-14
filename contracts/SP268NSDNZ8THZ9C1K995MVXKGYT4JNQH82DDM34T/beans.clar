;; Version: 1.0 - Mainnet Deployment

;; Import the standard SIP-010 trait
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Configuration
(define-constant fee-collector 'SPPKR81WF4WY5RPQN34YAMBZST0XF2VFMRX5RB5N) ;; Fixed fee collector address
(define-constant tip-fee u4000) ;; Fixed fee: 0.004 STX = 4000 microSTX

;; Error codes
(define-constant ERR_SAME_SENDER_RECIPIENT (err u100)) ;; Cannot tip yourself
(define-constant ERR_INSUFFICIENT_STX (err u102))      ;; Insufficient STX balance
(define-constant ERR_INSUFFICIENT_TOKENS (err u103))   ;; Insufficient token balance
(define-constant ERR_INVALID_AMOUNT (err u104))        ;; Invalid tip amount (e.g., 0)
(define-constant ERR_INVALID_RECIPIENT (err u105))     ;; Invalid recipient (e.g., contract itself)

;; STX Tip Function
(define-public (tip-stx (recipient principal) (amount uint) (memo (optional (buff 34))))
  (begin
    ;; Prevent sender from tipping themselves
    (asserts! (not (is-eq tx-sender recipient)) ERR_SAME_SENDER_RECIPIENT)
    ;; Prevent tipping to the contract itself
    (asserts! (not (is-eq recipient (as-contract tx-sender))) ERR_INVALID_RECIPIENT)
    ;; Ensure tip amount is greater than 0
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    ;; Calculate total STX required: tip amount + fee
    (let ((total-cost (+ amount tip-fee)))
      ;; Check sender's STX balance for tip + fee
      (asserts! (>= (stx-get-balance tx-sender) total-cost) ERR_INSUFFICIENT_STX)
      ;; Transfer full tip amount to recipient
      (try! (stx-transfer? amount tx-sender recipient))
      ;; Transfer fee to collector
      (try! (stx-transfer? tip-fee tx-sender fee-collector))
      ;; Print memo if provided
      (if (is-some memo)
        (begin
          (print (unwrap-panic memo))
          true)
        (begin
          (print "No memo provided")
          true))
      ;; Return success response
      (ok { recipient: recipient,
            tip: amount,
            fee: tip-fee }))))

;; SIP-010 Token Tip Function
(define-public (tip-ft (token <sip-010-trait>) (recipient principal) (amount uint) (memo (optional (buff 34))))
  (begin
    ;; Prevent sender from tipping themselves
    (asserts! (not (is-eq tx-sender recipient)) ERR_SAME_SENDER_RECIPIENT)
    ;; Prevent tipping to the contract itself
    (asserts! (not (is-eq recipient (as-contract tx-sender))) ERR_INVALID_RECIPIENT)
    ;; Ensure tip amount is greater than 0
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    ;; Check sender's STX balance for fee
    (asserts! (>= (stx-get-balance tx-sender) tip-fee) ERR_INSUFFICIENT_STX)
    ;; Check sender's token balance
    (asserts! (>= (try! (contract-call? token get-balance tx-sender)) amount) ERR_INSUFFICIENT_TOKENS)
    ;; Transfer full token amount to recipient with memo
    (try! (contract-call? token transfer amount tx-sender recipient memo))
    ;; Transfer fee to collector
    (try! (stx-transfer? tip-fee tx-sender fee-collector))
    ;; Print memo if provided
    (if (is-some memo)
      (begin
        (print (unwrap-panic memo))
        true)
      (begin
        (print "No memo provided")
        true))
    ;; Return success response
    (ok { recipient: recipient,
          token: (contract-of token),
          token-amount: amount,
          fee: tip-fee })))