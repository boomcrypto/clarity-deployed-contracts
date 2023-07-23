;;; UniswapV2Pair.sol
;;; UniswapV2Factory.sol

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-plus-trait .ft-plus-trait.ft-plus-trait)
(use-trait fee-to-trait .univ2-fee-to-trait.fee-to-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth                   (err u100))
(define-constant err-check-owner            (err u101))
(define-constant err-no-such-pool           (err u102))
(define-constant err-create-preconditions   (err u103))
(define-constant err-create-postconditions  (err u104))
(define-constant err-mint-preconditions     (err u105))
(define-constant err-mint-postconditions    (err u106))
(define-constant err-burn-preconditions     (err u107))
(define-constant err-burn-postconditons     (err u108))
(define-constant err-swap-preconditions     (err u109))
(define-constant err-swap-postconditions    (err u110))
(define-constant err-collect-preconditions  (err u111))
(define-constant err-collect-postconditions (err u112))
(define-constant err-anti-rug               (err u113))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq tx-sender (get-owner)) err-check-owner)))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

(define-data-var fee-to principal tx-sender)
(define-read-only (get-fee-to) (var-get fee-to))
(define-private (check-fee-to)
  (ok (asserts! (is-eq tx-sender (get-fee-to)) err-auth)))
(define-public (set-fee-to (new-fee-to principal))
  (begin
   (try! (check-owner))
   (ok (var-set fee-to new-fee-to)) ))

