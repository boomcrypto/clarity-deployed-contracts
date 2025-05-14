(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)


(define-constant WSTSTX 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wststx)
(define-constant WSBTC 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
(define-constant SUSDT 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-map approved-assets principal bool)
(define-constant APPROVED-ASSETS (list WSTSTX WSBTC SUSDT))

;; Define a map to track approved users who can interact with the vault during testing
(define-map approved-users principal bool)

(define-constant DEPLOYER tx-sender)
(define-constant VAULT (as-contract tx-sender))
(define-constant ONE_8 u100000000)  ;; 8 decimal places precision
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-UNSUPPORTED-SWAP (err u1001))
(define-constant ERR-UNSUPPORTED-ASSET (err u1002))
(define-constant ERR-SWAP-FAILED (err u1003))
(define-constant ERR-INVALID-PERCENTAGE (err u1004))
(define-constant ERR-INVALID-AMOUNT (err u1005))
(define-constant ERR-PAUSED (err u1006))
(define-constant ERR-INSUFFICIENT-MINT (err u1007))
(define-constant ERR-INVALID-NAV-WEIGHTS (err u1008))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1009))
(define-constant ERR-INVALID-TOKEN (err u1010))
(define-constant ERR-SUPPLY-ERROR (err u1011))

(define-map asset-weights principal uint)

(define-fungible-token beautiful-tan-cricket)
(define-data-var token-name (string-ascii 32) "beautiful-tan-cricket")
(define-data-var token-symbol (string-ascii 32) "beautiful-tan-cricket")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-decimals uint u8)
(define-data-var is-paused bool false)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (match (ft-transfer? beautiful-tan-cricket amount sender recipient)
            success (begin
                (print {type: "ft_transfer", amount: amount, sender: sender, recipient: recipient, memo: memo})
                (ok true))
            error (err error))))

;; --- TOKEN METADATA FUNCTIONS ---
(define-read-only (get-name) (ok (var-get token-name)))
(define-read-only (get-symbol) (ok (var-get token-symbol)))
(define-read-only (get-decimals) (ok (var-get token-decimals)))
(define-read-only (get-balance (who principal)) (ok (ft-get-balance beautiful-tan-cricket who)))
(define-read-only (get-total-supply) (ok (ft-get-supply beautiful-tan-cricket)))
(define-read-only (get-token-uri) (ok (var-get token-uri)))

(define-read-only (get-price (token (string-ascii 12))) (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price token))

(define-public (set-asset-weight (asset principal) (weight uint))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (asserts! (<= weight u10000) ERR-INVALID-PERCENTAGE)
        (asserts! (is-some (map-get? approved-assets asset)) ERR-UNSUPPORTED-ASSET)
        (map-set asset-weights asset weight)
        (ok true)))

(define-private (set-approved-asset (asset principal))
   (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (ok (map-set approved-assets asset true))))

(define-read-only (get-balance-usd)
    (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt get-balance VAULT))
    
(define-read-only (get-balance-ststx)
    (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wststx get-balance VAULT))

(define-read-only (get-balance-sbtc)
    (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc get-balance VAULT))

(define-read-only (get-holdings)
    {
        sbtc: (get-balance-sbtc),
        ststx: (get-balance-ststx),
        usd: (get-balance-usd)
    }
)

(define-read-only (get-token-price)
    (let (
        (nav (get-nav))
        (supply (unwrap! (get-total-supply) ERR-SUPPLY-ERROR))
    )
    (ok (if (is-eq supply u0)
        ONE_8 ;; Initial price of 1 (ONE_8 = 100000000) if no supply
        (/ (* nav ONE_8) supply))) ;; (NAV * ONE_8) / total supply to maintain 8 decimal precision
))


(define-read-only (get-price-ststx)
    (* (get last-price (get-price "stSTX")) u100)
)
(define-read-only (get-price-sbtc)
    (* (get last-price (get-price "sBTC")) u100)
)

(define-read-only (get-prices)
    {
        sbtc: (get-price-sbtc),
        ststx: (get-price-ststx),
        usd: ONE_8
    }
)


(define-read-only (get-values-usd)
    (let (
        (holdings (get-holdings))
        (price-ststx (get-price-ststx))
        (price-sbtc (get-price-sbtc))
        (value-usd (unwrap-panic (get usd holdings)))
        (value-ststx (/ (* (unwrap-panic (get ststx holdings)) price-ststx) ONE_8))
        (value-sbtc (/ (* (unwrap-panic (get sbtc holdings)) price-sbtc) ONE_8))
    )
    {
        sbtc: value-sbtc,
        ststx: value-ststx,
        usd: value-usd
    })
)

