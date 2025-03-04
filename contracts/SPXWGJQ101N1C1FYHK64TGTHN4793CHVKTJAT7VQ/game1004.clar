;; constant errors
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INSUFFICIENT-FUNDS (err u504))
(define-constant INVALID-DIAMOND-COUNT (err u407))
(define-constant INVALID-STX-BALANCE (err u408))
(define-constant ERR-TRANSFER-MULTISIG (err u409))
(define-constant ERR-TRANSFER-PROGRESSIVE (err u4503))
(define-constant ERR-TRANSFER-KRYPTOMIND (err u501))
(define-constant ERR-TRANSFER-BURN-WALLET (err u601))
(define-constant INVALID-HEART-COUNT (err u502))
(define-constant ERR-ENTER-NEW-WALLET (err u505))
(define-constant ERR-SAME-PERCENTAGE (err u508))
(define-constant ERR-SWAP-FAILED (err u509))
(define-constant INSUFFICIENT-STX-TO-ENTER (err u604))

;; Public variables for the percentages
(define-data-var percentage-progressive uint u10)
(define-data-var percentage-multisig uint u45)
(define-data-var percentage-burn uint u35)
(define-data-var percentage-kryptomind uint u20)
  
;; Public variables for the wallets
(define-data-var MULTISIG_WALLET principal 'SP11SKCKNE62GT113W5GZP4VNB47536GFH88MTVPD);;2
(define-data-var KRYPTOMIND principal 'SPVBZEFW7X123Q3GXC2YH4XV1SS0DW1MHTNJD6KE);;3
(define-data-var BURN_WALLET principal 'SP362TJX91ATWS1NJMRZVFEXHAQX6PR6GCBRJWVY2);;4
(define-data-var PROGRESSIVE_WALLET principal 'SP321AS0HTY0Q62NQ4N6BV8N03AR1MS2XG55026MT);;5
(define-data-var POOL_WALLET principal 'SPYTVYHJ0SJFTAH1VSQ74DREFFTTNS8XQ98K9X85);;6

;; Public variables 
(define-data-var total-stx-swapped uint u0) 
(define-data-var total-stone-burned uint u0) 
(define-data-var progressive-pool uint u0)

;; Mappings 
(define-map user-diamonds {user: principal} {diamonds: uint})
(define-map user-hearts {user: principal} {hearts: uint})
(define-map user-contest-inventory principal {hearts: uint, diamonds: uint})

(define-data-var contract-owner principal tx-sender)

;; helper functions

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)


(define-private (swap (stx-amount uint))
  (begin 
  (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)

        (asserts! 
        (is-ok 
        (contract-call? 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
        swap-exact-tokens-for-tokens
        u79
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
        stx-amount
        u1
        )) ERR-SWAP-FAILED)
         (ok stx-amount)
        )
  )

;; Setter functions

(define-public (set-contract-owner (owner principal))
  (begin  
  (try! (check-is-owner))
  (asserts! (not (is-eq owner (var-get contract-owner))) ERR-ENTER-NEW-WALLET)
    (var-set contract-owner owner)
    (ok owner)
  )
)

(define-public (set-percentage-progressive (new-percentage uint))
  (begin
    (try! (check-is-owner))
     (asserts! (not (is-eq new-percentage (var-get percentage-progressive))) ERR-SAME-PERCENTAGE)
    (var-set percentage-progressive new-percentage)
    (ok new-percentage)))

(define-public (set-percentage-multisig (new-percentage uint))
  (begin
    (try! (check-is-owner))
     (asserts! (not (is-eq new-percentage (var-get percentage-multisig))) ERR-SAME-PERCENTAGE)
    (var-set percentage-multisig new-percentage)
    (ok new-percentage)))

(define-public (set-percentage-burn (new-percentage uint))
  (begin
   (try! (check-is-owner))
     (asserts! (not (is-eq new-percentage (var-get percentage-burn))) ERR-SAME-PERCENTAGE)
    (var-set percentage-burn new-percentage)
    (ok new-percentage)))

(define-public (set-percentage-kryptomind (new-percentage uint))
  (begin
    (try! (check-is-owner))
     (asserts! (not (is-eq new-percentage (var-get percentage-kryptomind))) ERR-SAME-PERCENTAGE)
    (var-set percentage-kryptomind new-percentage)
    (ok new-percentage)))
    


(define-public (set-multisig-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get MULTISIG_WALLET))) ERR-ENTER-NEW-WALLET)
    (var-set MULTISIG_WALLET new-wallet)
    (ok new-wallet)))

