(define-read-only (get-user-sBTC-arkadiko (user principal))
  (let 
    (
      (vault 
        (unwrap! 
          (contract-call? 
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1
            get-vault 
            user 
            'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          )
          u0
        )
      )
    )
    (get collateral vault)
  )
)

(define-read-only (get-user-sBTC-bitflow (user principal))
  (+ 
    (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-21-v-1-2 get-user-sbtc-balance user) u0)
    (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-22-v-1-2 get-user-sbtc-balance user) u0)
    (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-23-v-1-2 get-user-sbtc-balance user) u0)
    (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-sbtc-reader-pool-2-v-1-2 get-user-sbtc-balance user) u0)
  )
)

(define-read-only (get-user-sBTC-granite (user principal))
  (default-to u0
    (get amount
      (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1
        get-user-collateral
        user
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
      )
    )
  )
)

(define-read-only (get-user-sBTC-velar (user principal))
  (contract-call?
    'SPFAQ8JFM2GPQDJR1PARSMDSV4D46PSFPN1S53YJ.util-sbtc-wstx
    get-user-sBTC-balance
    user
    (get end
      (contract-call?
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-farming-core-v1_1_1-0070
          get-user-staked
          user
      )
    )
  )
)

(define-read-only (get-user-sBTC-zest (user principal))
	(unwrap! (contract-call?
		'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0
		get-balance
		user
	) u0)
)

(define-read-only (get-user-total-sBTC-in-DeFIs (user principal))
  (+
    (get-user-sBTC-arkadiko user)
    (get-user-sBTC-bitflow user)
    (get-user-sBTC-granite user)
    (get-user-sBTC-velar user)
    (get-user-sBTC-zest user)
  )
)

(define-read-only (get-user-total-sBTC-in-DeFIs-at-block-height (user principal) (stx-block-height uint))
  (at-block 
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
    (get-user-total-sBTC-in-DeFIs user)
  )
)
