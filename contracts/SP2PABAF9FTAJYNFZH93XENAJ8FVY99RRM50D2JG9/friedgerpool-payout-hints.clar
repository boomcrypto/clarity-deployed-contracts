;; mapping between stacker and recipient of stacker's rewards
(define-map payout-map principal principal)

;; set receiver of the stacker's rewards
(define-public (set-payout-recipient (recipient principal))
    (ok (map-set payout-map tx-sender recipient)))

;; remove receiver of the stacker's rewards. Rewards will be sent to stacker
(define-public (delete-payout-recipient (recipient principal))
    (ok (map-delete payout-map tx-sender)))