(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-INVALID-STAKE u104)
(define-constant ERR-NO-MORE-BANANAS u400)
(define-constant ERR-NAME-TAKEN u404)
(define-constant CONTRACT-OWNER tx-sender)

(define-data-var shutoff-valve bool false)
(define-data-var contract principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var vault principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
(define-data-var admins (list 1000 principal) (list 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C 'SP3ZJP253DENMN3CQFEQSPZWY7DK35EH3SEH0J8PK 'SP3S21WY0A8YQK9MSHVW4E4YYTSE696MSHKR6YTAN))
(define-data-var price uint u5000000)
(define-data-var burn-rate uint u0)

(define-map names uint (string-ascii 256))

(define-read-only (get-just-name (id uint))
    (unwrap-panic (map-get? names id))
)

(define-read-only (get-name (id uint))
    (ok (unwrap-panic (map-get? names id)))
)

(define-read-only (check-name (name (string-ascii 256)))
    (is-some (index-of (get-all-names) name))
)

(define-public (name-monkey (id uint) (name (string-ascii 256)))
    (let (
        (owner (unwrap-panic (contract-call? .bitcoin-monkeys get-owner id)))
        (staked-monkey (is-some (index-of (contract-call? .btc-monkeys-staking get-staked-nfts tx-sender) id)))
        (to-burn (/ (* (var-get price) (var-get burn-rate)) u10000))
        (to-vault (/ (* (var-get price) (- u10000 (var-get burn-rate))) u10000))
    )
        (asserts! (or staked-monkey (is-eq tx-sender (unwrap-panic owner))) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (check-name name) false) (err ERR-NAME-TAKEN))
        (if (> to-vault u0)
            (begin
                (if (> to-burn u0)
                (begin
                    (try! (contract-call? .btc-monkeys-bananas burn to-burn))
                    (try! (contract-call? .btc-monkeys-bananas transfer to-vault tx-sender (var-get vault) none))
                )
                (begin
                    (try! (contract-call? .btc-monkeys-bananas transfer to-vault tx-sender (var-get vault) none))
                )
                )
                (map-set names id name)
            )
            (begin
                (map-set names id name)
            )
        )
        (ok true)
    )
)

(define-public (admin-name (id uint) (name (string-ascii 256)))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (map-set names id name)
        (ok true)
    )
)

(define-public (bulk-admin-name (ids (list 2500 uint)) (name-list (list 2500 (string-ascii 256))))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (print (map admin-name ids name-list))
        (ok true)
    )
)

(define-read-only (get-names (ids (list 2500 uint)))
    (print (map get-just-name ids))
)

(define-read-only (get-all-names)
    (print (map get-just-name (contract-call? .id-list lookup)))
)

(define-public (change-price (amount uint))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (var-set price amount)
        (ok true)
    )
)

(define-read-only (get-price)
    (ok (var-get price))
)

(define-public (change-burn-rate (amount uint))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (var-set burn-rate amount)
        (ok true)
    )
)

(define-read-only (get-burn-rate)
    (ok (var-get burn-rate))
)

(define-public (principal-add (address principal))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set admins (unwrap-panic (as-max-len? (append (var-get admins) address) u1000))))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (change-vault (address principal))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (var-set vault address)
        (ok true)
    )
)

(define-public (change-contract (address principal))
    (begin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err ERR-NOT-AUTHORIZED))
        (var-set contract address)
        (ok true)
    )
)