(define-read-only (is-balanced)
    (let (
        (values (get-values-usd))
        (total-value (get-nav))
        (weights (get-weights))
        (sbtc-weight (get-asset-weight WSBTC))
        (ststx-weight (get-asset-weight WSTSTX))
        (usd-weight (get-asset-weight SUSDT))
        (sbtc-target-bps (/ (* sbtc-weight u10000) (+ sbtc-weight ststx-weight usd-weight)))
        (ststx-target-bps (/ (* ststx-weight u10000) (+ sbtc-weight ststx-weight usd-weight)))
        (usd-target-bps (/ (* usd-weight u10000) (+ sbtc-weight ststx-weight usd-weight)))
        (sbtc-actual-bps (/ (* (get sbtc values) u10000) total-value))
        (ststx-actual-bps (/ (* (get ststx values) u10000) total-value))
        (usd-actual-bps (/ (* (get usd values) u10000) total-value))
        (tolerance u200) ;; 1% tolerance in basis points
    )
    (and 
        (if (> sbtc-actual-bps sbtc-target-bps)
            (<= (- sbtc-actual-bps sbtc-target-bps) tolerance) 
            (<= (- sbtc-target-bps sbtc-actual-bps) tolerance))
        (if (> ststx-actual-bps ststx-target-bps)
            (<= (- ststx-actual-bps ststx-target-bps) tolerance)
            (<= (- ststx-target-bps ststx-actual-bps) tolerance))
        (if (> usd-actual-bps usd-target-bps) 
            (<= (- usd-actual-bps usd-target-bps) tolerance)
            (<= (- usd-target-bps usd-actual-bps) tolerance))
    ))
)

(define-read-only (get-weights) (map get-weight APPROVED-ASSETS))

(define-private (get-asset-weight (asset principal)) (default-to u0 (map-get? asset-weights asset)))

(define-private (get-weight (asset principal)) (ok {asset: asset, weight: (get-asset-weight asset)}))

(define-read-only (get-nav)
    (let ((values (get-values-usd)))
    (+ (get sbtc values) (get ststx values) (get usd values))))

(define-private (check-ok (result (response uint uint)) (prev bool)) (and prev (is-ok result)))

(define-private (deposit-token (token <ft-trait>) (amount uint) (sender principal))
    (begin
        (try! (contract-call? token transfer-fixed amount sender VAULT none))
        (print {
            type: "deposit-token",
            token: token,
            amount: amount,
            sender: sender
        })
        (ok true)
    ))

(define-private (withdraw-token (token <ft-trait>) (amount uint) (recipient principal))
    (begin
        (try! (contract-call? token transfer-fixed amount VAULT recipient none))
        (print {
            type: "withdraw-token",
            token: token,
            amount: amount,
            recipient: recipient
        })
        (ok true)
    ))

(define-private (execute-single-swap 
    (swap-instruction { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    }))
    (let (
        (helper (get helper swap-instruction))
        (token-x (get token-x swap-instruction))
        (token-y (get token-y swap-instruction))
        (token-z (get token-z swap-instruction))
        (token-w (get token-w swap-instruction))
        (token-v (get token-v swap-instruction))
        (factor-x (get factor-x swap-instruction))
        (factor-y (get factor-y swap-instruction))
        (factor-z (get factor-z swap-instruction))
        (factor-w (get factor-w swap-instruction))
        (dx (get dx swap-instruction))
        (min (get min swap-instruction))
    )
    (if (is-eq helper u1) (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper token-x token-y factor-x dx min))
    (if (is-eq helper u2) (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a token-x token-y (unwrap-panic token-z) factor-x (unwrap-panic factor-y) dx min))
    (if (is-eq helper u3) (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b token-x token-y (unwrap-panic token-z) (unwrap-panic token-w) factor-x (unwrap-panic factor-y) (unwrap-panic factor-z) dx min))
    (if (is-eq helper u4) (as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c token-x token-y (unwrap-panic token-z) (unwrap-panic token-w) (unwrap-panic token-v) factor-x (unwrap-panic factor-y) (unwrap-panic factor-z) (unwrap-panic factor-w) dx min))
    ERR-UNSUPPORTED-SWAP))))))

(define-private (execute-swap-routes 
    (routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })))
    (let ((swaps (map execute-single-swap routes))) 
    (asserts! (fold check-ok swaps true) ERR-SWAP-FAILED)  
    (ok swaps)))

