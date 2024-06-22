(use-trait asset-wrapper-trait .traits.asset-wrapper-trait)
(use-trait block-height-provider-trait .traits.block-height-provider-trait)
(use-trait pair-logic-trait .traits.pair-logic-trait)

(define-constant PRECISION (pow u10 u18))
(define-constant MAX_RESERVE (- (pow u2 u64) u1))

(define-constant err-overflow (err u9991))
(define-constant err-slippage (err u9992))
(define-constant err-not-owner (err u9993))
(define-constant err-not-fee-to (err u9994))
(define-constant err-fee-too-high (err u9995))
(define-constant err-same-token (err u9996))
(define-constant err-wrong-block-height-provider (err u9997))
(define-constant err-block-height-provider-immutable (err u9998))
(define-constant err-invalid-args (err u9999))

(define-data-var num-pairs uint u0)

(define-data-var contract-owner principal tx-sender)
(define-data-var fee-to principal tx-sender)
(define-data-var block-height-provider-update-count uint u1)
(define-data-var global-params {pfee: uint, fee: uint, block-height-provider: principal} {pfee: u5000, fee: u30, block-height-provider: .tenure-provider})
(define-map protocol-fees-accrued principal uint)
(define-map pair-tokens
  uint
  {
    t0: principal,
    t1: principal,
    logic: principal,
  }
)

(define-map pairs {t0: principal, t1: principal, logic: principal}
  {
    id: uint,
    r0: uint,
    r1: uint,
    rlp: uint,
    fee: (optional uint),
    pfee: (optional uint),
    emission-per-share-1e18: uint,
    last-emission-update: uint,
  }
)

(define-map user-lp-info {pair-id: uint, user: principal} {balance: uint, emission: uint, last-emission-snapshot: uint})

(define-private (principal-less-than (a principal) (b principal))
  (let
    ((a-d (principal-destruct? a))
     (a- (match a-d x x x x))
     (b-d (principal-destruct? b))
     (b- (match b-d x x x x)))
    (if (not (is-eq (get version a-) (get version b-)))
      (< (get version a-) (get version b-))
      (if (not (is-eq (get hash-bytes a-) (get hash-bytes b-)))
        (< (get hash-bytes a-) (get hash-bytes b-))
        (if (and (is-some (get name a-)) (is-some (get name b-)))
          (< (unwrap-panic (get name a-)) (unwrap-panic (get name b-)))
          (is-none (get name a-)))))))

(define-private (muldiv (a uint) (b uint) (c uint))
(let 
  ((k (/ a c))
   (r (mod a c))
   (k- (/ b c))
   (r- (mod b c)))
  (+ (* c k k-) (* k r-) (* k- r) (/ (* r r-) c))))

(define-public (claim-protocol-fee (token <asset-wrapper-trait>))
  (let
    ((amount (get-protocol-fee (contract-of token))))
    (try! (is-contract-owner))
    (try! (transfer-out token amount (var-get fee-to)))
    (map-set protocol-fees-accrued (contract-of token) u0)
    (ok amount)))

(define-public (set-contract-owner (new-owner principal))
    (begin
        (try! (is-contract-owner))
        (ok (var-set contract-owner new-owner))))

(define-public (set-fee-to (new-fee-to principal))
    (begin
        (try! (is-contract-owner))
        (ok (var-set fee-to new-fee-to))))

(define-public (set-default-fee (new-fee uint))
    (begin
        (try! (is-contract-owner))
        (asserts! (<= new-fee u1000) err-fee-too-high)
        (var-set global-params (merge (var-get global-params) {fee: new-fee}))
        (print {event: "default-fee-change", value: new-fee})
        (ok true)))

