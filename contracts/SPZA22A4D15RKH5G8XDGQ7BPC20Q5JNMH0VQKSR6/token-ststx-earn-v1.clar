;; @contract Token
;; @version 1

(impl-trait .sip-010-trait.sip-010-trait)

;;-------------------------------------
;; Errors
;;-------------------------------------

(define-constant ERR_NOT_AUTHORIZED (err u5001))
(define-constant ERR_ONLY_VAULT_CONTRACT_ALLOWED (err u5002))

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant name "stSTX Earn Token")
(define-constant symbol "stSTXearn")
(define-constant decimals u6)

(define-fungible-token stSTXearn)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var token-uri (string-utf8 256) u"")

;;-------------------------------------
;; SIP-010 
;;-------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply stSTXearn)))

(define-read-only (get-name)
  (ok name))

(define-read-only (get-symbol)
  (ok symbol))

(define-read-only (get-decimals)
  (ok decimals))

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance stSTXearn account)))

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)

    (match (ft-transfer? stSTXearn amount sender recipient)
      response (begin
        (print memo)
        (print { action: "transfer", data: { sender: tx-sender, recipient: recipient, amount: amount, block-height: block-height } })
        (ok response)
      )
      error (err error))))

;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (contract-call? .hq-ststx-earn-v1 check-is-admin tx-sender))
    (ok (var-set token-uri value))))

;;-------------------------------------
;; Mint / Burn
;;-------------------------------------

;; Mint method
(define-public (mint-for-vault (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender .vault-ststx-earn-v1) ERR_ONLY_VAULT_CONTRACT_ALLOWED)
    (ft-mint? stSTXearn amount recipient)))

;; Burn method
(define-public (burn-for-vault (amount uint) (sender principal))
  (begin
    (asserts! (is-eq tx-sender .vault-ststx-earn-v1) ERR_ONLY_VAULT_CONTRACT_ALLOWED)
    (ft-burn? stSTXearn amount sender)))

;; Burn external
(define-public (burn (amount uint))
  (ft-burn? stSTXearn amount tx-sender))