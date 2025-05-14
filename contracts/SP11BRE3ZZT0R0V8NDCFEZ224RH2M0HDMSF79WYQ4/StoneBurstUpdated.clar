
;; =======================
;; Error & Constant Codes
;; =======================
(define-constant ERR-NOT-AUTHORIZED          (err u401))
(define-constant ERR-INSUFFICIENT-FUNDS      (err u402))
(define-constant INVALID-GEMS-COUNT          (err u403))
(define-constant INVALID-STX-BALANCE         (err u404))
(define-constant ERR-TRANSFER-MULTISIG       (err u405))
(define-constant ERR-TRANSFER-PROGRESSIVE    (err u406))
(define-constant ERR-TRANSFER-KRYPTOMIND     (err u407))
(define-constant ERR-TRANSFER-BURN-WALLET    (err u408))
(define-constant INVALID-HEART-COUNT         (err u409))
(define-constant ERR-ENTER-NEW-WALLET        (err u501))
(define-constant ERR-SAME-PERCENTAGE         (err u502))
(define-constant ERR-SWAP-FAILED             (err u503))
(define-constant ERR-STX-LIMIT-EXCEEDED      (err u504)) 
(define-constant ERR-INVALID-DISTRIBUTION    (err u505))
(define-constant ERR-INVALID-POOL             (err u600))
(define-constant ERR-INVALID-PERCENTAGE        (err u601))
(define-constant INVALID-SLIPPAGE-PERCENTAGE    (err u602))
(define-constant HUNDRED-PERCENT u10000)

;; Max STX amounts for hearts/gems
(define-constant MAX-STX-HEARTS u4000000)
(define-constant MAX-STX-GEMS   u1000000)


;; ===========================================
;; Public Variables - All Using 10000 Scaling
;; ===========================================
(define-data-var percentage-progressive  uint u1000)
(define-data-var percentage-burn        uint u8000)     ;;  80%
(define-data-var percentage-kryptomind  uint u2000)   ;; 20.00%
(define-data-var stx-stone-pool-id uint u79)
;; The slippage tolerance (e.g. 2% => user won't accept final < 98% of expected)
(define-data-var slippage-percent uint u200)
(define-data-var swap-fee
  (tuple (num uint) (den uint))
  (tuple (num u997) (den u1000))) ;; default to 0.3% (997/1000)

;; ==========================
;; Public Wallet Variables
;; ==========================
(define-data-var KRYPTOMIND            principal 'SP2RVTWWBB5KYFY2F0G4V054FETC6R5Q12ZCZ6QCC)
(define-data-var BURN_WALLET           principal 'SP000000000000000000002Q6VF78)
(define-data-var PROGRESSIVE_WALLET    principal 'SP2HYW9F9YXEE8ACZ7PE268VB7QME0JDJJVDPHFS5)

;; ==========================
;; Other Public Variables
;; ==========================
(define-data-var total-stx-swapped   uint u0)
(define-data-var total-stone-burned  uint u0)
(define-data-var progressive-pool    uint u0)
(define-data-var contract-owner      principal tx-sender)

;; ==================
;; Maps
;; ==================
(define-map user-gems   {user: principal} {gems: uint})
(define-map user-hearts {user: principal} {hearts: uint})
(define-map user-contest-inventory principal {hearts: uint, gems: uint})

;; ==========================================
;; Private Helper: Ownership Check
;; ==========================================
(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

;; ==========================================
;; Private: get-stx-stone-out
;; - calls univ2-core::get-pool(...) then
;;   univ2-library::get-amount-out(...)
;;   to determine the "expected" STONE
;; ==========================================
(define-private (get-stx-stone-out (stx-amount uint))
  (begin
    (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)
    (let ((my-pool-id (var-get stx-stone-pool-id)))
      (let ((maybe-pool
              (contract-call?
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
                get-pool
                my-pool-id)))
        (asserts! (is-some maybe-pool) ERR-INVALID-POOL)  ;; pool not found
        (let (
          (pool-data (unwrap-panic maybe-pool))
          (r0 (get reserve0 pool-data))
          (r1 (get reserve1 pool-data))
          (fee (var-get swap-fee))
        )
          (let ((out-result
                  (contract-call?
                    'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library
                    get-amount-out
                    stx-amount
                    r0
                    r1
                    fee  ;; 0.3% swap fee
                  )))
            (asserts! (is-ok out-result) ERR-SWAP-FAILED)
            (let ((val (unwrap! out-result ERR-SWAP-FAILED)))
              (ok val)
            )
          )
        )
      )
    )
  )
)

(define-private (swap-with-slippage (stx-amount uint))
  (begin
    (asserts! (> stx-amount u0) ERR-INSUFFICIENT-FUNDS)
    (let (
      (maybe-expected (get-stx-stone-out stx-amount))
    )
      (asserts! (is-ok maybe-expected) ERR-SWAP-FAILED)
      (let ((expected-stone (unwrap! maybe-expected ERR-SWAP-FAILED)))
        (let ((slip (var-get slippage-percent)))
          ;; e.g. 2% => keep at least 98% of expected
          (let ((min-out (/ (* expected-stone (- u10000 slip)) u10000)))
            (let (
              (router-call
                (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
                  swap-exact-tokens-for-tokens
                  (var-get stx-stone-pool-id)
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                  'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                  'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
                  stx-amount
                  min-out
                ))
            )
              (asserts! (is-ok router-call) ERR-SWAP-FAILED)
              (let ((swap-event (unwrap! router-call ERR-SWAP-FAILED)))
                (ok (get amt-out swap-event))
              )
            )
          )
        )
      )
    )
  )
)

;; ==========================================
;; Setter Functions (Ownership Required)
;; ==========================================

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq owner (var-get contract-owner))) ERR-ENTER-NEW-WALLET)
    (var-set contract-owner owner)
    (ok owner)
  )
)
(define-public (set-percentage-progressive (new-perc uint))
  (begin
    (try! (check-is-owner))
    (asserts! (< new-perc HUNDRED-PERCENT) ERR-INVALID-PERCENTAGE) ;; must be < 100%
    (var-set percentage-progressive new-perc)
    (ok new-perc)
  )
)
(define-public (set-secondary-percentages
                (new-burn uint)
                (new-kryptomind uint))
  (begin
    (try! (check-is-owner))  ;; ensure only contract-owner can call
    (asserts!
      (is-eq (+ new-burn new-kryptomind) u10000)
      ERR-INVALID-DISTRIBUTION)
    (asserts! (> new-burn u0) ERR-INVALID-PERCENTAGE) ;; ensure burn > 0
    
    ;;(var-set percentage-multisig new-multisig)
    (var-set percentage-burn new-burn)
    (var-set percentage-kryptomind new-kryptomind)
    (ok { burn: new-burn, krypto: new-kryptomind})
  )
)

