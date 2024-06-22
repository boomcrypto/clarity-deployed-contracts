---
title: "Trait block-info-v14"
draft: true
---
```
;; @contract Block Info
;; @version 6
;;
;; Contract to get info at given block

;;-------------------------------------
;; Constants
;;-------------------------------------

(define-constant ERR_BLOCK_INFO u42001)

;;-------------------------------------
;; Bitflow
;;-------------------------------------

(define-read-only (get-user-bitflow (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err ERR_BLOCK_INFO)))
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

```
