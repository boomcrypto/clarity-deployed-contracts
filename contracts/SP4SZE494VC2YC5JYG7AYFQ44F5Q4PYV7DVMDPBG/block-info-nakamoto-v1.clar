;; @contract Block Info Nakamoto
;; @version 1
;;
;; Contract to get info at given block

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)

;;-------------------------------------
;; User Info - Points
;;-------------------------------------

(define-read-only (get-user-wallet (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (at-block block-hash (get-wallet-balance account))
  )
)

(define-read-only (get-wallet-balance (account principal))
  (contract-call? .ststx-token get-balance account)
)

;;-------------------------------------
;; Bitflow
;;-------------------------------------

(define-read-only (get-user-bitflow (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
  )
    (if (< block u132631)
      (ok u0)
      
      (if (< block u135640)
        (at-block block-hash (get-bitflow-lp-1 account))

        (let (
          (balance-bitflow-1 (unwrap-panic (at-block block-hash (get-bitflow-lp-1 account))))
          (balance-bitflow-2 (unwrap-panic (at-block block-hash (get-bitflow-lp-2 account))))
        )
          (ok (+ balance-bitflow-1 balance-bitflow-2))
        )
      )
    )
  )
)

;; V1
(define-read-only (get-bitflow-lp-1 (account principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1 get-balance account)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-1 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-1
      account
    ))

    ;; Staked
    (staked (if (is-some user-data)
      (get total-currently-staked (unwrap-panic user-data))
      u0
    ))
  )
    (ok (+ balance staked))
  )
)

;; V2
(define-read-only (get-bitflow-lp-2 (account principal))
  (let (    
    ;; Wallet
    (balance (unwrap-panic (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance account)))

    ;; Staked
    (user-data (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-stx-ststx-v-1-2 get-user-data
      .ststx-token
      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
      account
    ))

    (staked (if (is-some user-data)
      (get total-currently-staked (unwrap-panic user-data))
      u0
    ))
  )
    (ok (+ balance staked))
  )
)

;;-------------------------------------
;; Zest
;;-------------------------------------

(define-read-only (get-user-zest (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u140111)
      (ok u0)
      (if (< block u143343)
        (at-block block-hash (get-user-zest-helper-1 account))
        (if (< block u149387)
          (at-block block-hash (get-user-zest-helper-2 account))
          (at-block block-hash (get-user-zest-helper-3 account))
        )
      )
    )
  )
)

(define-read-only (get-user-zest-helper-1 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx get-balance account)
)

(define-read-only (get-user-zest-helper-2 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-0 get-balance account)
)

(define-read-only (get-user-zest-helper-3 (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2 get-balance account)
)

;;-------------------------------------
;; Arkadiko
;;-------------------------------------

(define-read-only (get-user-arkadiko (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u142425)
      (ok u0)
      (ok (at-block block-hash (get-user-arkadiko-helper account)))
    )
  )
)

(define-read-only (get-user-arkadiko-helper (account principal))
  (let (
    (vault-info (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1 get-vault account .ststx-token)))
  )
    (get collateral vault-info)
  )
)

;;-------------------------------------
;; Velar
;;-------------------------------------

(define-read-only (get-user-velar (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u143600)
      (ok u0)
      (ok (at-block block-hash (get-user-velar-helper account block)))
    )
  )
)

(define-read-only (get-user-velar-helper (account principal) (block uint))
  (let (
    (total-lp-supply (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-total-supply)))
    (user-wallet (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-balance account)))
    (user-staked (if (< block u143607)
      u0
      (get end (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-ststx-aeusdc-core get-user-staked account))
    ))
    (user-total (+ user-wallet user-staked))

    (pool-info (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
  )

    (/ (* user-total (get reserve0 pool-info)) total-lp-supply)
  )
)

;;-------------------------------------
;; Hermetica
;;-------------------------------------

(define-read-only (get-user-hermetica (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u146526)
      (ok u0)
      (ok (at-block block-hash (get-user-hermetica-helper account)))
    )
  )
)

(define-read-only (get-user-hermetica-helper (account principal))
  (let (
    (token-balance (unwrap-panic (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.token-ststx-earn-v1 get-balance account)))
    (ratio (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-underlying-per-token))
    (wallet-amount (/ (* token-balance ratio) u1000000))

    (queued-amount (get-queued-hermetica-helper account))
  )
    (+ wallet-amount queued-amount)
  )
)

(define-read-only (get-queued-hermetica-helper (account principal))
  (let (
    (deposit-claims (get deposit-claims (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-claims-for-address account)))
  )
    (fold + (map get-claim-iter deposit-claims) u0)
  )
)

(define-read-only (get-claim-iter (claim-id uint))
  (let (
    (claim (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-claim claim-id))
  )
    (get underlying-amount (unwrap-panic claim))
  )
)
