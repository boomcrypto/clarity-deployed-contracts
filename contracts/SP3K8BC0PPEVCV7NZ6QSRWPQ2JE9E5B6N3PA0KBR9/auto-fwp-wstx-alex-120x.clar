(impl-trait .trait-ownable.ownable-trait)
(impl-trait .trait-sip-010.sip-010-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-AVAILABLE-ALEX (err u20000))

(define-fungible-token auto-fwp-wstx-alex-120x)

(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)

(define-data-var token-name (string-ascii 32) "Auto STX / ALEX Pool 120x")
(define-data-var token-symbol (string-ascii 32) "auto-fwp-wstx-alex-120x")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-auto-fwp-wstx-alex-120x.json"))

(define-data-var token-decimals uint u8)
(define-data-var transferrable bool false)

(define-read-only (get-transferrable)
	(ok (var-get transferrable))
)

(define-public (set-transferrable (new-transferrable bool))
	(begin 
		(try! (check-is-owner))
		(ok (var-set transferrable new-transferrable))
	)
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)

;; --- Authorisation check

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
)

;; Other

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 32)))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (check-is-owner))
		(ok (var-set token-uri new-uri))
	)
)

(define-public (add-approved-contract (new-approved-contract principal))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-contracts new-approved-contract true))
	)
)

(define-public (set-approved-contract (owner principal) (approved bool))
	(begin
		(try! (check-is-owner))
		(ok (map-set approved-contracts owner approved))
	)
)

;; --- Public functions

;; sip010-ft-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))	
    (begin
		    (asserts! (var-get transferrable) ERR-TRANSFER-FAILED)
        (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
        (try! (ft-transfer? auto-fwp-wstx-alex-120x amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance auto-fwp-wstx-alex-120x who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply auto-fwp-wstx-alex-120x))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Protocol functions

(define-constant ONE_8 u100000000)

;; @desc mint
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint (amount uint) (recipient principal))
	(begin		
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-mint? auto-fwp-wstx-alex-120x amount recipient)
	)
)

;; @desc burn
;; @restricted ContractOwner/Approved Contract
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ft-burn? auto-fwp-wstx-alex-120x amount sender)
	)
)

;; @desc pow-decimals
;; @returns uint
(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals)))
)

;; @desc fixed-to-decimals
;; @params amount
;; @returns uint
(define-read-only (fixed-to-decimals (amount uint))
  (/ (* amount (pow-decimals)) ONE_8)
)

;; @desc decimals-to-fixed 
;; @params amount
;; @returns uint
(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals))
)

;; @desc get-total-supply-fixed
;; @params token-id
;; @returns (response uint)
(define-read-only (get-total-supply-fixed)
  (ok (decimals-to-fixed (unwrap-panic (get-total-supply))))
)

;; @desc get-balance-fixed
;; @params token-id
;; @params who
;; @returns (response uint)
(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account))))
)

;; @desc transfer-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @params recipient
;; @returns (response bool)
(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo)
)

;; @desc mint-fixed
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response bool)
(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient)
)

;; @desc burn-fixed
;; @params token-id
;; @params amount
;; @params sender
;; @returns (response bool)
(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender)
)

(define-private (mint-fixed-many-iter (item {amount: uint, recipient: principal}))
	(mint-fixed (get amount item) (get recipient item))
)