(define-public (set-pair-fee (t0 principal) (t1 principal) (pair-logic principal) (new-fee (optional uint)))
  (let
    ((correct-order (principal-less-than t0 t1))
     (t0- (if correct-order t0 t1))
     (t1- (if correct-order t1 t0))
     (pair (unwrap-panic (map-get? pairs {t0: t0-, t1: t1-, logic: pair-logic}))))
    (try! (is-contract-owner))
    (asserts! (match new-fee x (<= x u1000) true) err-fee-too-high)
    (map-set pairs {t0: t0-, t1: t1-, logic: pair-logic}
      (merge pair {fee: new-fee}))
    (print (merge pair {event: "fee-change", fee: new-fee}))
    (ok true)))

(define-public (set-pair-protocol-fee (t0 principal) (t1 principal) (pair-logic principal) (new-fee (optional uint)))
  (let
    ((correct-order (principal-less-than t0 t1))
     (t0- (if correct-order t0 t1))
     (t1- (if correct-order t1 t0))
     (pair (unwrap-panic (map-get? pairs {t0: t0-, t1: t1-, logic: pair-logic}))))
    (try! (is-contract-owner))
    (asserts! (match new-fee x (<= x u7000) true) err-fee-too-high)
    (map-set pairs {t0: t0-, t1: t1-, logic: pair-logic}
      (merge pair {pfee: new-fee}))
    (print (merge pair {event: "pfee-change", fee: new-fee}))
    (ok true)))

(define-public (set-default-protocol-fee (new-fee uint))
    (begin
        (try! (is-contract-owner))
        (asserts! (<= new-fee u7000) err-fee-too-high)
        (var-set global-params (merge (var-get global-params) {pfee: new-fee}))
        (print {event: "default-pfee-change", value: new-fee})
        (ok true)))

(define-public (set-block-height-provider (new-provider <block-height-provider-trait>))
    (begin
        (try! (is-contract-owner))
        (asserts! (< (var-get block-height-provider-update-count) u2) err-block-height-provider-immutable)
        (var-set block-height-provider-update-count (+ u1 (var-get block-height-provider-update-count)))
        (var-set global-params (merge (var-get global-params) {block-height-provider: (contract-of new-provider)}))
        (ok true)))

(define-public (add-liquidity (block-height-provider <block-height-provider-trait>) (t0-trait <asset-wrapper-trait>) (t1-trait <asset-wrapper-trait>) (pair-logic <pair-logic-trait>) (amount-t0-desired uint) (amount-t1-desired uint) (amount-lp-min uint))
  (let
    ((t0 (contract-of t0-trait))
     (t1 (contract-of t1-trait))
     (d0 (try! (transfer-in t0-trait amount-t0-desired)))
     (d1 (try! (transfer-in t1-trait amount-t1-desired)))
     (current-block (try! (contract-call? block-height-provider get-block-height)))
     (pair (update-emission current-block (try! (initialize-pair t0 t1 (contract-of pair-logic)))))
     (global (var-get global-params))
     (r0 (get r0 pair))
     (r1 (get r1 pair))
     (rlp (get rlp pair))
     (fee (default-to (get fee global) (get fee pair)))
     (pfee (default-to (get pfee global) (get pfee pair)))
     (dlp-without-fee (try! (contract-call? pair-logic join t0 t1 r0 r1 rlp d0 d1)))
     (immediate-withdraw (try! (contract-call? pair-logic exit t0 t1 (+ r0 d0) (+ r1 d1) (+ rlp dlp-without-fee) dlp-without-fee)))
     (iw0 (get amount0 immediate-withdraw))
     (iw1 (get amount1 immediate-withdraw))
     (fee0 (if (> iw0 d0) u0 (div-ceil (* fee (- d0 iw0)) u10000)))
     (fee1 (if (> iw1 d1) u0 (div-ceil (* fee (- d1 iw1)) u10000)))
     (pfee0 (div-ceil (* fee0 pfee) u10000))
     (pfee1 (div-ceil (* fee1 pfee) u10000))
     (dlp (try! (contract-call? pair-logic join t0 t1 (+ r0 (- fee0 pfee0)) (+ r1 (- fee1 pfee1)) rlp (- d0 fee0) (- d1 fee1)))))
    (asserts! (is-eq (contract-of block-height-provider) (get block-height-provider global)) err-wrong-block-height-provider)
    (asserts! (>= dlp amount-lp-min) err-slippage)
    (credit-protocol-fee t0 pfee0)
    (credit-protocol-fee t1 pfee1)
    (change-user-lp pair tx-sender (to-int dlp))
    (try! (change-reserve pair t0 t1 (contract-of pair-logic) (to-int (- d0 pfee0)) (to-int (- d1 pfee1)) (to-int dlp)))
    (print {event: "join", maker: tx-sender, pair-id: (get id pair), t0: t0, t1: t1, logic: (contract-of pair-logic), d0: d0, d1: d1, dlp: dlp, fee0: (- fee0 pfee0), fee1: (- fee1 pfee1), pfee0: pfee0, pfee1: pfee1})
    (ok dlp)))