;; NOTE: tx-sender does not implement trait...
(define-data-var rev-share principal tx-sender)
(define-read-only (get-rev-share) (var-get rev-share))
(define-public (set-rev-share (new-rev-share principal))
  (begin
   (try! (check-owner))
   (ok (var-set rev-share new-rev-share)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; storage
(define-data-var pool-id uint u0)

(define-private (next-pool-id)
  (let ((id  (var-get pool-id))
        (nxt (+ id u1)))
    (var-set pool-id nxt)
    nxt))

(define-read-only (get-nr-pools) (var-get pool-id))

(define-map pools
  uint
  {
    symbol           : (string-ascii 65),
    token0           : principal,
    token1           : principal,
    lp-token         : principal,
    reserve0         : uint,
    reserve1         : uint,
    swap-fee         : (tuple (num uint) (den uint)), ;;fraction of input
    protocol-fee     : (tuple (num uint) (den uint)), ;;fraction of swap fee
    share-fee        : (tuple (num uint) (den uint)), ;;fraction of protocol fee
    block-height     : uint, ;;last
    burn-block-height: uint, ;;updated
  })

(define-map index
  {token0: principal, token1: principal}
  uint)

;; Set of known lp-tokens.
(define-map lp-tokens principal bool)

(define-map revenue
  uint
  {
    token0: uint,
    token1: uint,
  })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; read
(define-read-only (get-pool (id uint))
  (map-get? pools id))

(define-read-only (do-get-pool (id uint))
  (unwrap-panic (get-pool id)))

(define-read-only (get-pool-id (token0 principal) (token1 principal))
  (map-get? index {token0: token0, token1: token1}))

(define-read-only (lookup-pool (token0 principal) (token1 principal))
  (match (get-pool-id token0 token1)
         id (some {pool: (do-get-pool id), flipped: false})
         (match (get-pool-id token1 token0)
                id (some {pool: (do-get-pool id), flipped: true})
                none)))


(define-read-only (do-get-revenue (id uint))
  (unwrap-panic (map-get? revenue id)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; write
(define-read-only
  (check-fee
   (fee   (tuple (num uint) (den uint)))
   (guard (tuple (num uint) (den uint))) )
  (let ((amt  u1000000)
        (amt1 (/ (* amt (get num fee))   (get den fee)))
        (amt2 (/ (* amt (get num guard)) (get den guard))))

    (>= amt1 amt2)))

(define-constant MAX-SWAP-FEE {num: u995, den: u1000})


(define-public
  (update-swap-fee
    (id  uint)
    (fee (tuple (num uint) (den uint))))
  (let ((pool (do-get-pool id)))
    (try! (check-owner))
    (asserts! (check-fee fee MAX-SWAP-FEE) err-anti-rug)
    (ok (map-set pools id (merge pool {swap-fee: fee})) )))

(define-public
  (update-protocol-fee
    (id  uint)
    (fee (tuple (num uint) (den uint))))
  (let ((pool (do-get-pool id)))
    (try! (check-owner))
    (ok (map-set pools id (merge pool {protocol-fee: fee})) )))

(define-public
  (update-share-fee
   (id  uint)
   (fee (tuple (num uint) (den uint))))
  (let ((pool (do-get-pool id)))
    (try! (check-owner))
    (ok (map-set pools id (merge pool {share-fee: fee})) )))


(define-private
  (update-reserves
    (id uint)
    (r0 uint)
    (r1 uint))
  (let ((pool (do-get-pool id)))
    (ok (map-set pools id (merge pool {
      reserve0         : r0,
      reserve1         : r1,
      block-height     : block-height,
      burn-block-height: burn-block-height,
      })) )))


(define-private
  (update-revenue
    (id        uint)
    (is-token0 bool)
    (amt       uint))
  (let ((r0  (do-get-revenue id))
        (t0r (get token0 r0))
        (t1r (get token1 r0))
        (r1  {token0: (if is-token0 (+ t0r amt) t0r),
              token1: (if is-token0 t1r (+ t1r amt)) }) )
    (ok (map-set revenue id r1)) ))

(define-private (reset-revenue (id uint))
  (ok (map-set revenue id {token0: u0, token1: u0})) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ctors
(define-private
  (make-symbol
    (token0 <ft-trait>)
    (token1 <ft-trait>))
  (let ((sym0 (try! (contract-call? token0 get-symbol)))
        (sym1 (try! (contract-call? token1 get-symbol))))
    (asserts! (not (is-eq sym0 sym1)) err-create-preconditions)
    (ok (concat sym0 (concat "-" sym1)) )))

(define-private
  (make-pool
    (token0       <ft-trait>)
    (token1       <ft-trait>)
    (lp-token     <ft-plus-trait>)
    (swap-fee     (tuple (num uint) (den uint)))
    (protocol-fee (tuple (num uint) (den uint)))
    (share-fee    (tuple (num uint) (den uint))))
  (ok {
    symbol           : (try! (make-symbol token0 token1)),
    token0           : (contract-of token0),
    token1           : (contract-of token1),
    lp-token         : (contract-of lp-token),
    reserve0         : u0,
    reserve1         : u0,
    swap-fee         : swap-fee,
    protocol-fee     : protocol-fee,
    share-fee        : share-fee,
    block-height     : block-height,
    burn-block-height: burn-block-height,
  }))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; create
(define-public
  (create
    (token0       <ft-trait>)
    (token1       <ft-trait>)
    (lp-token     <ft-plus-trait>)
    (swap-fee     (tuple (num uint) (den uint)))
    (protocol-fee (tuple (num uint) (den uint)))
    (share-fee    (tuple (num uint) (den uint)))  )

  (let ((t0   (contract-of token0))
        (t1   (contract-of token1))
        (lp   (contract-of lp-token))
        (pool (try! (make-pool token0 token1 lp-token swap-fee protocol-fee share-fee)))
        (id   (next-pool-id)))

    ;; Pre-conditions
    (try! (check-owner))
    (asserts!
      (and (not (is-eq t0 t1))
           (is-none (lookup-pool t0 t1))
           (not (default-to false (map-get? lp-tokens lp)))
           (<= (get num swap-fee)     (get den swap-fee))
           (<= (get num protocol-fee) (get den protocol-fee))
           (<= (get num share-fee)    (get den share-fee))
           (check-fee swap-fee MAX-SWAP-FEE)
      )
      err-create-preconditions)

    ;; Update global state

    ;; Update local state
    (map-set pools id pool)
    (map-set index {token0: t0, token1: t1} id)
    (map-set lp-tokens lp true)
    (map-set revenue id { token0: u0, token1: u0 })

    ;; Post-conditions

    ;; Return
    (let ((event
          {op  : "create",
           user: tx-sender,
           id  : id,
           pool: pool}))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mint
(define-public
  (mint
    (id       uint)
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <ft-plus-trait>)
    (amt0     uint)
    (amt1     uint))

  (let ((pool         (do-get-pool id))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool))
        (r1           (get reserve1 pool))
        (liquidity    (calc-mint amt0 amt1 r0 r1 total-supply)) )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool) (contract-of lp-token))
           (is-eq (get token0   pool) (contract-of token0))
           (is-eq (get token1   pool) (contract-of token1))
           (> amt0 u0)
           (> amt1 u0)
           (> liquidity u0) )
      err-mint-preconditions)

    ;; Update global state
    (try! (contract-call? token0 transfer amt0 user protocol none))
    (try! (contract-call? token1 transfer amt1 user protocol none))
    (try! (as-contract (contract-call? lp-token mint liquidity user)))

    ;; Update local state
    (unwrap-panic (update-reserves id (+ r0 amt0) (+ r1 amt1)))

    ;; Post-conditions
    (asserts!
     (and
      ;; Guard against overflow in burn.
      (> (* (+ total-supply liquidity) (+ r0 amt0)) u0)
      (> (* (+ total-supply liquidity) (+ r1 amt1)) u0)
      )
     err-mint-postconditions)

    ;; Return
    (let ((event
           {op          : "mint",
            user        : user,
            id          : id,
            pool        : pool,
            amt0        : amt0,
            amt1        : amt1,
            liquidity   : liquidity,
            total-supply: total-supply
            }))
      (print event)
      (ok event)) ))

(define-read-only
  (calc-mint
    (amt0         uint)
    (amt1         uint)
    (reserve0     uint)
    (reserve1     uint)
    (total-supply uint))

  (if (is-eq total-supply u0)
      (sqrti (* amt0 amt1))
      (min (/ (* amt0 total-supply) reserve0)
           (/ (* amt1 total-supply) reserve1))) )

(define-read-only (min (a uint) (b uint)) (if (<= a b) a b))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; burn
(define-public
  (burn
    (id        uint)
    (token0    <ft-trait>)
    (token1    <ft-trait>)
    (lp-token  <ft-plus-trait>)
    (liquidity uint))

  (let ((pool         (do-get-pool id))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool))
        (r1           (get reserve1 pool))
        (amts         (calc-burn liquidity r0 r1 total-supply))
        (amt0         (get amt0 amts))
        (amt1         (get amt1 amts)) )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool) (contract-of lp-token))
           (is-eq (get token0   pool) (contract-of token0))
           (is-eq (get token1   pool) (contract-of token1))
           (> liquidity u0)
           (> amt0 u0)
           (> amt1 u0) )
      err-burn-preconditions)

    ;; Update global state
    (try! (as-contract (contract-call? token0 transfer amt0 protocol user none)))
    (try! (as-contract (contract-call? token1 transfer amt1 protocol user none)))
    (try! (as-contract (contract-call? lp-token burn liquidity user)))

    ;; Update local state
    (unwrap-panic (update-reserves id (- r0 amt0) (- r1 amt1)))

    ;; Post-conditions

    ;; Return
    (let ((event
          {op          : "burn",
           user        : user,
           id          : id,
           pool        : pool,
           liquidity   : liquidity,
           amt0        : amt0,
           amt1        : amt1,
           total-supply: total-supply
           }))
      (print event)
      (ok event)) ))

