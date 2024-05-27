;; title: template-batch-endorsements

;; traits
;;
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
;; 
;; (VAR) based on title of collection
(define-non-fungible-token endorsement uint)
;; constants
;;
;; (VAR) changes based on the number of recipients
(define-constant TOTAL u13)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

;; (VAR) changes based on the collection ipfs hash
(define-constant IPFS-ROOT "ipfs://ipfs/bafybeidkeplmox4gj374bext6ziqlgvoiikr7asolmrapqldib3ebt3thy/{id}.json")


;; data vars
;;
(define-data-var last-token-id uint u0)
;; data maps
;;


;; public functions
;;
(define-private (mint (address principal))
    (let (
        (token-id (+ u1 (var-get last-token-id)))
    ) 
    (var-set last-token-id token-id)
    (nft-mint? endorsement token-id address)))

;; Non transferrable
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (err ERROR-NOT-IMPLEMENTED))

(define-public (burn (id uint)) 
    (let (
        (owner (unwrap! (nft-get-owner? endorsement id) (err ERROR-UNAUTHORIZED)))
    ) 
    (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
    (nft-burn? endorsement id owner)))
;; read only functions
;;

;; this would be constant to mark collection as preminted
(define-read-only (get-last-token-id) 
    (ok TOTAL))

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? endorsement id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT)))

;;; mint calls here
(mint 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR)
(mint 'SPVCJJPSESD1Z677N4PD2NDGDJKZB1SDN0DP2Q9S)
(mint 'SP3YV8PJ0GW4A926ZTY5ASB1Q25MGARY88ZGZ741X)
(mint 'SP2MSV1XW3XR2NSWK6RHDPF5QSK6KZYH9EYKD5N0Q)
(mint 'SP2FY8MV3EZVRTG2Q9J1KMMRVKC86DQ00BGGCQJXQ)
(mint 'SP1RG3YP9C8SC82GVHT1E1WG22MYHTCJ4FT3T9R4G)
(mint 'SP70S68PQ3FZ5N8ERJVXQQXWBWNTSCMFZWWFZXNR)
(mint 'SP70S68PQ3FZ5N8ERJVXQQXWBWNTSCMFZWWFZXNR)
(mint 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P)
(mint 'SP3JV9T1V10BGWFP2MC1EFMRHMTM1RJB3125JV3HH)
(mint 'SPVCJJPSESD1Z677N4PD2NDGDJKZB1SDN0DP2Q9S)
(mint 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y)
(mint 'SP1SE73VJ07WQSZSFJ1QP3SX7TVRPVJGYP0S89WWH)