(define-public (set-kryptomind-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get KRYPTOMIND))) ERR-ENTER-NEW-WALLET)
    (var-set KRYPTOMIND new-wallet)
    (ok new-wallet)
  )
)

(define-public (set-burn-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get BURN_WALLET)))  ERR-ENTER-NEW-WALLET)
    (var-set BURN_WALLET new-wallet)
    (ok new-wallet)
  )
)

(define-public (set-progressive-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get PROGRESSIVE_WALLET)))  ERR-ENTER-NEW-WALLET)
    (var-set PROGRESSIVE_WALLET new-wallet)
    (ok new-wallet)
  )
)

(define-public (set-slippage-percent (new-slippage uint))
  (begin
    (try! (check-is-owner))
    ;; e.g. limit slippage to <= 5% 
    (asserts! (<= new-slippage u500) INVALID-SLIPPAGE-PERCENTAGE) 
    (var-set slippage-percent new-slippage)
    (ok new-slippage)
  )
)

(define-public (set-stx-stone-pool-id (new-pool-id uint))
  (begin
    (try! (check-is-owner))
    (var-set stx-stone-pool-id new-pool-id)
    (ok new-pool-id)
  )
)
(define-public (set-swap-fee (new-num uint) (new-den uint))
  (begin
    (try! (check-is-owner))   
    (var-set swap-fee (tuple (num new-num) (den new-den)))
    (ok (var-get swap-fee))
  )
)