(define-read-only
  (calc-burn
    (liquidity    uint)
    (reserve0     uint)
    (reserve1     uint)
    (total-supply uint))
  {
    amt0: (/ (* liquidity reserve0) total-supply),
    amt1: (/ (* liquidity reserve1) total-supply),
  })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; swap
(define-public
  (swap
    (id        uint)
    (token-in  <ft-trait>)
    (token-out <ft-trait>)
    (rev-share0 <fee-to-trait>)
    (amt-in    uint)
    (amt-out   uint))

  (let ((pool             (do-get-pool id))
        (user             tx-sender)
        (protocol         (as-contract tx-sender))

        (t0               (get token0 pool))
        (t1               (get token1 pool))
        (is-token0        (is-eq (contract-of token-in) t0))

        (swap-fee         (get swap-fee     pool))
        (protocol-fee     (get protocol-fee pool))
        (share-fee        (get share-fee    pool))
        (amts             (calc-swap amt-in swap-fee protocol-fee share-fee))
        (amt-in-adjusted  (get amt-in-adjusted  amts))
        (amt-fee-lps      (get amt-fee-lps      amts))
        (amt-fee-protocol (get amt-fee-protocol amts))
        (amt-fee-share    (get amt-fee-share    amts))
        (amt-fee-rest     (get amt-fee-rest     amts))

        (r0              (get reserve0 pool))
        (r1              (get reserve1 pool))
        (k               (* r0 r1))
        (bals            (if is-token0
                             {bal0: (+ r0 amt-in-adjusted amt-fee-lps),
                              bal1: (- r1 amt-out),
                              a   : (+ r0 amt-in-adjusted),
                              b   : (- r1 amt-out)}
                             {bal0: (- r0 amt-out),
                              bal1: (+ r1 amt-in-adjusted amt-fee-lps),
                              a   : (- r0 amt-out),
                              b   : (+ r1 amt-in-adjusted)}))
        (b0              (get bal0 bals))
        (b1              (get bal1 bals))
        (a               (get a bals))
        (b               (get b bals)) )

    ;; Pre-conditions
    (asserts!
      (and (or (is-eq (contract-of token-in) t0)
               (is-eq (contract-of token-in) t1))
           (or (is-eq (contract-of token-out) t0)
               (is-eq (contract-of token-out) t1))
           (not (is-eq (contract-of token-in) (contract-of token-out)))

           (is-eq (contract-of rev-share0) (get-rev-share))

           (> amt-in  u0)
           (> amt-out u0)

           (> amt-in-adjusted u0)
           (or (is-eq (get num swap-fee) (get den swap-fee))
               (and (> amt-fee-lps u0))
                    (or (is-eq (get num protocol-fee) (get den protocol-fee))
                        (> amt-fee-protocol u0)))
           (is-eq amt-in (+ amt-in-adjusted amt-fee-lps amt-fee-share amt-fee-rest))

           (> b0 u0)
           (> b1 u0)
           (> a  u0)
           (> b  u0) )
      err-swap-preconditions)

    ;; Update global state
    (try! (contract-call? token-in transfer amt-in user protocol none))
    (try! (as-contract (contract-call? token-out transfer amt-out protocol user none)))

    (if (> amt-fee-share u0)
      (begin
        (try! (as-contract (contract-call? token-in transfer amt-fee-share protocol (get-rev-share) none)))
        (try! (as-contract (contract-call? rev-share0 send-revenue id is-token0 amt-fee-share)))
      )
      true)

    ;; Update local state
    (unwrap-panic (update-reserves id b0 b1))
    (unwrap-panic (update-revenue id is-token0 amt-fee-rest))

    ;; Post-conditions
    (asserts!
      (>= (* a b) k)
      err-swap-postconditions)

    ;; Return
    (let ((event
           {op              : "swap",
            user            : user,
            id              : id,
            pool            : pool,
            token-in        : token-in,
            token-out       : token-out,
            amt-in          : amt-in,
            amt-out         : amt-out,
            amt-in-adjusted : amt-in-adjusted,
            amt-fee-lps     : amt-fee-lps,
            amt-fee-protocol: amt-fee-protocol,
            amt-fee-share   : amt-fee-share,
            amt-fee-rest    : amt-fee-rest,
            b0              : b0,
            b1              : b1,
            a               : a,
            b               : b,
            k               : k}))
      (print event)
      (ok event)) ))

