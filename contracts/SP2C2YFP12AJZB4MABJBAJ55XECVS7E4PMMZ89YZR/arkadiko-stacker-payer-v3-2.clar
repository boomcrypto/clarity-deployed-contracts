;; Implementation of Stacker Payer
;; which allows users to redeem xSTX for STX

(define-constant ERR-NOT-AUTHORIZED u22401)
(define-constant ERR-EMERGENCY-SHUTDOWN-ACTIVATED u221)
(define-constant ERR-VAULT-ALREADY-REDEEMED u222)
(define-constant ERR-AUCTION-RUNNING u223)
(define-constant ERR-WRONG-COLLATERAL u224)
(define-constant ERR-NOT-LIQUIDATED u225)

(define-data-var stacker-payer-shutdown-activated bool false)
(define-data-var stx-redeemable uint u45650000000)
(define-map vaults-redeemed { vault-id: uint } { redeemed: bool })

(define-read-only (get-stx-redeemable)
  (var-get stx-redeemable)
)

(define-read-only (has-stx-redeemable)
  (> (var-get stx-redeemable) u0)
)

(define-read-only (has-vault-redeemed (vault-id uint))
  (is-some (map-get? vaults-redeemed { vault-id: vault-id }))
)

(define-read-only (is-enabled)
  (and
    (not (unwrap-panic (contract-call? .arkadiko-dao get-emergency-shutdown-activated)))
    (not (var-get stacker-payer-shutdown-activated))
  )
)

(define-public (toggle-stacker-payer-shutdown)
  (begin
    (asserts! (is-eq tx-sender (contract-call? .arkadiko-dao get-guardian-address)) (err ERR-NOT-AUTHORIZED))

    (ok (var-set stacker-payer-shutdown-activated (not (var-get stacker-payer-shutdown-activated))))
  )
)

(define-public (return-stx-to-reserve (ustx-amount uint))
  (begin
    (asserts! (is-enabled) (err ERR-EMERGENCY-SHUTDOWN-ACTIVATED))

    (if (> ustx-amount u0)
      (as-contract
        (stx-transfer? ustx-amount tx-sender (unwrap-panic (contract-call? .arkadiko-dao get-qualified-name-by-name "stx-reserve")))
      )
      (ok true)
    )
  )
)

(define-public (set-stx-redeemable (ustx-amount uint))
  (let (
    (dao-address (contract-call? .arkadiko-dao get-dao-owner))
  )
    (asserts! (is-eq contract-caller dao-address) (err ERR-NOT-AUTHORIZED))

    (ok (var-set stx-redeemable ustx-amount))
  )
)

(define-public (add-stx-redeemable (auction-id uint))
  (let (
    (auction (contract-call? .arkadiko-auction-engine-v4-2 get-auction-by-id auction-id))
    (vault (contract-call? .arkadiko-vault-data-v1-1 get-vault-by-id (get vault-id auction)))
    (difference (if (> (get total-collateral-sold auction) (get stacked-tokens vault))
      (- (get total-collateral-sold auction) (get stacked-tokens vault))
      u0
    ))
  )
    (asserts! (not (has-vault-redeemed (get vault-id auction))) (err ERR-VAULT-ALREADY-REDEEMED))
    (asserts! (get auction-ended vault) (err ERR-AUCTION-RUNNING))
    (asserts! (get is-liquidated vault) (err ERR-NOT-LIQUIDATED))
    (asserts! (is-eq (get collateral-token vault) "xSTX") (err ERR-WRONG-COLLATERAL))

    (map-set vaults-redeemed { vault-id: (get vault-id auction) } { redeemed: true })
    (ok (var-set stx-redeemable (+ (var-get stx-redeemable) difference)))
  )
)

(define-public (redeem-stx (ustx-amount uint))
  (let (
    (sender tx-sender)
    (amount (min-of ustx-amount (var-get stx-redeemable)))
  )
    (asserts! (is-enabled) (err ERR-EMERGENCY-SHUTDOWN-ACTIVATED))
    (asserts! (> amount u0) (ok true))

    (try! (contract-call? .arkadiko-dao burn-token .xstx-token amount sender))
    (try! (contract-call? .arkadiko-stx-reserve-v1-1 request-stx-to-auto-payoff amount))
    (try! (as-contract (stx-transfer? amount tx-sender sender)))

    (ok (var-set stx-redeemable (- (var-get stx-redeemable) amount)))
  )
)

(define-read-only (get-stx-redeemable-helper)
  (let (
    (freddie-redeemable (unwrap-panic (contract-call? .arkadiko-freddie-v1-1 get-stx-redeemable)))
  )
    (+ freddie-redeemable (var-get stx-redeemable))
  )
)

