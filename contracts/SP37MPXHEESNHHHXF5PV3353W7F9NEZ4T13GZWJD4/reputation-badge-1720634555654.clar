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
(define-constant TOTAL u18)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

;; (VAR) changes based on the collection ipfs hash
(define-constant IPFS-ROOT "ipfs://ipfs/QmRnuedWZ2Y59UDzgUMwpTahNN6zd4yQnK8SzUJ7BvNjUm/{id}.json")


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
(mint 'SP15NRP6NNP8FQ4ZE8MN999C2CMSE43ZK3Y3QGN45)
(mint 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P)
(mint 'SP1PHAGEQ5RWM8G84DFGMRPENKQGFC4QJ9YWXAYKF)
(mint 'SP1ZHGD5N96421HBVB41G444TEZR70KDGTTBGNXNN)
(mint 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB)
(mint 'SP2JXH5S8228Z33KP7N1E9MYHKTH15FNNWK1WNY9J)
(mint 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB)
(mint 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP)
(mint 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(mint 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ)
(mint 'SP3A4KQ6PWTPK5CDPZRAGBN3CVEVA2M8A652TH5XG)
(mint 'SP3EW5GY6DM9ZT6T20F58PRJNG64VETHKHJF24A9D)
(mint 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864)
(mint 'SP7QQ9DV0DMV7YW4HR713MKBWADVA0BFC2J65PJT)
(mint 'SPAHTV25EDZPSFPSH3DGKN0ANRSDMEHYFVA1CS3N)
(mint 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB)
(mint 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC)
(mint 'SPWVKHWDQCPCS3QFYTWGNQYA72WZKQKR41S1N1XF)
