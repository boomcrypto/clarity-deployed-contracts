(use-trait v-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR_SWAP_FAILED (err u1003))
(define-constant ERR_SWAP_TOO_SOON (err u1004))

(define-constant SWAP_INTERVAL u2016)
(define-data-var contract-owner principal 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X)
(define-data-var stakingContract principal 'SP2J9NG5A4F2C0NP0NSSEKM27J2G7CKWXH6RCSQ3X)
(define-data-var last-swap-height uint u0)
(define-data-var balNow uint u0)
(define-data-var returnRate uint u1)
(define-data-var interval uint u2016)

;; Using contract-caller (S/O Ghislo)
(define-public (setStaking (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err u1005)) ;; Ensure only owner can set staking contract
    (var-set stakingContract address)
    (ok address)
  )
)

(define-public (setInterval (inter uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err u1005)) ;; Ensure only owner can set the interval
    (var-set interval inter)
    (ok inter)
  )
)

(define-public (setRate (rate uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err u1005)) ;; Ensure only owner can set the return rate
    (var-set returnRate rate)
    (ok rate)
  )
)

(define-public (setOwner (address principal))
  (begin
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err u1005)) ;; Ensure only owner can set the contract owner
    (var-set contract-owner address)
    (ok address)
  )
)

(define-public (hot-swap)
  (begin
    ;; Get the current block height
    (let ((current-height block-height)
          (last-swap (var-get last-swap-height))
          (setInt (var-get interval)))
      ;; Check if the required interval has passed
      (if (< (- current-height last-swap) setInt)
        (ok u111) ;; Swap too soon
        (let (
          (current-balance (unwrap-panic (as-contract (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx get-balance tx-sender))))
          (amount-to-send (/ current-balance (var-get returnRate)))
          (swap-result (as-contract (contract-call? 
            'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.router-velar-alex-v-1-2 
            swap-helper-a
            amount-to-send  ;; Hardcoded value for current-balance
            u69000000              ;; Hardcoded value
            true            ;; Hardcoded boolean
            (tuple (a 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) (b 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock))  ;; Hardcoded tuple with constants
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
            (tuple (a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlqstx-v3) (b 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2))  ;; Hardcoded tuple with constants
            (tuple (a u5000000))  ;; Hardcoded tuple for a-factors
          )))
        )
        ;; Check if the swap was successful
        (match swap-result
          swap-ok 
            (begin
              ;; Update the last swap height
              (var-set last-swap-height current-height)
              (ok swap-ok))
          swap-err 
            (err ERR_SWAP_FAILED)
        ))))
  )
)

(define-public (send-to-burn (amount uint))
  (begin
    (try! (as-contract (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer amount tx-sender 'SP000000000000000000002Q6VF78 none)))
    (ok amount)
  )
)

;; Mainnet `return` function added
(define-public (return (amount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get contract-owner)) (err u1005)) ;; Ensure only owner can set the contract owner
    (try! (as-contract (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx transfer amount contract-caller (var-get contract-owner) none)))
    (ok amount)
  )
)

;; Mainnet `send-to-stake` function with testnet constants
(define-public (send-to-stake (amount uint))
  (begin
    (try! (as-contract (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock transfer amount tx-sender (var-get stakingContract) none)))
    (ok amount)
  )
)