(define-public (mint-fixed-many (recipients (list 200 {amount: uint, recipient: principal})))
	(begin
		(asserts! (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) ERR-NOT-AUTHORIZED)
		(ok (map mint-fixed-many-iter recipients))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-map available-alex principal uint)
(define-map borrowed-alex principal uint)

(define-data-var shortfall-coverage uint u110000000) ;; 1.1x

(define-read-only (get-shortfall-coverage)
  (ok (var-get shortfall-coverage))
)

(define-public (set-shortfall-coverage (new-shortfall-coverage uint))
  (begin
    (try! (check-is-owner))
    (ok (var-set shortfall-coverage new-shortfall-coverage))
  )
)

(define-public (set-available-alex (user principal) (new-amount uint))
    (begin 
        (try! (check-is-owner))
        (ok (map-set available-alex user new-amount))
    )
)

(define-read-only (get-available-alex-or-default (user principal))
    (default-to u0 (map-get? available-alex user))
)

(define-read-only (get-borrowed-alex-or-default (user principal))
  (default-to u0 (map-get? borrowed-alex user))
)

(define-public (add-to-position (dx uint))
    (let 
        (
          (sender tx-sender)
          (pool (try! (contract-call? .fixed-weight-pool-v1-01 get-token-given-position .token-wstx .age000-governance-token u50000000 u50000000 dx none)))
          (vault (try! (contract-call? .auto-fwp-wstx-alex-120 get-token-given-position (get token pool))))
          (alex-required (+ (get dy pool) (get rewards vault)))
          (alex-available (get-available-alex-or-default sender))
          (alex-borrowed (get-borrowed-alex-or-default sender))                        
        )
        (asserts! (>= alex-available alex-required) ERR-AVAILABLE-ALEX)

        (try! (contract-call? .token-wstx transfer-fixed dx sender (as-contract tx-sender) none))
        (as-contract (try! (contract-call? .age000-governance-token mint-fixed alex-required tx-sender)))
        (as-contract (try! (contract-call? .fixed-weight-pool-v1-01 add-to-position .token-wstx .age000-governance-token u50000000 u50000000 .fwp-wstx-alex-50-50-v1-01 dx (some (get dy pool)))))
        (as-contract (try! (contract-call? .auto-fwp-wstx-alex-120 add-to-position (get token pool))))
        (map-set available-alex sender (- alex-available alex-required))
        (map-set borrowed-alex sender (+ alex-borrowed alex-required))
		(try! (ft-mint? auto-fwp-wstx-alex-120x (fixed-to-decimals (get token vault)) sender))
        (print { object: "pool", action: "position-added", data: (get token vault)})
        (ok { total-alex-borrowed: (+ alex-borrowed alex-required), position: (get token vault) })
    )
)

(define-public (reduce-position)
  (let 
    (
      (sender tx-sender)
      (alex-borrowed (get-borrowed-alex-or-default sender))
      (supply (unwrap-panic (get-balance-fixed sender)))
      (total-supply (unwrap-panic (get-total-supply-fixed)))
      (share (div-down supply total-supply))
      (vault-reduced (as-contract (try! (contract-call? .auto-fwp-wstx-alex-120 reduce-position share))))
      (pool-reduced (as-contract (try! (contract-call? .fixed-weight-pool-v1-01 reduce-position .token-wstx .age000-governance-token u50000000 u50000000 .fwp-wstx-alex-50-50-v1-01 share))))
      (alex-returned (+ (get dy pool-reduced) (get rewards vault-reduced)))
      (stx-returned (get dx pool-reduced))      
      (alex-to-buy (if (<= alex-borrowed alex-returned) u0 (mul-down (- alex-borrowed alex-returned) (var-get shortfall-coverage))))
      (stx-to-sell (if (is-eq alex-to-buy u0) u0 (try! (contract-call? .fixed-weight-pool-v1-01 get-wstx-in-given-y-out .age000-governance-token u50000000 alex-to-buy))))
      (alex-bought (if (is-eq stx-to-sell u0) u0 (get dy (as-contract (try! (contract-call? .fixed-weight-pool-v1-01 swap-wstx-for-y .age000-governance-token u50000000 stx-to-sell (some (- alex-borrowed alex-returned))))))))
      (alex-to-return (- (+ alex-returned alex-bought) alex-borrowed))
      (stx-to-return (- stx-returned stx-to-sell))
    )
    
    ;; (as-contract (try! (contract-call? .age000-governance-token transfer-fixed alex-borrowed tx-sender .executor-dao none)))
    (as-contract (try! (contract-call? .age000-governance-token burn-fixed alex-borrowed tx-sender)))
    (as-contract (try! (contract-call? .age000-governance-token transfer-fixed alex-to-return tx-sender sender none)))
    (as-contract (try! (contract-call? .token-wstx transfer-fixed stx-to-return tx-sender sender none)))

	(try! (ft-burn? auto-fwp-wstx-alex-120x (fixed-to-decimals supply) sender))
    (print { object: "pool", action: "position-reduced", data: supply })
    (ok { stx: stx-to-return, alex: alex-to-return })
  )
)

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0)
    u0
    (/ (* a ONE_8) b)
  )
)

;; contract initialisation
(set-contract-owner .executor-dao)