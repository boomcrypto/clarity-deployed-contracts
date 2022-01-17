(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token wrapped-rewards)

(define-constant admin 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60)
(define-data-var reward-admin principal 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60)

(define-map rewards-by-height uint {wrew: uint, ustx: uint})

(define-data-var last-price (tuple (amount uint) (height uint) (timestamp uint))
  {amount: u2813, height: u23481, timestamp: u1627462508})

;; total submitted btc rewards
(define-read-only (get-rewards-by-height (height uint))
  (ok (default-to {wrew: u0, ustx: u0} (map-get? rewards-by-height height))))

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance wrapped-rewards owner)))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply wrapped-rewards)))

;; returns the token name
(define-read-only (get-name)
  (ok "Friedger Pool wrapped rewards"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FPWR"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? wrapped-rewards amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://pool.friedger.de/wrapped-rewards.json")))

;;
;; mint via admin
;;

(define-private (map-update-rewards-by-height (height uint) (wrew-value uint) (ustx-value uint))
  (let ((rewards (map-get? rewards-by-height height)))
    (let ((wrew (default-to u0 (get wrew rewards)))
        (ustx (default-to u0 (get ustx rewards))))
      (map-set rewards-by-height height {wrew: (+ wrew-value wrew), ustx: (+ ustx-value ustx)}))))

;; admin can submit a reward amount in sats at a stx block height and mint wrapped rewards
(define-public (mint (height uint) (value uint))
  (if (is-eq tx-sender admin)
    (begin
      (asserts! (> value u0) ERR_TX_IGNORED)
      (let ((ustx (/ (* value u1000000) (get-price height))))
        (asserts! (map-update-rewards-by-height height value ustx) ERR_NATIVE_FAILURE)
        (match (ft-mint? wrapped-rewards value (var-get reward-admin))
          success (ok {value: value, ustx: ustx})
          error (err (* error u1000)))))
  (err u403)))


(define-public (update-reward-admin (new-admin principal))
  (if (is-eq tx-sender (var-get reward-admin))
    (ok (var-set reward-admin new-admin))
    (err u403)))

;; price BTC/STX
(define-private (oracle-get-price)
  (contract-call? 'SPZ0RAC1EFTH949T4W2SYY6YBHJRMAF4ECT5A7DD.oracle-v1 get-price "artifix-binance" "STX-BTC")
)

(define-private (update (price (tuple (amount uint) (height uint) (timestamp uint))) (height uint))
  (if (> height (get height (var-get last-price)))
    (var-set last-price price)
    false))

(define-private (get-price-at-height (height uint))
  (match (get-block-info? id-header-hash height)
    hash (match (at-block hash (oracle-get-price))
          price (begin
                  (update price height)
                  (some (get amount price)))
          none)
    none))

(define-private (get-price (height uint))
  (match (get-price-at-height height)
    price price
    (match (get-price-at-height (- height u1))
      price-1 price-1
      (match (get-price-at-height (- height u2))
        price-2 price-2
        (get amount (print (var-get last-price)))))))

(define-public (get-price-stx-btc (height uint))
  (ok (get-price height)))

(define-constant ERR_TX_IGNORED (err u6))
(define-constant ERR_NATIVE_FAILURE (err u99))