(define-public (redeem-stx-helper (ustx-amount uint))
  (let (
    (freddie-total-redeemable (unwrap-panic (contract-call? .arkadiko-freddie-v1-1 get-stx-redeemable)))
  )
    (try! (contract-call? .arkadiko-freddie-v1-1 redeem-stx ustx-amount))

    (if (> ustx-amount freddie-total-redeemable)
      (redeem-stx (- ustx-amount freddie-total-redeemable))
      (ok true)
    )
  )
)

(define-public (release-stacked-stx (auction-id uint))
  (let (
    (auction (contract-call? .arkadiko-auction-engine-v4-2 get-auction-by-id auction-id))
  )
    (try! (contract-call? .arkadiko-freddie-v1-1 release-stacked-stx (get vault-id auction)))
    (try! (add-stx-redeemable auction-id))

    (ok true)
  )
)

(define-private (min-of (i1 uint) (i2 uint))
  (if (< i1 i2)
      i1
      i2))


;; Initialization
(begin
  (map-set vaults-redeemed { vault-id: u409 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u675 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u794 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1748 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1199 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1381 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1610 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u589 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u29 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2048 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2092 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1741 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1775 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1749 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2012 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1856 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1711 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1270 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u52 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u39 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1655 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1494 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u667 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u981 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1174 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u635 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u711 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u806 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u683 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1219 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u142 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1207 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1190 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1137 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1141 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u825 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1188 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1283 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1273 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1438 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1618 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1702 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2032 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1633 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1282 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1924 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1863 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1811 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1617 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1510 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1499 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1490 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1473 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1448 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1411 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1394 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1272 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1135 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1120 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1107 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1091 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1074 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1073 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1067 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1001 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u943 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u922 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u903 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u869 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u857 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u835 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u807 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u791 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u787 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u780 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u778 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u763 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u752 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u748 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u732 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u709 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u631 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u561 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u559 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u555 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u551 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u544 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u509 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u497 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u493 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u475 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u447 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u445 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u437 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u422 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u418 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u407 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u391 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u381 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u371 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u364 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u221 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u204 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u187 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u146 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u110 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u109 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u420 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1077 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u85 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u83 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u51 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2074 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2065 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1870 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1869 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1840 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1824 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1751 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1736 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1689 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1678 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1627 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1548 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1536 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1512 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1480 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1479 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1442 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1425 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1383 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1361 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1294 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1259 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1220 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1211 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1114 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1084 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u955 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u924 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u892 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u890 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u865 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u842 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u826 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u809 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u743 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u678 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u660 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u650 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u649 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u619 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u577 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u573 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u563 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u560 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u552 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u517 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u512 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u504 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u495 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u490 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u483 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u489 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1931 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1750 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1699 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1247 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1116 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1095 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1039 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u441 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u408 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u375 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u348 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u339 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u321 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u319 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u310 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u267 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u253 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u248 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u206 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u179 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u151 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u41 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1612 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1941 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1854 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1835 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1553 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1537 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1457 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2045 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1980 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1936 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1567 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1321 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1291 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1258 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1251 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1089 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u982 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u919 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u698 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u398 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u312 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u302 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u277 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u249 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2087 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1969 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1935 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1843 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1842 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1837 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1804 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1787 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1755 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1718 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1700 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1603 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1602 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1599 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1522 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1509 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1298 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1239 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u911 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u714 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u684 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u597 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u584 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u283 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u374 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2041 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1922 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1913 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1912 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1482 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1380 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1165 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u966 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u630 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u388 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u365 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u357 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2005 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1921 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1918 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1846 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1836 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1709 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1319 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1063 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u893 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u766 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u677 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u651 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u642 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u634 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u626 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u515 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u414 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u373 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u177 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2108 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2042 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2014 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2006 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1987 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1959 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1950 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1929 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1925 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1801 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1800 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1770 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1756 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1664 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1650 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1609 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1508 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1365 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1357 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1285 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1284 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1268 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1209 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1133 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1085 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u953 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u947 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u878 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u802 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u629 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u628 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u605 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2112 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2078 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u2077 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1983 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1853 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1766 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1759 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1686 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1566 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u907 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u884 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u639 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u591 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u521 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u465 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u457 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u442 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u395 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u361 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u360 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u353 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u309 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u296 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u294 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u163 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u34 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u31 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u26 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1157 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1131 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u182 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u1562 } { redeemed: true })
  (map-set vaults-redeemed { vault-id: u819 } { redeemed: true })
)