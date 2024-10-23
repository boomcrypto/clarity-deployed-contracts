(use-trait ft 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait strategy  .strategy.default-strategy)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-AMOUNT (err u2001))
(define-constant ERR-INVALID-PRINCIPAL (err u2002))
(define-constant ERR-INVALID-INTERVAL (err u2003))
(define-constant ERR-INVALID-KEY (err u2004))
(define-constant ERR-DCA-ALREADY-EXISTS (err u2005))
(define-constant ERR-INVALID-PRICE (err u2006))
(define-constant ERR-CONFIG-NOT-SET (err u2007))
(define-constant ERR-FETCHING-PRICE (err u2008))
(define-constant ERR-INVALID-STRATEGY (err u2009))

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-data-var treasury principal tx-sender)

(define-map sources-targets-config {source: principal, target: principal} 
															{id: uint,
															fee-fixed: uint, 
															fee-percent: uint,
															source-factor: uint,
															helper-factor:uint, 
															is-source-numerator: bool, 
															min-dca-threshold: uint, 
															max-dca-threshold: uint, 
															max-slippage: uint,
															strategy:principal})

(define-map fee-map { source: principal } { fee: uint })

(define-map dca-data { user: principal,
												source: principal,
												target: principal,
												interval: uint } 
											{ 
												is-paused: bool,
												amount: uint, ;; amount per dca
												source-amount-left: uint,
												target-amount: uint,
												min-price: uint,
												max-price: uint,
												last-updated-timestamp: uint})

(define-map interval-id-to-seconds { interval: uint  } { seconds: uint })
(map-set interval-id-to-seconds {interval: u0} {seconds: u7200}) ;; 2 hrs
(map-set interval-id-to-seconds {interval: u1} {seconds: u43200})  ;; 12 hrs
(map-set interval-id-to-seconds {interval: u2} {seconds: u86400}) ;; daily
(map-set interval-id-to-seconds {interval: u3} {seconds: u604800}) ;; weekly
;; ----------------------------------------------------------------------------------------
;; --------------------------------------Getters-------------------------------------------
;; ----------------------------------------------------------------------------------------
(define-read-only (get-dca-data (user principal) (source principal) (target principal) (interval uint))
	(map-get? dca-data {user:user, source:source, target:target, interval:interval}))

(define-read-only (get-sources-targets-config (source principal) (target principal)) 
	(ok (map-get? sources-targets-config {source:source, target:target})))
(define-read-only (get-fee (source principal)) (default-to  u0 (get fee (map-get? fee-map {source: source}))))

(define-read-only (is-approved) (contract-call? .auth is-approved))

(define-read-only (get-interval-seconds (interval uint))
  (map-get? interval-id-to-seconds {interval: interval})
)
;; ----------------------------------------------------------------------------------------
;; --------------------------------------Setters-------------------------------------------
;; ----------------------------------------------------------------------------------------
(define-public (set-sources-targets-config (source principal) (target principal) (id uint) (fee-fixed uint) (fee-percent uint) (source-factor uint) (helper-factor uint) (is-source-numerator bool) (min-dca-threshold uint) (max-dca-threshold uint) (strategy-principal principal) (max-slippage uint)) 
	(let ((value {id:id, fee-fixed:fee-fixed, fee-percent:fee-percent, source-factor: source-factor, helper-factor:helper-factor, is-source-numerator:is-source-numerator, min-dca-threshold: min-dca-threshold, max-dca-threshold: max-dca-threshold, strategy:strategy-principal, max-slippage: max-slippage})) 		
		(asserts! (is-approved) ERR-NOT-AUTHORIZED) 
		(print {function:"set-sources-targets-config", params: value})
		(ok (map-set sources-targets-config {source: source, target: target} value))
))
;; --------------------------------------------------------------------------
;; ----------------------------------------DCA---------------------------------------------
;; ----------------------------------------------------------------------------------------
(define-public (create-dca  (source-trait <ft>) 
														(target principal)
														(interval uint)
														(total-amount uint)
														(dca-amount uint)
														(min-price uint)
														(max-price uint))
	(let ((sender tx-sender)
			(source (contract-of source-trait))
			(data {is-paused: false, amount: dca-amount, source-amount-left: total-amount, target-amount: u0, min-price: min-price, max-price: max-price, last-updated-timestamp:u0})
			(sources-targets-conf  (unwrap! (map-get? sources-targets-config {source: source, target: target}) ERR-INVALID-PRINCIPAL) )
			(min-dca-threshold (get min-dca-threshold sources-targets-conf))
			(max-dca-threshold (get max-dca-threshold sources-targets-conf))
			)
		(asserts! (and (>= dca-amount min-dca-threshold) (<= dca-amount max-dca-threshold) (>= total-amount dca-amount)) ERR-INVALID-AMOUNT)
		(unwrap! (map-get? interval-id-to-seconds {interval: interval}) ERR-INVALID-INTERVAL)
		(asserts! (map-insert dca-data {user:sender, source:source, target:target, interval:interval} data) ERR-DCA-ALREADY-EXISTS)
		(print {function: "create-dca", 
						input: {user: sender, source-trait: source-trait, target:target, interval:interval, total-amount:total-amount, dca-amount:dca-amount, min-price:min-price, max-price: max-price},
						more: {more: data }})
		(contract-call? source-trait transfer total-amount sender .dca-vault none)
))

