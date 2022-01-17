;; Stacks Address TARDIS
;; find the balance at a given block height

;; People assume that time is a strict progression of cause to effect
;; but actually, from a non-linear subject point of view, it's more
;; like a big ball of wibbly wobbly timey wimey stuff.

(define-constant ERR-INVALID-BLOCK u1000)

;; if the address is not found, 0 will be returned
(define-read-only (stacks-balance-tardis (historicalBlockHeight uint) (targetAddress principal))
    (at-block
        (unwrap! (get-block-info? id-header-hash historicalBlockHeight) (err ERR-INVALID-BLOCK))
        (ok (stx-get-balance targetAddress))
    )
)