(define-data-var token-to-validate principal 'SP000000000000000000002Q6VF78.none)

(define-private (validate-token-eq-token  
    (token-x <ft-trait>)
    (acc bool)) 
    (and acc (is-eq (contract-of token-x) (var-get token-to-validate))))

(define-private (get-token-x-from-route
    (route { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })) (get token-x route))

(define-read-only (get-destination-token-from-route
    (route { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    }))
    (let (
        (helper (get helper route))
    )
        (if (is-eq helper u1) 
            (get token-y route)
            (if (is-eq helper u2) 
                (unwrap-panic (get token-z route))
                (if (is-eq helper u3) 
                    (unwrap-panic (get token-w route))
                    (if (is-eq helper u4) 
                        (unwrap-panic (get token-v route))
                        (get token-x route) ;; Default to token-x if helper is not recognized
                    )
                )
            )
        )
    )
)

(define-private (get-actual-from-swap-inner (response (response uint uint)))
    (match response
        success (unwrap-panic response)
        error u0
    )
)
(define-private (get-actual-from-swap (swap-responses (list 10 (response uint uint))))
    (fold + (map get-actual-from-swap-inner swap-responses) u0)
)
;; Get the percentage of the pool that a user owns
;; Returns the user's percentage of the pool with 8 decimal places precision
(define-private (get-user-percentage (user principal))
    (let (
        (user-balance (unwrap-panic (get-balance user)))
        (total-supply (unwrap-panic (get-total-supply)))
    )
        (if (is-eq total-supply u0)
            ERR-INVALID-AMOUNT
            (ok (/ (* user-balance ONE_8) total-supply)))))

;; Get the amount of a specific token that a user owns based on their percentage of the pool
(define-private (get-user-token-amount (user-percentage uint) (token <ft-trait>))
    (let ((token-balance (unwrap-panic (contract-call? token get-balance VAULT))))
        (ok (/ (* token-balance user-percentage) ONE_8))))


;; Validate that the token amounts in swap routes match the expected amounts based on user's percentage
;; Returns true if all token amounts match expected values, false otherwise
(define-private (validate-token-amounts 
    (swap-routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    }))
    (percentage uint) )
    (let (
        (user-percentage (unwrap-panic (get-user-percentage tx-sender)))
        (adjusted-percentage (/ (* user-percentage percentage) ONE_8))
    )
        (fold validate-route-amount swap-routes true)))

;; Helper function to validate a single route's token-x amount
(define-private (validate-route-amount 
    (route { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    }) 
    (valid bool))
    (let (
        (token-x (get token-x route))
        (expected-amount (unwrap-panic (get-user-token-amount (unwrap-panic (get-user-percentage tx-sender)) token-x)))
        (actual-amount (get dx route))
    )
        (and valid (is-eq expected-amount actual-amount))))


(define-public (purchase 
    (token <ft-trait>) 
    (amount uint) 
    (min-shares uint) 
    (swap-routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })))
    (let (
        (sender tx-sender)
        (initial-nav (get-nav))
        (token-price (try! (get-token-price)))
        (token-from (var-set token-to-validate (contract-of token)))
        (deposit-asset (try! (deposit-token token amount sender)))
        (swaps (try! (execute-swap-routes swap-routes)))
        (current-nav (get-nav))
        (shares-to-mint (* (/ (- current-nav initial-nav) token-price) ONE_8))
    )
        (asserts! (is-approved-user sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get is-paused)) ERR-PAUSED)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (>= shares-to-mint min-shares) ERR-INSUFFICIENT-MINT)
        ;; (asserts! (is-balanced) ERR-INVALID-NAV-WEIGHTS)
        (asserts! (fold validate-token-eq-token (map get-token-x-from-route swap-routes) true) ERR-INVALID-TOKEN)
        (try! (ft-mint? beautiful-tan-cricket shares-to-mint sender))
        (print {type: "purchase", token: token, amount: amount, sender: sender})
        (ok shares-to-mint)))


(define-public (redeem 
    (token <ft-trait>) 
    (percentage uint) 
    (swap-routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })))
    (let (
        (sender tx-sender)
        (token-price (try! (get-token-price)))
        (token-to (var-set token-to-validate (contract-of token)))
        (user-pct (try! (get-user-percentage sender)))
        (swaps-with-actual (validate-token-amounts swap-routes percentage))
        (swaps (try! (execute-swap-routes swap-routes)))
        (user-balance (unwrap-panic (get-balance sender)))
        (supply (unwrap-panic (get-total-supply)))
        (shares-to-burn (/ (* user-balance percentage) u10000))
        (amount (+ (get-actual-from-swap swaps)))
        (withdraw-to (try! (as-contract (withdraw-token token amount sender))))
    )
        (asserts! (is-approved-user sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get is-paused)) ERR-PAUSED)
        ;; (asserts! (is-balanced) ERR-INVALID-NAV-WEIGHTS)
        (asserts! (fold validate-token-eq-token (map get-destination-token-from-route swap-routes) true) ERR-INVALID-TOKEN)
        (asserts! (>= user-balance shares-to-burn) ERR-INSUFFICIENT-BALANCE)
        (try! (ft-burn? beautiful-tan-cricket shares-to-burn sender))
        (print {type: "redeem", sender: sender, percentage: percentage, shares-to-burn: shares-to-burn})
        (ok shares-to-burn)))


