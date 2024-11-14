;; Define constants and variables
(define-constant contract-owner tx-sender)
(define-data-var last-id uint u462)

;; Read-only function to get current last-id
(define-read-only (get-last-id)
    (var-get last-id)
)

;; Public function to airdrop NFTs
(define-public (airdrop (holders (list 25 principal)))
    (begin
        (asserts! (is-eq contract-owner tx-sender) (err u1))
        (asserts! (> (len holders) u0) (err u2))
        (asserts! (<= (len holders) u25) (err u3))
        (ok (map xfer holders))
    )
)

;; Private function to transfer NFT and increment ID
(define-private (xfer (address principal))
    (begin
        (try! (contract-call? 'SPKW6PSNQQ5Y8RQ17BWB0X162XW696NQX1868DNJ.treasure-hunters transfer 
            (var-get last-id) 
            tx-sender  
            address))
        (var-set last-id (+ (var-get last-id) u1))
        (ok true)
    )
)