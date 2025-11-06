;; ========================================================
;; Stone-Burst Contract - All Audit Fixes Implemented
;; ========================================================


;; =======================
;; Error & Constant Codes
;; =======================
(define-constant ERR-NOT-AUTHORIZED          (err u401))
(define-constant INVALID-GEMS-COUNT          (err u403))
(define-constant INVALID-STX-BALANCE         (err u404))
(define-constant ERR-TRANSFER-KRYPTOMIND     (err u407))
(define-constant INVALID-HEART-COUNT         (err u409))
(define-constant ERR-ENTER-NEW-WALLET        (err u501))
(define-constant ERR-STX-LIMIT-EXCEEDED      (err u504))

;; Max STX amounts for hearts/gems
(define-constant MAX-STX-HEARTS u4000000)
(define-constant MAX-STX-GEMS   u1000000)

;; ==========================
;; Public Wallet Variables
;; ==========================
(define-data-var KRYPTOMIND            principal 'SP2RVTWWBB5KYFY2F0G4V054FETC6R5Q12ZCZ6QCC)

(define-data-var kryptomind-pool    uint u0)
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

(define-public (set-kryptomind-wallet (new-wallet principal))
  (begin
    (try! (check-is-owner))
    (asserts! (not (is-eq new-wallet (var-get KRYPTOMIND))) ERR-ENTER-NEW-WALLET)
    (var-set KRYPTOMIND new-wallet)
    (ok new-wallet)
  )
)




;; ==========================
;; Getter Functions
;; ==========================
(define-read-only (get-kryptomind-wallet)    (ok (var-get KRYPTOMIND)))
(define-read-only (get-contract-owner)       (ok (var-get contract-owner)))
(define-read-only (get-kryptomind-pool-balance)
  (var-get kryptomind-pool))

(define-read-only (get-user-contest-inventory (user principal))
  (map-get? user-contest-inventory user))

(define-read-only (get-user-gems (user principal))
  (ok (default-to {gems: u0} (map-get? user-gems {user: user}))))

(define-read-only (get-user-hearts (user principal))
  (ok (default-to {hearts: u0} (map-get? user-hearts {user: user}))))


;; ========================================
;; Purchase Gems - Uses Slippage
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

      
              ;; kryptomind stx
              (unwrap! (stx-transfer? required-stx tx-sender (var-get KRYPTOMIND))
                       ERR-TRANSFER-KRYPTOMIND)

              ;; update user gems
             (var-set kryptomind-pool (+ (var-get kryptomind-pool) required-stx))

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
                       kryptomind-share: required-stx,
                       }))
                (print ev)
                (ok ev)
              )
            )
          )
        )

;; ========================================
;; Purchase Hearts - Uses Slippage
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

          
          ;; kryptomind
          (unwrap! (stx-transfer? required-stx tx-sender (var-get KRYPTOMIND))
                   ERR-TRANSFER-KRYPTOMIND)
          (var-set kryptomind-pool (+ (var-get kryptomind-pool) required-stx))

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
                   kryptomind-share: required-stx,
                   }))
            (print ev)
            (ok ev)
          )
        )
      )
    )
;;   )
;; )

;; ========================================
;; Enter Contest
;; [CHANGED FOR AUDIT-FIX: HI-01]
;; -> Add items to existing inventory instead of overwriting
;; ========================================
(define-public (enter-contest)
  (begin
    (asserts! (>= (stx-get-balance tx-sender) u200000) INVALID-STX-BALANCE)
    (unwrap! (stx-transfer? u200000 tx-sender (var-get KRYPTOMIND))
             ERR-TRANSFER-KRYPTOMIND)
    (var-set kryptomind-pool (+ (var-get kryptomind-pool) u200000))

    ;; [HI-01 FIX] Instead of overwriting hearts/gems to (3, 10), we add them.
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
      (map-set user-gems {user: tx-sender} {gems: (+ old-gems u10)})
      (map-set user-hearts {user: tx-sender} {hearts: (+ old-hearts u3)})

      ;; also update the contest-inventory
      (map-set user-contest-inventory tx-sender
        {hearts: (+ (get hearts old-contest) u3),
         gems:   (+ (get gems   old-contest) u10)})

      (let ((ev
              {op: "enter-contest",
               user: tx-sender,
               hearts-gained: u3,
               gems-gained: u10,
               total-pool: (var-get kryptomind-pool)}))
        (print ev)
        (ok ev)
      )
    )
  )
)
