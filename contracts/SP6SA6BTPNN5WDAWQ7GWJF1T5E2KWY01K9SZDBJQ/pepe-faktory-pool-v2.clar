(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-traits-v1.sip010-ft-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-traits-v0.liquidity-pool-trait)

(define-constant DEPLOYER tx-sender)
(define-constant CONTRACT (as-contract tx-sender))

(define-constant ERR_INVALID_OPERATION (err u400))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_TOO_MUCH_SLIPPAGE (err u407))

(define-constant PRECISION u1000000)
(define-constant LP_REBATE u10000)

(define-constant OP_SWAP_A_TO_B 0x00) 
(define-constant OP_SWAP_B_TO_A 0x01)
(define-constant OP_ADD_LIQUIDITY 0x02) 
(define-constant OP_REMOVE_LIQUIDITY 0x03) 
(define-constant OP_LOOKUP_RESERVES 0x04) 

(define-fungible-token sBTC-PEPE)
(define-data-var token-uri (optional (string-utf8 256)) none)

(define-data-var gated bool true)

(define-public (transfer
    (amount uint)
    (sender principal)
    (recipient principal)
    (memo (optional (buff 34)))
  )
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (try! (ft-transfer? sBTC-PEPE amount sender recipient))
    (match memo
      to-print (print to-print)
      0x0000
    )
    (print {
      type: "transfer-lp",
      sender: sender,
      recipient: recipient,
      amount: amount,
    })
    (ok true)
  )
)

(define-read-only (get-name)
  (ok "sBTC-PEPE lp-token")
)

(define-read-only (get-symbol)
  (ok "sBTC-PEPE")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance sBTC-PEPE who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply sBTC-PEPE))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-public (set-token-uri (uri (string-utf8 256)))
  (if (is-eq contract-caller DEPLOYER)
    (ok (var-set token-uri (some uri)))
    ERR_UNAUTHORIZED
  )
)

(define-public (execute
    (amount uint)
    (opcode (optional (buff 16)))
  )
  (let (
      (sender tx-sender)
      (operation (get-byte (default-to 0x00 opcode) u0))
    )
    (if (is-eq operation OP_SWAP_A_TO_B)
      (swap-a-to-b amount u0)
      (if (is-eq operation OP_SWAP_B_TO_A)
        (swap-b-to-a amount)
        (if (is-eq operation OP_ADD_LIQUIDITY)
          (add-liquidity amount)
          (if (is-eq operation OP_REMOVE_LIQUIDITY)
            (remove-liquidity amount)
            ERR_INVALID_OPERATION
          )
        )
      )
    )
  )
)

(define-read-only (quote
    (amount uint)
    (opcode (optional (buff 16)))
  )
  (let ((operation (get-byte (default-to 0x00 opcode) u0)))
    (if (is-eq operation OP_SWAP_A_TO_B)
      (ok (get-swap-quote amount (some 0x00)))
      (if (is-eq operation OP_SWAP_B_TO_A)
        (ok (get-swap-quote amount (some 0x01)))
        (if (is-eq operation OP_ADD_LIQUIDITY)
          (ok (get-liquidity-quote amount))
          (if (is-eq operation OP_REMOVE_LIQUIDITY)
            (ok (get-liquidity-quote amount))
            (if (is-eq operation OP_LOOKUP_RESERVES)
              (ok (get-reserves-quote))
              ERR_INVALID_OPERATION
            )
          )
        )
      )
    )
  )
)

(define-public (swap-a-to-b
    (amount uint)
    (min-y-out uint)
  )
  (let (
      (sender tx-sender)
      (delta (get-swap-quote amount (some 0x00)))
      (dy-d (get dy delta))
    )
    (and (var-get gated) (asserts! (is-approved-caller) ERR_UNAUTHORIZED))
      (print {
      type: "buy",
      sender: sender,
      token-in: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      amount-in: amount,
      token-out: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      amount-out: dy-d,
      pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT,
    })
    (asserts! (>= dy-d min-y-out) ERR_TOO_MUCH_SLIPPAGE)
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer amount sender CONTRACT none
    ))
    (try! (as-contract (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
      transfer dy-d CONTRACT sender none
    )))
    (print {
      type: "buy",
      sender: sender,
      token-in: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      amount-in: amount,
      token-out: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      amount-out: dy-d,
      pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT,
    })
    (ok delta)
  )
)