;; ==========================
;; Getter Functions
;; ==========================
(define-read-only (get-kryptomind-wallet)    (ok (var-get KRYPTOMIND)))
(define-read-only (get-burn-wallet)          (ok (var-get BURN_WALLET)))
(define-read-only (get-progressive-wallet)   (ok (var-get PROGRESSIVE_WALLET)))
(define-read-only (get-contract-owner)       (ok (var-get contract-owner)))
(define-read-only (get-total-stx-swapped)    (ok (var-get total-stx-swapped)))
(define-read-only (get-total-stone-burned)   (ok (var-get total-stone-burned)))
(define-read-only (get-swap-fee)             (ok (var-get swap-fee))
)
(define-read-only (get-progressive-pool-balance)
  (var-get progressive-pool))

(define-read-only (get-percentage-progressive)
  (ok (var-get percentage-progressive)))

(define-read-only (get-percentage-burn)
  (ok (var-get percentage-burn)))

(define-read-only (get-percentage-kryptomind)
  (ok (var-get percentage-kryptomind)))

(define-read-only (get-user-contest-inventory (user principal))
  (map-get? user-contest-inventory user))

(define-read-only (get-user-gems (user principal))
  (ok (default-to {gems: u0} (map-get? user-gems {user: user}))))

(define-read-only (get-user-hearts (user principal))
  (ok (default-to {hearts: u0} (map-get? user-hearts {user: user}))))

;; [Getter for slippage & pool-id]
(define-read-only (get-slippage-percent)
  (ok (var-get slippage-percent)))

(define-read-only (get-stx-stone-pool-id)
  (ok (var-get stx-stone-pool-id)))

;; ========================================
;; Purchase Gems
;; ========================================
(define-public (buy-gems (gems-count uint))
  (begin
    ;; Validate gem bundles
    (asserts!
      (or (is-eq gems-count u5)
          (is-eq gems-count u25)
          (is-eq gems-count u50)
          (is-eq gems-count u100))
      INVALID-GEMS-COUNT)

     ;; Determine required STX
    (let ((required-stx
            (if (is-eq gems-count u5)
                u200000
                (if (is-eq gems-count u25)
                    u400000
                    (if (is-eq gems-count u50)
                        u700000
                        (if (is-eq gems-count u100)
                            u1000000
                            u0))))))
      (asserts! (>= (stx-get-balance tx-sender) required-stx) INVALID-STX-BALANCE)
      (asserts! (<= required-stx MAX-STX-GEMS) ERR-STX-LIMIT-EXCEEDED)

      ;; 1) Progressive share
      (let ((share-progressive
              (/ (* required-stx (var-get percentage-progressive)) HUNDRED-PERCENT))
            (leftover 0))
        (let ((temp-rem (- required-stx share-progressive)))
          ;; 2) leftover distribution for [multisig, burn, kryptomind]
          (let (
            (share-burn
              (/ (* temp-rem (var-get percentage-burn)) HUNDRED-PERCENT))
            (share-krypto
              (/ (* temp-rem (var-get percentage-kryptomind)) HUNDRED-PERCENT))
          )
            ;; 3) Swap portion (burn)
            (let ((swapped-stone (unwrap! (swap-with-slippage share-burn) ERR-SWAP-FAILED)))
              
              ;; progressive stx
              (unwrap! (stx-transfer? share-progressive tx-sender (var-get PROGRESSIVE_WALLET))
                       ERR-TRANSFER-PROGRESSIVE)

              ;; swapped stone -> burn wallet
              (asserts!
                (is-ok (contract-call?
                         'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                         transfer
                         swapped-stone
                         tx-sender
                         (var-get BURN_WALLET)
                         none))
                ERR-TRANSFER-BURN-WALLET)
              ;; kryptomind stx
              (unwrap! (stx-transfer? share-krypto tx-sender (var-get KRYPTOMIND))
                       ERR-TRANSFER-KRYPTOMIND)

              ;; track totals
              (var-set total-stx-swapped (+ (var-get total-stx-swapped) share-burn))
              (var-set total-stone-burned (+ (var-get total-stone-burned) swapped-stone))

              ;; update user gems
              (map-set user-gems {user: tx-sender}
                {gems: (+ (get gems (default-to {gems: u0}
                                       (map-get? user-gems {user: tx-sender})))
                          gems-count)})

              ;; event
              (let ((ev
                      {op: "buy-gems",
                       user: tx-sender,
                       gems-count: gems-count,
                       required-stx: required-stx,
                       progressive-share: share-progressive,
                       burn-share: share-burn,
                       kryptomind-share: share-krypto,
                       swapped-stone: swapped-stone}))
                (print ev)
                (ok ev)
              )
            )
          )
        )
      )
    )
  )
)