(define-public (remove-liquidity (block-height-provider <block-height-provider-trait>) (t0-trait <asset-wrapper-trait>) (t1-trait <asset-wrapper-trait>) (pair-logic <pair-logic-trait>) (amount-lp uint) (amount-t0-min uint) (amount-t1-min uint))
  (let
    ((t0 (contract-of t0-trait))
     (t1 (contract-of t1-trait))
     (current-block (try! (contract-call? block-height-provider get-block-height)))
     (global (var-get global-params))
     (pair (update-emission current-block (try! (initialize-pair t0 t1 (contract-of pair-logic)))))
     (r0 (get r0 pair))
     (r1 (get r1 pair))
     (rlp (get rlp pair))
     (result (try! (contract-call? pair-logic exit t0 t1 r0 r1 rlp amount-lp)))
     (d0 (get amount0 result))
     (d1 (get amount1 result)))
    (asserts! (is-eq (contract-of block-height-provider) (get block-height-provider global)) err-wrong-block-height-provider)
    (asserts! (>= d0 amount-t0-min) err-slippage)
    (asserts! (>= d1 amount-t1-min) err-slippage)
    (try! (change-reserve pair t0 t1 (contract-of pair-logic) (- 0 (to-int d0)) (- 0 (to-int d1)) (- 0 (to-int amount-lp))))
    (change-user-lp pair contract-caller (- (to-int amount-lp)))
    (try! (transfer-out t0-trait d0 contract-caller))
    (try! (transfer-out t1-trait d1 contract-caller))
    (print {event: "exit", maker: contract-caller, pair-id: (get id pair), t0: t0, t1: t1, logic: (contract-of pair-logic), d0: d0, d1: d1, dlp: amount-lp})
    (ok {t0: d0, t1: d1})))

(define-private (swap-helper
                 (next {token: <asset-wrapper-trait>, logic: <pair-logic-trait>})
                 (acc (response {global: {fee: uint, pfee: uint, block-height-provider: principal}, amount-out: uint, user: principal, token: <asset-wrapper-trait>} uint)))
    (let
      ((result (try! acc))
       (token-in (get token result))
       (token-out (get token next)))
      (ok (merge result {
          amount-out: (try! (swap-single (contract-of token-in) (contract-of token-out) (get logic next) (get amount-out result) result)),
          token: (get token next),
      }))))
        

(define-private (path-zipper (token <asset-wrapper-trait>) (logic <pair-logic-trait>)) {token: token, logic: logic})

(define-public (swap (path (list 10 <asset-wrapper-trait>)) (path-logics (list 10 <pair-logic-trait>)) (amt-in uint) (amt-out-min uint))
  (let
    ((tout (unwrap-panic (element-at? path (- (len path) u1))))
     (tin (unwrap-panic (element-at? path u0)))
     (zipped (map path-zipper (unwrap-panic (slice? path u1 (len path))) path-logics))
     (result (try! (fold swap-helper zipped (ok { token: tin, amount-out: (try! (transfer-in tin amt-in)), user: tx-sender, global: (var-get global-params)}))))
     (amt-out (get amount-out result)))
    (asserts! (>= (len path) u2) err-invalid-args)
    (asserts! (is-eq (- (len path) u1) (len path-logics)) err-invalid-args)
    (asserts! (>= amt-out amt-out-min) err-slippage)
    (try! (transfer-out tout amt-out tx-sender))
    (ok amt-out)))