(define-public (add-to-position (source-trait <ft>) (target principal) (interval uint) (amount uint)) 
	(let (
			(sender tx-sender)
			(source (contract-of source-trait))
			(data (unwrap! (get-dca-data sender source target interval) ERR-INVALID-KEY))
			(prev-amount (get source-amount-left data))
			) 
		(try! (contract-call? source-trait transfer amount sender .dca-vault none))
		(print {function: "add-to-position", 
							input: {source-trait: source-trait, target:target, interval:interval, amount:amount, sender: sender},
							more: {more: data, prev-amount: prev-amount, source-amount-left: (+ amount prev-amount) }})
		(ok (map-set dca-data {user:sender, source:source, target:target, interval:interval} (merge data {source-amount-left: (+ amount prev-amount)})))
))

(define-public (reduce-position (source-trait <ft>) (target principal) (interval uint) (amount uint)) 
	(let (
			(sender tx-sender)
			(source (contract-of source-trait))
			(data (unwrap! (get-dca-data sender source target interval) ERR-INVALID-KEY))
			(prev-amount (get source-amount-left data))
			(amount-to-reduce (if (> amount prev-amount) prev-amount amount))
		)
		(asserts! (> amount-to-reduce u0) ERR-INVALID-AMOUNT)
		(as-contract (try! (contract-call? .dca-vault transfer-ft source-trait amount-to-reduce sender)))
		(print {function: "reduce-position", 
							input: {source-trait: source-trait, target:target, interval:interval, amount:amount, sender: sender},
							more: {more: data, prev-amount: prev-amount, amount-to-reduce: amount-to-reduce }})
		(ok (map-set dca-data {user:sender, source:source, target:target, interval:interval} (merge data {source-amount-left: (- prev-amount amount-to-reduce)})))
))

(define-public (withdraw (source principal) (target-trait <ft>) (interval uint) (amount uint)) 
	(let ((sender tx-sender)
		(target (contract-of target-trait))
		(data (unwrap! (get-dca-data sender source target interval) ERR-INVALID-KEY))
		(prev-amount (get target-amount data))
		(amount-to-withdraw (if (> amount prev-amount) prev-amount amount))
		) 
		(asserts! (> amount-to-withdraw u0) ERR-INVALID-AMOUNT)
		(as-contract (try! (contract-call? .dca-vault transfer-ft target-trait amount-to-withdraw sender)))
		(print {function: "withdraw", 
						input: {target-trait: target-trait, source:source, interval:interval, amount:amount, sender: sender},
						more: {more: data, prev-amount: prev-amount, amount-to-withdraw:amount-to-withdraw }})
	(ok (map-set dca-data {user:sender, source:source, target:target, interval:interval} (merge data {target-amount: (- prev-amount amount-to-withdraw)})))
))

;; TODO REFACTOR instead of swapping once per user => add all the token amounts of the users somewhere and swap the aggregated amount only once. 
(define-public (dca-users (source-trait <ft>)
												 	(target-trait <ft>)
													(keys (list 20 {user:principal, source:principal, target:principal, interval:uint}))
													(dca-strategy <strategy>)
													(helper-trait (optional <ft>))
													)
		(let ((source (contract-of source-trait))
					(target (contract-of target-trait))
					(curr-timestamp (unwrap-panic (get-block-info? time (- block-height u1))))
					(curr-timestamp-list (list curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp curr-timestamp))
					(user-amounts (map dca-user (list source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait source-trait) 	
																(list target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait target-trait) 	
																(list helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait helper-trait) 	
																keys
																curr-timestamp-list
													))
					(agg-amounts (fold aggregate-amounts user-amounts {total-amount:u0, fee:u0}))
					(source-total-amount (get total-amount agg-amounts))
					(fee (get fee agg-amounts))
					(source-target-map (unwrap! (map-get? sources-targets-config {source: source, target: target}) ERR-INVALID-PRINCIPAL))
					(id (get id source-target-map))
					(is-source-numerator (get is-source-numerator source-target-map))
					(source-factor (get source-factor source-target-map))
					(helper-factor (get helper-factor source-target-map))
					(max-slippage (get max-slippage source-target-map))
					(price (try! (get-price source target source-factor is-source-numerator helper-trait (some helper-factor))))
					(amount-dy (if is-source-numerator (mul-down source-total-amount price) (div-down source-total-amount price)))
					(min-dy (mul-down amount-dy max-slippage))
				) (print {useramounts: user-amounts, agg-amounts:agg-amounts, amountdy: amount-dy , min-dy:min-dy})
				(asserts! (is-eq (contract-of dca-strategy) 
												(get strategy source-target-map)) ERR-INVALID-STRATEGY)
				(if (is-eq source-total-amount u0) (ok (list u0)) 
				(begin 
					(try! (as-contract (contract-call? .dca-vault transfer-ft source-trait source-total-amount (contract-of dca-strategy))))
					(let (
							(target-total-amount (as-contract (try! (contract-call? dca-strategy swap-wrapper source-trait target-trait source-factor source-total-amount min-dy id helper-factor helper-trait))))
							)
							(print { function:"dca-users", 
											input: {source:source-trait, target:target-trait, keys:keys, dca-strategy:dca-strategy, helper-tait:helper-trait},
											more: {agg-amounts:agg-amounts, user-amounts:user-amounts, amount-dy:amount-dy, min-dy:min-dy, target-total-amount:target-total-amount} })
							(add-fee fee source)
							(ok (map set-new-target-amount (list source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount source-total-amount)
																					(list target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount target-total-amount)
																					curr-timestamp-list
																					user-amounts
																					))
)))))

