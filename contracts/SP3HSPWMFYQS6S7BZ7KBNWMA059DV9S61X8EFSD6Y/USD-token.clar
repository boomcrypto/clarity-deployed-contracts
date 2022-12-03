;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .googlier-dao-token-trait-v1.dao-token-trait)

;; Defines the USD Stablecoin according to the SIP-010 Standard
(define-fungible-token USD)

(define-data-var token-uri (string-utf8 256) u"")

;; errors
(define-constant ERR-NOT-AUTHORIZED u14401)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply USD))
)

(define-read-only (get-name)
  (ok "USD")
)

(define-read-only (get-symbol)
  (ok "USD")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance USD account))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender (contract-call? .googlier-dao get-dao-owner))
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))

    (match (ft-transfer? USD amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

;; ---------------------------------------------------------
;; DAO token trait
;; ---------------------------------------------------------

;; Mint method for DAO
(define-public (mint-for-dao (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq contract-caller .googlier-dao) (err ERR-NOT-AUTHORIZED))
    (ft-mint? USD amount recipient)
  )
)

;; Burn method for DAO
(define-public (burn-for-dao (amount uint) (sender principal))
  (begin
    (asserts! (is-eq contract-caller .googlier-dao) (err ERR-NOT-AUTHORIZED))
    (ft-burn? USD amount sender)
  )
)

;; Burn external - Should never happen
(define-public (burn (amount uint) (sender principal))
  (err ERR-NOT-AUTHORIZED)
)

;; Initialize the contract
(begin
  ;; TODO: do not do this on testnet or mainnet
  (try! (ft-mint? USD u10 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y))
  (try! (ft-mint? USD u1000000000000 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y)) ;; 1 million USD
  (try! (ft-mint? USD u1000000000000 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y)) ;; 1 million USD
  (try! (ft-mint? USD u1000000000000 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y)) ;; 1 million USD
  (try! (ft-mint? USD u1000000000000 'SP3HSPWMFYQS6S7BZ7KBNWMA059DV9S61X8EFSD6Y)) ;; 1 million USD
)