(define-private (reverse-helper (item {token: <asset-wrapper-trait>, logic: <pair-logic-trait>}) (seq (list 10 {token: <asset-wrapper-trait>, logic: <pair-logic-trait>})))
  (unwrap-panic (as-max-len? (concat (list item) seq) u10)))
(define-private (reverse (l (list 10 {token: <asset-wrapper-trait>, logic: <pair-logic-trait>})))
  (fold reverse-helper l (list)))

(define-private (swap-given-out-helper
                 (next {token: <asset-wrapper-trait>, logic: <pair-logic-trait>})
                 (acc (response {global: {fee: uint, pfee: uint, block-height-provider: principal}, amount-in: uint, user: principal, token: <asset-wrapper-trait>} uint)))
    (let
      ((result (try! acc))
       (token-in (get token result))
       (token-out (get token next)))
      (ok (merge result {
          amount-in: (try! (swap-given-out-single (contract-of token-in) (contract-of token-out) (get logic next) (get amount-in result) result)),
          token: (get token next),
      }))))

(define-public (swap-given-out (path (list 10 <asset-wrapper-trait>)) (path-logics (list 10 <pair-logic-trait>)) (amount-out uint) (amount-in-max uint))
  (let
    ((tout (unwrap-panic (element-at? path (- (len path) u1))))
     (tin (unwrap-panic (element-at? path u0)))
     (zipped (map path-zipper path path-logics))
     (result (try! (fold swap-given-out-helper (reverse zipped) (ok { token: tout, amount-in: amount-out, user: tx-sender, global: (var-get global-params)}))))
     (amount-in (get amount-in result)))
    (asserts! (>= (len path) u2) err-invalid-args)
    (asserts! (is-eq (- (len path) u1) (len path-logics)) err-invalid-args)
    (asserts! (>= amount-in-max amount-in) err-slippage)
    (try! (transfer-out tout amount-in tx-sender))
    (ok amount-in)))

(define-read-only (get-pair (current-block-height uint) (t0 principal) (t1 principal) (logic principal))
  (let
    ((global (var-get global-params))
     (correct-order (principal-less-than t0 t1))
     (t0- (if correct-order t0 t1))
     (t1- (if correct-order t1 t0)))
    (match (map-get? pairs {t0: t0-, t1: t1-, logic: logic})
      pair (some (merge (update-emission current-block-height pair) {
        fee: (default-to (get fee global) (get fee pair)),
        pfee: (default-to (get pfee global) (get pfee pair)),
        r0: (if correct-order (get r0 pair) (get r1 pair)),
        r1: (if correct-order (get r1 pair) (get r0 pair))}))
      none)))

(define-read-only (get-pair-by-id (current-block-height uint) (id uint))
  (match (map-get? pair-tokens id)
    t (some (merge t (unwrap-panic (get-pair current-block-height (get t0 t) (get t1 t) (get logic t)))))
    none))

(define-read-only (is-contract-owner)
    (ok (asserts! (is-eq contract-caller (var-get contract-owner)) err-not-owner)))

(define-read-only (get-num-pairs)
    (var-get num-pairs)) 

(define-read-only (get-balance (pair-id uint) (user principal))
    (match (map-get? user-lp-info {pair-id: pair-id, user: user})
      user-info (get balance user-info)
      u0))

(define-read-only (get-emission (time uint) (pair-id uint) (user principal))
    (match (map-get? user-lp-info {pair-id: pair-id, user: user})
      user-info (let
        ((t (unwrap-panic (map-get? pair-tokens pair-id)))
         (pair (update-emission time (unwrap-panic (map-get? pairs {t0: (get t0 t), t1: (get t1 t), logic: (get logic t)}))))
         (user-info-updated (update-user-info pair user-info)))
        (get emission user-info-updated))
      u0))

