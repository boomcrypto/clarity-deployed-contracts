(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NO-LEVEL (err u404))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-LISTED (err u500))

(define-data-var admins (list 1000 principal) (list 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S tx-sender))
(define-map upgrade-costs uint uint)
(define-map mutant-levels uint uint)
(define-map mutant-level-counts uint uint)

(define-public (upgrade (id uint) (target-level uint))
  (let 
    (
      (current-level (default-to u1 (map-get? mutant-levels id)))
      (current-level-count (default-to u0 (map-get? mutant-level-counts current-level)))
      (target-level-count (default-to u0 (map-get? mutant-level-counts target-level)))
    )
    (asserts! (<= target-level u5) ERR-NO-LEVEL)
    (asserts! (> target-level current-level) ERR-NO-LEVEL)
    (asserts! (and (<= id u5000) (>= id u1)) ERR-NOT-FOUND)
    (asserts! (is-none (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys get-listing-in-ustx id)) ERR-LISTED)
    (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token burn (get-cost-to-upgrade-mutant id target-level)))
    (map-set mutant-level-counts current-level (- current-level-count u1))
    (map-set mutant-level-counts target-level (+ target-level-count u1))
    (ok (map-set mutant-levels id target-level))
  )
)

(define-read-only (get-mutant-level (id uint))
  (default-to u1 (map-get? mutant-levels id))
)

(define-read-only (get-count-of-mutants-at-level (level uint))
  (default-to u0 (map-get? mutant-level-counts level))
)

(define-read-only (get-cost-to-upgrade (current-level uint) (target-level uint))
  (+
    (if (and (< current-level u2) (>= target-level u2))
        (default-to u50 (map-get? upgrade-costs u2)) u0)
    (if (and (< current-level u3) (>= target-level u3))
        (default-to u100 (map-get? upgrade-costs u3)) u0)
    (if (and (< current-level u4) (>= target-level u4))
        (default-to u150 (map-get? upgrade-costs u4)) u0)
    (if (and (< current-level u5) (>= target-level u5))
        (default-to u225 (map-get? upgrade-costs u5)) u0)
  )
)

(define-read-only (get-cost-to-upgrade-mutant (id uint) (target-level uint))
  (get-cost-to-upgrade (default-to u1 (map-get? mutant-levels id)) target-level)
)

(define-public (add-admin (addr principal))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (ok (var-set admins (unwrap-panic (as-max-len? (append (var-get admins) addr) u1000))))
  )
)

(define-public (set-upgrade-cost (level uint) (cost uint))
  (begin
    (asserts! (is-some (index-of (var-get admins) tx-sender)) ERR-NOT-AUTHORIZED)
    (ok (map-set upgrade-costs level cost))
  )
)

(define-read-only (get-admins)
  (ok (var-get admins))
)

(map-set upgrade-costs u2 u50000000)
(map-set upgrade-costs u3 u100000000)
(map-set upgrade-costs u4 u150000000)
(map-set upgrade-costs u5 u225000000)

(map-set mutant-level-counts u1 u5000)