(define-public (set-kryptomind-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get KRYPTOMIND))) ERR-ENTER-NEW-WALLET)
    (var-set KRYPTOMIND new-wallet)
    (ok new-wallet)))

(define-public (set-burn-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get BURN_WALLET)))  ERR-ENTER-NEW-WALLET)
    (var-set BURN_WALLET new-wallet)
    (ok new-wallet))
)
(define-public (set-progressive-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get PROGRESSIVE_WALLET)))  ERR-ENTER-NEW-WALLET)
    (var-set PROGRESSIVE_WALLET new-wallet)
    (ok new-wallet))
)
    
(define-public (set-pool-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get POOL_WALLET))) ERR-ENTER-NEW-WALLET)
    (var-set POOL_WALLET new-wallet)

    (ok new-wallet)
  )
)




;; Getter functions 
(define-read-only (get-multisig-wallet) (ok (var-get MULTISIG_WALLET)))

(define-read-only (get-kryptomind-wallet) (ok (var-get KRYPTOMIND)))

(define-read-only (get-burn-wallet) (ok (var-get BURN_WALLET)))

(define-read-only (get-pool-wallet) (ok (var-get POOL_WALLET)))

(define-read-only (get-progressive-wallet) (ok (var-get PROGRESSIVE_WALLET)))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-total-stx-swapped)
  (ok (var-get total-stx-swapped))
)
(define-read-only (get-total-stone-burned)
  (ok (var-get total-stone-burned))
)


(define-read-only (get-percentage-progressive)
  (ok (var-get percentage-progressive)))

(define-read-only (get-percentage-burn)
  (ok (var-get percentage-burn)))

(define-read-only (get-percentage-kryptomind)
  (ok (var-get percentage-kryptomind)))

  (define-read-only (get-percentage-multisig)
  (ok (var-get percentage-multisig))
)

(define-read-only (get-progressive-pool-balance)
  (var-get progressive-pool))  

(define-read-only (get-user-contest-inventory (user principal))
  (map-get? user-contest-inventory user)) 

(define-read-only (get-user-diamonds (user principal))
  (ok (default-to {diamonds: u0} (map-get? user-diamonds {user: user}))))

(define-read-only (get-user-hearts (user principal))
  (ok (default-to {hearts: u0} (map-get? user-hearts {user: user}))))

;; Purchase diamonds
(define-public (buy-diamonds (diamond-count uint))
  (begin
    (asserts! (or (is-eq diamond-count u5) (is-eq diamond-count u25) (is-eq diamond-count u50) (is-eq diamond-count u100))
      INVALID-DIAMOND-COUNT)

    (let ((required-stx
            (if (is-eq diamond-count u5) u200000
              (if (is-eq diamond-count u25) u400000
                (if (is-eq diamond-count u50) u700000
                  (if (is-eq diamond-count u100) u1000000 u0))))))
      (asserts! (>= (stx-get-balance tx-sender) required-stx) INVALID-STX-BALANCE)
      (let ((share-to-progressive (/ (* required-stx (var-get percentage-progressive)) u100))
            (remaining-stx (- required-stx (/ (* required-stx (var-get percentage-progressive)) u100))) 
            (share-to-multisig (/ (* remaining-stx (var-get percentage-multisig)) u100))
            (share-to-burn (/ (* remaining-stx (var-get percentage-burn)) u100))
            (share-to-kryptomind (/ (* remaining-stx (var-get percentage-kryptomind)) u100))
            (swapped-stone (try! (swap share-to-burn))) )

        (unwrap! (stx-transfer? share-to-progressive tx-sender (var-get PROGRESSIVE_WALLET)) ERR-TRANSFER-PROGRESSIVE)
        (asserts! (is-ok  (contract-call? 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                                    transfer
                                     swapped-stone tx-sender (var-get BURN_WALLET) none)) ERR-TRANSFER-BURN-WALLET)
        (unwrap! (stx-transfer? share-to-multisig tx-sender (var-get MULTISIG_WALLET)) ERR-TRANSFER-MULTISIG)
       
        (unwrap! (stx-transfer? share-to-kryptomind tx-sender (var-get KRYPTOMIND)) ERR-TRANSFER-KRYPTOMIND)
        (var-set total-stx-swapped (+ (var-get total-stx-swapped) share-to-burn))
        (var-set total-stone-burned (+ (var-get total-stone-burned) swapped-stone))
        (map-set user-diamonds {user: tx-sender}
          {diamonds: (+ (get diamonds (default-to {diamonds: u0} (map-get? user-diamonds {user: tx-sender}))) diamond-count)})
        (ok diamond-count)))))