(define-read-only
  (calc-swap
    (amt-in       uint)
    (swap-fee     (tuple (num uint) (den uint))) ;;e.g. 998/1000
    (protocol-fee (tuple (num uint) (den uint))) ;;e.g. 250/1000
    (share-fee    (tuple (num uint) (den uint))) ;;e.g. 50/1000
    )
  (let ((amt-in-adjusted   (/ (* amt-in (get num swap-fee)) (get den swap-fee)))
        (amt-fee-total     (- amt-in amt-in-adjusted))
        (amt-fee-protocol  (/ (* amt-fee-total (get num protocol-fee)) (get den protocol-fee)) )
        (amt-fee-lps       (- amt-fee-total amt-fee-protocol))
        (amt-fee-share     (/ (* amt-fee-protocol (get num share-fee)) (get den share-fee)))
        (amt-fee-rest      (- amt-fee-protocol amt-fee-share))
        )
    {
      amt-in-adjusted : amt-in-adjusted,
      amt-fee-lps     : amt-fee-lps,
      amt-fee-protocol: amt-fee-protocol,
      amt-fee-share   : amt-fee-share,
      amt-fee-rest    : amt-fee-rest
    } ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sync/skim
;;;
;;; ~Not implementable since tokens for all pools are owned by a single
;;; contract (and we can't iterate over pools). Could add pools list
;;; and fold.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; collect
(define-public
  (collect
    (id     uint)
    (token0 <ft-trait>)
    (token1 <ft-trait>))

  (let ((pool     (do-get-pool id))
        (user     tx-sender)
        (protocol (as-contract tx-sender))

        (rev      (do-get-revenue id))
        (amt0     (get token0 rev))
        (amt1     (get token1 rev)) )

    ;; Pre-conditions
    (try! (check-fee-to))
    (asserts!
      (and (is-eq (contract-of token0) (get token0 pool))
           (is-eq (contract-of token1) (get token1 pool)) )
      err-collect-preconditions)

    ;; Update global state
    (if (>= amt0 u0)
        (try! (as-contract (contract-call? token0 transfer amt0 protocol user none)))
        false)
    (if (>= amt1 u0)
        (try! (as-contract (contract-call? token1 transfer amt1 protocol user none)))
        false)

    ;; Update local state
    (unwrap-panic (reset-revenue id))

    ;; Post-conditions

    ;; Return
    (let ((event
          {op     : "collect",
           user   : user,
           id     : id,
           pool   : pool,
           revenue: rev }))
      (print event)
      (ok event) )))

;;; eof