(define-private (set-new-target-amount (source-total-amount uint)
																			(target-total-amount uint)
																			(curr-timestamp uint) 
																			(user-dca-amount-resp (response (tuple (amount-minus-fee uint) (fee uint) (key (optional (tuple (interval uint) (source principal) (target principal) (user principal))))) uint))
																			)  
			(match user-dca-amount-resp user-dca-amount
			(let ((key (unwrap-panic (get key user-dca-amount)))
						(data (unwrap-panic (get-dca-data (get user key) (get source key) (get target key) (get interval key))))
						(source-amount-left (get source-amount-left data))
						(target-amount (get target-amount data))
						(amount-minus-fee (get amount-minus-fee user-dca-amount))
						(fee (get fee user-dca-amount))
						(source-amount-traded (+ fee amount-minus-fee)) 
						(target-amount-traded (mul-down (div-down source-amount-traded source-total-amount) target-total-amount))
					)
					(map-set dca-data key (merge data {last-updated-timestamp: curr-timestamp, 
													source-amount-left: (- source-amount-left source-amount-traded),
													target-amount: (+ target-amount target-amount-traded)}))
					target-amount-traded
				)
			user-dca-err
			u0
	))

(define-private (aggregate-amounts (curr-resp (response (tuple (amount-minus-fee uint) (fee uint) (key (optional (tuple (interval uint) (source principal) (target principal) (user principal))))) uint))
																		(prev (tuple (total-amount uint) (fee uint))))
		(let ((curr (match curr-resp curr curr err-curr {amount-minus-fee:u0, fee:u0, key: none}))
					(curr-amount-minus-fee (get amount-minus-fee curr))
					(curr-fee (get fee curr))
					(prev-amount-minus-fee (get total-amount prev))
					(prev-fee (get fee prev))
				)
	{total-amount: (+ curr-amount-minus-fee prev-amount-minus-fee), fee: (+ curr-fee prev-fee)}
))

(define-private (dca-user (source-trait <ft>)
													(target-trait <ft>)
													(helper-trait (optional <ft>))
													(key (tuple (user principal) (source principal) (target principal) (interval uint))) 
													(curr-timestamp uint))
	(let ((user (get user key))
				(source (get source key))
				(target (get target key))
				(interval (get interval key))
				(data (unwrap! (get-dca-data user source target interval) ERR-INVALID-KEY))
				(source-amount-left (get source-amount-left data))
				(amount (get amount data))
				(target-amount (get target-amount data))
				(last-updated-timestamp (get last-updated-timestamp data))
				(min-price (get min-price data))
				(max-price (get max-price data))
				(interval-seconds (unwrap! (get-interval-seconds interval) ERR-INVALID-INTERVAL))
				(target-timestamp (+ (get seconds interval-seconds) last-updated-timestamp))
				) 
				(print {function: "dca-user", 
								input: {user: user, source: source, target: target, interval: interval, curr-timestamp: curr-timestamp},
								more: {amount: amount, interval-secoinds: interval-seconds, target-timestamp: target-timestamp}})
				(asserts! (is-eq (contract-of source-trait) source) ERR-INVALID-PRINCIPAL)
				(asserts! (is-eq (contract-of target-trait) target) ERR-INVALID-PRINCIPAL)
				(if (>= curr-timestamp target-timestamp)
						(process-swap source target source-trait target-trait helper-trait user amount min-price max-price source-amount-left interval curr-timestamp target-amount)
						(ok {amount-minus-fee: u0, fee: u0, key: none})
)))

