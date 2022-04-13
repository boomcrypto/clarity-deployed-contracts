;; mapping between recipient of stacker's rewards and xbtc distribution
(define-map xbtc-rewards principal bool)

;; set distribution of rewards in xbtc or in stx
;; @param in-xbtc if true rewards are distributed in xbtc if possible
(define-public (set-distribution-in-xbtc (in-xbtc bool))
    (ok (map-set xbtc-rewards tx-sender in-xbtc)))
