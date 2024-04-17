(define-constant err-unauthorised (err u3000))

(define-map authorised-operators principal bool)
(map-set authorised-operators tx-sender true)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised))
)

(define-read-only (is-authorised-operator (who principal))
	(default-to false (map-get? authorised-operators who))
)

;; governance calls

(define-public (set-authorised-operator (who principal) (enabled bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set authorised-operators who enabled))
	)
)

;; priviliged calls
(define-public (set-use-whitelist (enabled bool))
	(begin
		(asserts! (is-authorised-operator tx-sender) err-unauthorised)
		(contract-call? .lqstx-mint-endpoint-v1-02 set-use-whitelist enabled)))

(define-public (set-whitelisted-many (addresses (list 1000 principal)) (enabled (list 1000 bool)))
    (begin 
        (asserts! (is-authorised-operator tx-sender) err-unauthorised)
        (contract-call? .lqstx-mint-endpoint-v1-02 set-whitelisted-many addresses enabled)))