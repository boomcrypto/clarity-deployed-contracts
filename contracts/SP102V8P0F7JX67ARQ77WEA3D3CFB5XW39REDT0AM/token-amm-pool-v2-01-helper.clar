(define-read-only (get-balance-many (tokens (list 200 { token-id: uint, who: principal })))
	(map get-balance tokens))
(define-private (get-balance (token { token-id: uint, who: principal }))
    (contract-call? .token-amm-pool-v2-01 get-balance (get token-id token) (get who token)))