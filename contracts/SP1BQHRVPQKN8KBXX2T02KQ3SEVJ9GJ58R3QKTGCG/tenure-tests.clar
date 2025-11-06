
;; title: tenure-tests
;; version:
;; summary:
;; description:

(define-read-only (get-burnchain-info (height uint))
    (let (
            (burnchain-header-hash (unwrap! (get-tenure-info? burnchain-header-hash height) (err u200)))
            (miner-address (unwrap! (get-tenure-info? miner-address height) (err u200)))
            (time (unwrap! (get-tenure-info? time height) (err u200)))
            (vrf-seed (unwrap! (get-tenure-info? vrf-seed height) (err u200)))
            (block-reward (unwrap! (get-tenure-info? block-reward height) (err u200)))
            (miner-spend-total (unwrap! (get-tenure-info? miner-spend-total height) (err u200)))
            (miner-spend-winner (unwrap! (get-tenure-info? miner-spend-winner height) (err u200)))
        )
        (ok {
            burnchain-header-hash: burnchain-header-hash,
            miner-address: miner-address,
            time: time,
            vrf-seed: vrf-seed,
            block-reward: block-reward,
            miner-spend-total: miner-spend-total,
            miner-spend-winner: miner-spend-winner
        }
        )
    )
)

(define-read-only (get-stacks-block-info (height uint))
    (let 
        (
            (id-header-hash (unwrap! (get-stacks-block-info? id-header-hash height) (err u200)))
            (header-hash (unwrap! (get-stacks-block-info? header-hash height) (err u200)))
            (time (unwrap! (get-stacks-block-info? time height) (err u200)))
        )
        (ok {
                id-header-hash: id-header-hash,
                header-hash: header-hash,
                time: time
            }
        )
    )
)

(define-read-only (get-current-burn-block-height)
    (ok burn-block-height)
)

(define-read-only (get-current-stacks-block-height)
    (ok stacks-block-height)
)