;; ========================================
;; Purchase Hearts
;; ========================================
(define-public (buy-hearts (heart-count uint))
  (begin
    (asserts!
      (or (is-eq heart-count u3)
          (is-eq heart-count u10)
          (is-eq heart-count u25)
          (is-eq heart-count u50))
      INVALID-HEART-COUNT)

    (let ((required-stx
            (if (is-eq heart-count u3)
                u1000000
                (if (is-eq heart-count u10)
                    u2000000
                    (if (is-eq heart-count u25)
                        u3000000
                        (if (is-eq heart-count u50)
                            u4000000
                            u0))))))
      (asserts! (>= (stx-get-balance tx-sender) required-stx) INVALID-STX-BALANCE)
      (asserts! (<= required-stx MAX-STX-HEARTS) ERR-STX-LIMIT-EXCEEDED)

      (let (
        (share-progressive
          (/ (* required-stx (var-get percentage-progressive)) HUNDRED-PERCENT))
        (temp-rem (- required-stx share-progressive))

        (share-burn
          (/ (* temp-rem (var-get percentage-burn)) HUNDRED-PERCENT))
        (share-krypto
          (/ (* temp-rem (var-get percentage-kryptomind)) HUNDRED-PERCENT))
      )
        (let ((swapped-stone (unwrap! (swap-with-slippage share-burn) ERR-SWAP-FAILED)))
          ;; progressive stx
          (unwrap! (stx-transfer? share-progressive tx-sender (var-get PROGRESSIVE_WALLET))
                   ERR-TRANSFER-PROGRESSIVE)
          
          ;; stone -> burn
          (asserts!
            (is-ok (contract-call?
                     'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve
                     transfer
                     swapped-stone
                     tx-sender
                     (var-get BURN_WALLET)
                     none))
            ERR-TRANSFER-BURN-WALLET)
          
          ;; kryptomind
          (unwrap! (stx-transfer? share-krypto tx-sender (var-get KRYPTOMIND))
                   ERR-TRANSFER-KRYPTOMIND)
          
          (var-set total-stx-swapped (+ (var-get total-stx-swapped) share-burn))
          (var-set total-stone-burned (+ (var-get total-stone-burned) swapped-stone))
          
          ;; update user hearts
          (let ((old-hearts
                  (get hearts (default-to {hearts: u0}
                            (map-get? user-hearts {user: tx-sender})))))
            (map-set user-hearts {user: tx-sender}
                     {hearts: (+ old-hearts heart-count)}))
          
          ;; event
          (let ((ev
                  {op: "buy-hearts",
                   user: tx-sender,
                   heart-count: heart-count,
                   required-stx: required-stx,
                   progressive-share: share-progressive,
                   burn-share: share-burn,
                   kryptomind-share: share-krypto,
                   swapped-stone: swapped-stone}))
            (print ev)
            (ok ev)
          )
        )
      )
    )
  )
)

(define-public (enter-contest)
  (begin
    (asserts! (>= (stx-get-balance tx-sender) u500000) INVALID-STX-BALANCE)
    (unwrap! (stx-transfer? u500000 tx-sender (var-get PROGRESSIVE_WALLET))
             ERR-TRANSFER-PROGRESSIVE)
    (var-set progressive-pool (+ (var-get progressive-pool) u500000))
    (let (
      (old-gems
        (get gems (default-to {gems: u0}
                  (map-get? user-gems {user: tx-sender}))))
      (old-hearts
        (get hearts (default-to {hearts: u0}
                  (map-get? user-hearts {user: tx-sender}))))
      (old-contest
        (default-to {hearts: u0, gems: u0}
                    (map-get? user-contest-inventory tx-sender)))
    )
      ;; new totals
      (map-set user-gems {user: tx-sender} {gems: (+ old-gems u75)})
      (map-set user-hearts {user: tx-sender} {hearts: (+ old-hearts u5)})

      ;; also update the contest-inventory
      (map-set user-contest-inventory tx-sender
        {hearts: (+ (get hearts old-contest) u5),
         gems:   (+ (get gems   old-contest) u75)})

      (let ((ev
              {op: "enter-contest",
               user: tx-sender,
               hearts-gained: u5,
               gems-gained: u75,
               total-pool: (var-get progressive-pool)}))
        (print ev)
        (ok ev)
      )
    )
  )
)
