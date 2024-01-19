(define-public (mia (blocks (list 200 uint)))
(ok (map mia-claim blocks)))

(define-public (nyc (blocks (list 200 uint)))
(ok (map nyc-claim blocks)))

(define-private (mia-claim (height uint))
(contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 claim-mining-reward "mia" height))

(define-private (nyc-claim (height uint))
(contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd006-citycoin-mining-v2 claim-mining-reward "nyc" height))