(define-read-only (get-protocol-fee (token principal))
  (default-to u0 (map-get? protocol-fees-accrued token)))

(define-read-only (update-user-info (pair {id: uint, r0: uint, r1: uint, rlp: uint, fee: (optional uint), pfee: (optional uint), emission-per-share-1e18: uint, last-emission-update: uint}) (user-info {balance: uint, emission: uint, last-emission-snapshot: uint}))
  (merge user-info {
      emission: (* (get balance user-info) (- (get emission-per-share-1e18 pair) (get last-emission-snapshot user-info))),
      last-emission-snapshot: (get emission-per-share-1e18 pair)
  }))

(define-private (get-user-lp-info (pair {id: uint, r0: uint, r1: uint, rlp: uint, fee: (optional uint), pfee: (optional uint), emission-per-share-1e18: uint, last-emission-update: uint}) (user principal))
  (match (map-get? user-lp-info {pair-id: (get id pair), user: user})
    user-info (update-user-info pair user-info)
    {balance: u0, emission: u0, last-emission-snapshot: (get emission-per-share-1e18 pair)}))

(define-private (change-user-lp (pair {id: uint, r0: uint, r1: uint, rlp: uint, fee: (optional uint), pfee: (optional uint), emission-per-share-1e18: uint, last-emission-update: uint}) (user principal) (delta int))
  (let
    ((current (get-user-lp-info pair user)))
    (map-set user-lp-info {pair-id: (get id pair), user: user} (merge current {balance: (add (get balance current) delta)}))))


(define-private (credit-protocol-fee (token principal) (amount uint))
  (if (is-eq amount u0) false
    (map-set protocol-fees-accrued token (+ amount (default-to u0 (map-get? protocol-fees-accrued token))))))

(define-private (swap-single (ti principal) (to principal) (logic <pair-logic-trait>) (amount-in uint) (context {amount-out: uint, user: principal, global: {fee: uint, pfee: uint, block-height-provider: principal}, token: <asset-wrapper-trait>}))
  (let
    ((pair (try! (initialize-pair ti to (contract-of logic))))
     (ri (get r0 pair))
     (ro (get r1 pair))
     (global (get global context))
     (fee (div-ceil (* amount-in (default-to (get fee global) (get fee pair))) u10000))
     (pfee (div-ceil (* fee (default-to (get pfee global) (get pfee pair))) u10000))
     (amount-out (try! (contract-call? logic swap-given-in ti to ri ro (- amount-in fee)))))
    (try! (change-reserve pair ti to (contract-of logic) (to-int (- amount-in pfee)) (- 0 (to-int amount-out)) 0))
    (credit-protocol-fee ti pfee)
    (print {event: "swap", maker: (get user context), tkn-in: ti, tkn-out: to, logic: (contract-of logic), amt-in: amount-in, amt-out: amount-out, lpfee: (- fee pfee), pfee: pfee, reserve-in: ri, reserve-out: ro})
    (ok amount-out)))


(define-private (swap-given-out-single (ti principal) (to principal) (logic <pair-logic-trait>) (amount-out uint) (context {amount-in: uint, user: principal, global: {fee: uint, pfee: uint, block-height-provider: principal}, token: <asset-wrapper-trait>}))
  (let
    ((pair (try! (initialize-pair ti to (contract-of logic))))
     (ri (get r0 pair))
     (ro (get r1 pair))
     (global (get global context))
     (amount-in-without-fee (try! (contract-call? logic swap-given-out ti to ri ro amount-out)))
     (fee-rate (default-to (get fee global) (get fee pair)))
     (pfee-rate (default-to (get pfee global) (get pfee pair)))
     (fee (- (div-ceil (* amount-in-without-fee u10000) (- u10000 fee-rate)) amount-in-without-fee))
     (pfee (div-ceil (* fee pfee-rate) u10000))
     (amount-in (+ fee amount-in-without-fee)))
    (try! (change-reserve pair ti to (contract-of logic) (to-int (- amount-in pfee)) (- 0 (to-int amount-out)) 0))
    (credit-protocol-fee ti pfee)
    (print {event: "swap", maker: (get user context), tkn-in: ti, tkn-out: to, logic: (contract-of logic), amt-in: amount-in, amt-out: amount-out, lpfee: (- fee pfee), pfee: pfee, reserve-in: ri, reserve-out: ro})
    (ok amount-in)))