(define-public (swap-b-to-a (amount uint))
  (let (
      (sender tx-sender)
      (delta (get-swap-quote amount (some 0x01)))
      (dy-d (get dy delta))
    )
    (and (var-get gated) (asserts! (is-approved-caller) ERR_UNAUTHORIZED))
    (try! (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
      transfer amount sender CONTRACT none
    ))
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer dy-d CONTRACT sender none
    )))
    (print {
      type: "sell",
      sender: sender,
      token-in: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      amount-in: amount,
      token-out: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      amount-out: dy-d,
      pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT,
    })
    (ok delta)
  )
)

(define-public (add-liquidity (amount uint))
  (let (
      (sender tx-sender)
      (delta (get-liquidity-quote amount))
      (dx-d (get dx delta))
      (dy-d (get dy delta))
      (dk-d (get dk delta))
    )
    (try! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer dx-d sender CONTRACT none
    ))
    (try! (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
      transfer dy-d sender CONTRACT none
    ))
    (try! (ft-mint? sBTC-PEPE dk-d sender))
    (print {
      type: "add-liquidity",
      sender: sender,
      token-a: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      token-a-amount: dx-d,
      token-b: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      token-b-amount: dy-d,
      lp-tokens: dk-d,
      pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT,
    })
    (ok delta)
  )
)

(define-public (remove-liquidity (amount uint))
  (let (
      (sender tx-sender)
      (delta (get-liquidity-quote amount))
      (dx-d (get dx delta))
      (dy-d (get dy delta))
      (dk-d (get dk delta))
    )
    (try! (ft-burn? sBTC-PEPE dk-d sender))
    (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      transfer dx-d CONTRACT sender none
    )))
    (try! (as-contract (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
      transfer dy-d CONTRACT sender none
    )))
    (print {
      type: "remove-liquidity",
      sender: sender,
      token-a: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      token-a-amount: dx-d,
      token-b: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      token-b-amount: dy-d,
      lp-tokens: dk-d,
      pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT,
    })
    (ok delta)
  )
)

(define-private (get-byte
    (opcode (buff 16))
    (position uint)
  )
  (default-to 0x00 (element-at? opcode position))
)

(define-private (get-reserves)
  {
    a: (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      get-balance CONTRACT
    )),
    b: (unwrap-panic (contract-call?
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
      get-balance CONTRACT
    )),
  }
)

(define-read-only (get-swap-quote
    (amount uint)
    (opcode (optional (buff 16)))
  )
  (let (
      (reserves (get-reserves))
      (operation (get-byte (default-to 0x00 opcode) u0))
      (is-a-in (is-eq operation OP_SWAP_A_TO_B))
      (x (if is-a-in
        (get a reserves)
        (get b reserves)
      ))
      (y (if is-a-in
        (get b reserves)
        (get a reserves)
      ))
      (dx (/ (* amount (- PRECISION LP_REBATE)) PRECISION))
      (numerator (* dx y))
      (denominator (+ x dx))
      (dy (/ numerator denominator))
    )
    {
      dx: dx,
      dy: dy,
      dk: u0,
    }
  )
)

(define-read-only (get-liquidity-quote (amount uint))
  (let (
      (k (ft-get-supply sBTC-PEPE))
      (reserves (get-reserves))
    )
    {
      dx: (if (> k u0)
        (/ (* amount (get a reserves)) k)
        amount
      ),
      dy: (if (> k u0)
        (/ (* amount (get b reserves)) k)
        amount
      ),
      dk: amount,
    }
  )
)

(define-read-only (get-reserves-quote)
  (let (
      (reserves (get-reserves))
      (supply (ft-get-supply sBTC-PEPE))
    )
    {
      dx: (get a reserves),
      dy: (get b reserves),
      dk: supply,
    }
  )
)

(begin
  (try! (add-liquidity u2141167))
  (try! (contract-call?
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
    transfer u292596971245 tx-sender CONTRACT none
  ))
  (try! (approve-caller 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.faktory-core-v2))
  (print {
      type: "initialize-pool",
      sender: tx-sender,
      token-a: 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token,
      token-b: 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz,
      initial-pool-reserves: (get-reserves-quote),
      pool-contract: CONTRACT
  })
  (ok true)
)

(define-map approved-callers principal bool)

(define-public (approve-caller (caller principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
    (ok (map-set approved-callers caller true))
  )
)

(define-public (revoke-caller (caller principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
    (ok (map-set approved-callers caller false))
  )
)

(define-private (is-approved-caller)
  (or
    (is-eq tx-sender contract-caller) 
    (default-to false (map-get? approved-callers contract-caller)) 
  )
)

(define-public (set-gated (enabled bool))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR_UNAUTHORIZED)
    (ok (var-set gated enabled))
  )
)

(define-read-only (is-gated)
  (var-get gated)
)