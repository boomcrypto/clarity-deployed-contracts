;; @contract Block Info Velar Nakamoto
;; @version 1
;;
;; Contract to get info stSTX/STX on Velar at given block

(define-public (get-user-velar (account principal) (block uint))
  (let (
    (ratio (try! (contract-call? .data-core-v1 get-stx-per-ststx .reserve-v1)))
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u243045)
      (ok u0)
      (ok (at-block block-hash (get-user-velar-helper account block ratio)))
    )
  )
)

(define-read-only (get-user-velar-helper (account principal) (block uint) (ratio uint))
  (let (
    (total-lp-supply (unwrap-panic (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001 get-total-supply)))
    (user-wallet (unwrap-panic (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001 get-balance account)))
    (user-staked (if (< block u243045)
      u0
      (get end (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-farming-core-v1_1_1_ststx-0001 get-user-staked account))
    ))
    (pool-info (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001 do-get-pool))
    (reserve0 (get reserve0 pool-info))
    (reserve0-ststx (/ (* reserve0 u1000000) ratio))
    (reserve1 (get reserve1 pool-info))
    (total-in-pool (+ reserve0-ststx reserve1))

    (user-total (+ user-wallet user-staked))
  )
    (/ (* user-total total-in-pool) total-lp-supply)
  )
)