(define-public (rebalance 
    (swap-routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })))
    (let (
        (sender tx-sender)
        (initial-nav (get-nav))
        (try! (execute-swap-routes swap-routes))
        (post-swap-nav (get-nav))
    )
        (asserts! (is-approved-user sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get is-paused)) ERR-PAUSED)
        (asserts! (is-eq sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (asserts! (is-balanced) ERR-INVALID-NAV-WEIGHTS)
        (print {
            type: "rebalance", 
            sender: sender, 
            initial-nav: initial-nav, 
            post-swap-nav: 
            post-swap-nav
        })
        (ok true)))


(define-public (set-weights-and-rebalance 
    (sbtc-weight uint)
    (ststx-weight uint)
    (usd-weight uint)
    (swap-routes (list 10 { 
        helper: uint, 
        token-x: <ft-trait>, 
        token-y: <ft-trait>,
        token-z: (optional <ft-trait>),
        token-w: (optional <ft-trait>),
        token-v: (optional <ft-trait>),
        factor-x: uint,
        factor-y: (optional uint),
        factor-z: (optional uint),
        factor-w: (optional uint),
        dx: uint,
        min: (optional uint)
    })))
    (let (
        (sender tx-sender)
        (initial-nav (get-nav))
    )
        (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get is-paused)) ERR-PAUSED)
        (asserts! (is-eq sender DEPLOYER) ERR-NOT-AUTHORIZED)
        ;; Set weights for each asset
        (try! (set-asset-weight WSBTC sbtc-weight))
        (try! (set-asset-weight WSTSTX ststx-weight))
        (try! (set-asset-weight SUSDT usd-weight))
        ;; Execute the swap routes to rebalance
        (try! (rebalance swap-routes))
        (print {
            type: "set-weights-and-rebalance", 
            sender: sender, 
            sbtc-weight: sbtc-weight, 
            ststx-weight: ststx-weight, 
            usd-weight: usd-weight
        })
        (ok true)))


(define-read-only (get-nav-history (blocks (list 50 uint)))
    (ok (map get-nav-at-block blocks)))

(define-read-only (get-nav-at-block (block uint))
    (let (
        (block-id (unwrap-panic (get-stacks-block-info? id-header-hash block)))
        (nav (at-block block-id (get-nav)))
    )
        {block: block, nav: nav}
    ))

(define-read-only (get-price-history (blocks (list 50 uint)))
    (ok (map get-price-at-block blocks)))

(define-read-only (get-price-at-block (block uint))
    (let (
        (block-id (unwrap-panic (get-stacks-block-info? id-header-hash block)))
        (price (at-block block-id (get-token-price)))
    )
        {block: block, price: price}
    ))

(define-read-only (get-weight-history (blocks (list 50 uint)))
    (ok (map get-weights-at-block blocks)))

(define-read-only (get-weights-at-block (block uint))
    (let (
        (block-id (unwrap-panic (get-stacks-block-info? id-header-hash block)))
        (weights (at-block block-id (get-weights)))
    )
        {block: block, weights: weights}
    ))

(define-read-only (is-approved-user (user principal))
  (default-to false (map-get? approved-users user))
)

(define-public (add-approved-user (user principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
    (ok (map-set approved-users user true))
  )
)

(define-public (remove-approved-user (user principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
    (ok (map-delete approved-users user))
  )
)

(define-public (toggle-pause)
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (var-set is-paused (not (var-get is-paused)))
        (ok true)))

;; Function to remove any token from the vault as an approved user this is used for testing. will not be in final version
(define-public (remove-token (token <ft-trait>) (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get is-paused)) ERR-PAUSED)        
        (withdraw-token token amount recipient)
    )
)

(begin
    (map set-approved-asset APPROVED-ASSETS)
    (map set-asset-weight APPROVED-ASSETS (list u3000 u4000 u3000))
    (map-set approved-users DEPLOYER true)
    (ok true)
)