;; Purchase hearts
(define-public (buy-hearts (heart-count uint))
  (begin
    (asserts! (or (is-eq heart-count u3) (is-eq heart-count u10) (is-eq heart-count u25) (is-eq heart-count u50)) 
      INVALID-HEART-COUNT)

    (let ((required-stx (if (is-eq heart-count u3) u1000000
                          (if (is-eq heart-count u10) u2000000
                              (if (is-eq heart-count u25) u3000000
                                  (if (is-eq heart-count u50) u4000000 u0))))))
      (asserts! (>= (stx-get-balance tx-sender) required-stx) INVALID-STX-BALANCE)
      
      (let ((share-to-progressive (/ (* required-stx (var-get percentage-progressive)) u100))
            (remaining-stx (- required-stx (/ (* required-stx (var-get percentage-progressive)) u100))) ;; Remaining STX after 10%
            (share-to-multisig (/ (* remaining-stx (var-get percentage-multisig)) u100))
            (share-to-burn (/ (* remaining-stx (var-get percentage-burn)) u100))
            (share-to-kryptomind (/ (* remaining-stx (var-get percentage-kryptomind)) u100))
            (swapped-stone (try! (swap share-to-burn))) )

        (unwrap! (stx-transfer? share-to-progressive tx-sender (var-get PROGRESSIVE_WALLET)) ERR-TRANSFER-PROGRESSIVE)
        (asserts! (is-ok  (contract-call? 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                                    transfer
                                     swapped-stone tx-sender (var-get BURN_WALLET) none)) ERR-TRANSFER-BURN-WALLET)
        (unwrap! (stx-transfer? share-to-multisig tx-sender (var-get MULTISIG_WALLET)) ERR-TRANSFER-MULTISIG) 
        (unwrap! (stx-transfer? share-to-kryptomind tx-sender (var-get KRYPTOMIND)) ERR-TRANSFER-KRYPTOMIND)

        (var-set total-stx-swapped (+ (var-get total-stx-swapped) share-to-burn))
        (var-set total-stone-burned (+ (var-get total-stone-burned) swapped-stone))
        
        (let ((existing-hearts (get hearts (default-to {hearts: u0} (map-get? user-hearts {user: tx-sender})))))
          (map-set user-hearts {user: tx-sender} {hearts: (+ existing-hearts heart-count)}))
        (ok heart-count)))))

;; Enter contest

(define-public (enter-contest)
  (begin
    (asserts! (>= (stx-get-balance tx-sender) u100000) INSUFFICIENT-STX-TO-ENTER)
    (try! (stx-transfer? u100000 tx-sender (var-get POOL_WALLET)))
    (var-set progressive-pool (+ (var-get progressive-pool) u100000))
    (map-set user-contest-inventory tx-sender {hearts: u3, diamonds: u10})
    (ok {message: "Game entry successful", hearts: u3, diamonds: u10, pool: (var-get progressive-pool)})
  )
)