(define-private (process-swap (source principal)
															(target principal)
															(source-trait <ft>)
															(target-trait <ft>) 
															(helper-trait (optional <ft>))
															(user principal)
															(amount uint)
															(min-price uint)
															(max-price uint)
															(source-amount-left uint)
															(interval uint)
															(curr-timestamp uint)
															(target-amount uint)
															) 
		(let ((source-target-map (unwrap! (map-get? sources-targets-config {source: source, target: target}) ERR-CONFIG-NOT-SET))
				(amount-to-trade (if (< source-amount-left amount) source-amount-left amount))
				(is-source-numerator (get is-source-numerator source-target-map))
				(source-factor (get source-factor source-target-map))
				(helper-factor (get helper-factor source-target-map))
				(fee-fixed (get fee-fixed source-target-map))
				(fee-percent (get fee-percent source-target-map))
				(fee (calc-fees amount-to-trade source fee-fixed fee-percent))
				(amount-minus-fee (- amount-to-trade fee))
				(price (try! (get-price source target source-factor is-source-numerator helper-trait (some helper-factor))))
			)
		(print {function: "process-swap", 
						input:{ curr-timestamp:curr-timestamp, source:source, target:target, user:user, amount:amount, source-amount-left:source-amount-left, interval:interval, target-amount:target-amount, max-price:max-price, min-price:min-price},
						more:{ amount-to-trade:amount-to-trade, price:price, fee:fee, amount-minus-fee:amount-minus-fee }})
		(asserts! (and (<= price max-price) (>= price min-price)) ERR-INVALID-PRICE)
		(ok {amount-minus-fee: amount-minus-fee, fee: fee, key:(some {user:user, source:source, target:target, interval:interval})})
))

(define-private (get-price (source principal) (target principal) (source-factor uint) (is-source-numerator bool) (helper-trait-opt (optional <ft>)) (helper-factor (optional uint)))
	(match helper-trait-opt helper-trait (get-price-hop source target source-factor helper-trait (unwrap-panic helper-factor) is-source-numerator)  
																								(get-price-internal source target source-factor))
)

(define-private (get-price-internal (token-x principal) (token-y principal) (factor uint)) 
	 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-price token-x token-y factor)
)

(define-private (get-price-hop (source principal) (target principal) (source-factor uint) (helper-trait <ft>) (helper-factor uint) (is-source-numerator bool)) 
	(let ((helper (contract-of helper-trait))
			(price-a (try! (get-price-internal helper source source-factor))) ;; stx/usd: 1.78986355
			(price-b (try! (get-price-internal helper target helper-factor))) ;; stx/welsh : 958.02094616
			)
			(print {function:"get-price-hop", 
							params:{source:source, target:target, source-facotr:source-factor, helper-trait:helper-trait, helper-factor:helper-factor, is-source-numerator:is-source-numerator},
							more:{price-a:price-a, price-b:price-b}
			})										  
			(ok (if is-source-numerator (div-down price-b price-a) (div-down price-a price-b)))	
))

;; ----------------------------------------------------------------------------------------
;; -----------------------------------------FEES-------------------------------------------
;; ----------------------------------------------------------------------------------------
(define-private (calc-fees (amount uint) (source principal) (fee-fixed uint) (fee-percent uint)) 
	(let ((fee-perc-amount (mul-down amount fee-percent))
				(fee (+ fee-perc-amount fee-fixed))
				(prev-fee (default-to u0 (get fee (map-get? fee-map {source:source}))))
				(next-fee (+ fee prev-fee))
			)
		(print {function: "calc-fees", 
							more: {fee: fee, next-fee: next-fee,  prev-fee:prev-fee, fee-perc-amount:fee-perc-amount, fee-fixed:fee-fixed, amount:amount, fee-percent:fee-percent}})	
		fee
))

(define-private (add-fee (new-fee uint) (source principal)) 
	(let ((prev-fee (get-fee source))
			) 
				(map-set fee-map {source: source} {fee: (+ new-fee prev-fee)})
))

(define-public (transfer-fee-to-treasury (source-trait <ft>))
(let ((source  (contract-of source-trait))
			(fee (unwrap-panic (get fee (map-get? fee-map {source: source})))))
		(try! (contract-call? .dca-vault transfer-ft source-trait fee (var-get treasury)))
		(print {function:"withdraw-fee", args:{source-trait:source-trait}, more:{fee:fee}})
		(ok (map-set fee-map {source: source} {fee: u0}))
))
;; ----------------------------------------------------------------------------------------
;; -----------------------------------------MATH-------------------------------------------
;; ----------------------------------------------------------------------------------------
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
(define-private (div-down (a uint) (b uint))
	(if (is-eq a u0) u0 (/ (* a ONE_8) b)))