(define-read-only (update-emission (time uint) (pair {id: uint, r0: uint, r1: uint, rlp: uint, fee: (optional uint), pfee: (optional uint), emission-per-share-1e18: uint, last-emission-update: uint}))
  (merge pair {
    emission-per-share-1e18: (+
      (get emission-per-share-1e18 pair)
      (if (is-eq u0 (get rlp pair))
        u0
        (muldiv PRECISION (- time (get last-emission-update pair)) (get rlp pair)))),
    last-emission-update: time,
  }))

(define-private (initialize-pair (t0 principal) (t1 principal) (logic principal))
  (let
    ((correct-order (principal-less-than t0 t1))
     (t0- (if correct-order t0 t1))
     (t1- (if correct-order t1 t0)))
    (match (map-get? pairs {t0: t0-, t1: t1-, logic: logic})
      pair (ok (if correct-order pair (merge pair {r0: (get r1 pair), r1: (get r0 pair)})))
      (let
        ((pair-id (var-get num-pairs))
         (pair {id: pair-id, r0: u0, r1: u0, rlp: u0, fee: none, pfee: none, emission-per-share-1e18: u0, last-emission-update: u0}))
        (asserts! (not (is-eq t0 t1)) err-same-token)
        (var-set num-pairs (+ pair-id u1))
        (map-set pairs {t0: t0-, t1: t1-, logic: logic} pair)
        (map-set pair-tokens pair-id {t0: t0-, t1: t1-, logic: logic})
        (print {event: "create", id: pair-id, t0: t0-, t1: t1-, logic: logic})
        (ok pair)))))

(define-private (change-reserve
                                (pair {id: uint, r0: uint, r1: uint, rlp: uint, fee: (optional uint), pfee: (optional uint), emission-per-share-1e18: uint, last-emission-update: uint})
                                (t0 principal)
                                (t1 principal)
                                (logic principal)
                                (d0 int)
                                (d1 int)
                                (dlp int))
  (let
    ((new-r0 (add (get r0 pair) d0))
     (new-r1 (add (get r1 pair) d1))
     (new-rlp (add (get rlp pair) dlp)))
    (asserts! (< new-r0 MAX_RESERVE) err-overflow)
    (asserts! (< new-r1 MAX_RESERVE) err-overflow)
    (asserts! (< new-rlp MAX_RESERVE) err-overflow)
    (if (principal-less-than t0 t1)
      (map-set pairs {t0: t0, t1: t1, logic: logic}
        (merge pair
               {
                 r0: new-r0,
                 r1: new-r1,
                 rlp: new-rlp,
                }))
      (map-set pairs {t0: t1, t1: t0, logic: logic}
        (merge pair
               {
                 r0: new-r1,
                 r1: new-r0,
                 rlp: new-rlp,
               })))
    (ok true)))

(define-private (add (a uint) (b int)) (to-uint (+ (to-int a) b)))

(define-private (transfer-in (token <asset-wrapper-trait>) (amount uint))
  (if (is-eq u0 amount) (ok u0)
    (contract-call? token transfer-in amount)))

(define-private (div-ceil (a uint) (b uint))
  (if (is-eq a u0) u0 (+ (/ (- a u1) b) u1)))


(define-private (transfer-out (token <asset-wrapper-trait>) (amount uint) (to principal))
  (if (is-eq u0 amount) (ok u0)
    (contract-call? token transfer-out amount to)))
