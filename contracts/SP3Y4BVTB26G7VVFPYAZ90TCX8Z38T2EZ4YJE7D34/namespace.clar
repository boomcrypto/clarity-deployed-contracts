(define-constant ERR_NO_AUTHORITY 10001)
(define-constant ERR_ALREADY_REGISTERED 10002)
(define-constant ERR_CANNOT_REGISTER_YET 10003)
(define-constant ERR_CALLER_ALREADY_OWN_NAME 10004)
(define-constant ERR_TRANSFER_STX 10005)
(define-constant ERR_CANNOT_CHANGE_PRICE 10006)
(define-constant ERR_PRICE_INVALID 10007)

(define-constant BN u200000000000000)
(define-constant BURN_FEE u1)
(define-constant SALT 0x6161616161616161616161616161616161616161)

(define-data-var m_owner principal tx-sender)
(define-data-var m_fee_collector principal tx-sender)
(define-data-var m_namespace (buff 20) 0x)
(define-data-var m_can_register_since_block uint u0)
(define-data-var m_freeze_price bool false)
(define-data-var m_total_names uint u0)
(define-data-var m_total_fee uint u0)
(define-data-var m_price_function { buckets: (list 16 uint), base: uint, coeff: uint, nonalpha_discount: uint, no_vowel_discount: uint } { buckets: (list), base: u0, coeff: u0, nonalpha_discount: u0, no_vowel_discount: u0 })

(define-public (register_namespace (namespace (buff 20)) (lifetime uint) (can_register_since_block uint) (stx_to_burn uint))
  (begin
    (asserts! (is-eq (var-get m_owner) contract-caller) (err ERR_NO_AUTHORITY))
    (asserts! (is-eq (len (var-get m_namespace)) u0) (err ERR_ALREADY_REGISTERED))
    (var-set m_namespace namespace)
    (var-set m_can_register_since_block can_register_since_block)
    (unwrap! (stx-transfer? stx_to_burn tx-sender (as-contract tx-sender)) (err ERR_TRANSFER_STX))
    (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-preorder (hash160 (concat namespace SALT)) stx_to_burn)))
    (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-reveal namespace SALT BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN lifetime tx-sender)))
    (try! (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-ready namespace)))
    (print "register success")
    (ok true)
  )
)

(define-public (name_register (name (buff 48)))
  (let
    (
      (namespace (var-get m_namespace))
      (price (get_name_price name))
      (collector_fee (- price BURN_FEE))
      (hashed_salted_name (hash160 (concat (concat (concat name 0x2e) namespace) SALT)))
    )
    (asserts! (>= block-height (var-get m_can_register_since_block)) (err ERR_CANNOT_REGISTER_YET))
    (try! (set_price_lowest))
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hashed_salted_name BURN_FEE))
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name SALT 0x))
    (unwrap! (stx-transfer? collector_fee tx-sender (var-get m_fee_collector)) (err ERR_TRANSFER_STX))
    (var-set m_total_names (+ (var-get m_total_names) u1))
    (var-set m_total_fee (+ (var-get m_total_fee) collector_fee))
    (try! (set_price_highest))
    (ok true)
  )
)

(define-public (bulk_name_register (items (list 30 { name: (buff 48), beneficiary: principal })))
  (begin
    (asserts! (>= block-height (var-get m_can_register_since_block)) (err ERR_CANNOT_REGISTER_YET))
    (asserts! (try! (contract-call? 'SP000000000000000000002Q6VF78.bns can-receive-name tx-sender)) (err ERR_CALLER_ALREADY_OWN_NAME))
    (try! (set_price_lowest))
    (print {register: (len items), success: (len (filter iter_register items))})
    (try! (set_price_highest))
    (ok true)
  )
)

(define-public (name_renewal (name (buff 48)))
  (let
    (
      (namespace (var-get m_namespace))
      (price (get_name_price name))
      (collector_fee (- price BURN_FEE))
    )
    (try! (set_price_lowest))
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-renewal namespace name BURN_FEE none none))
    (unwrap! (stx-transfer? collector_fee tx-sender (var-get m_fee_collector)) (err ERR_TRANSFER_STX))
    (var-set m_total_fee (+ (var-get m_total_fee) collector_fee))
    (try! (set_price_highest))
    (ok true)
  )
)

(define-public (change_owner_and_fee_collector (new_owner principal) (fee_collector principal))
  (begin
    (if (is-eq (len (var-get m_namespace)) u0)
      (asserts! (is-eq tx-sender (var-get m_owner)) (err ERR_NO_AUTHORITY))
      (asserts! (is-eq contract-caller (var-get m_owner)) (err ERR_NO_AUTHORITY))
    )
    (var-set m_owner new_owner)
    (var-set m_fee_collector fee_collector)
    (ok true)
  )
)

(define-public (change_price (base uint) (coeff uint) (buckets (list 16 uint)) (non_alpha_discount uint) (no_vowel_discount uint))
  (begin
    (asserts! (is-eq contract-caller (var-get m_owner)) (err ERR_NO_AUTHORITY))
    (asserts! (not (var-get m_freeze_price)) (err ERR_CANNOT_CHANGE_PRICE))
    (asserts! (is-eq (len buckets) u16) (err ERR_PRICE_INVALID))
    (var-set m_price_function {
      buckets: buckets,
      base: base,
      coeff: coeff,
      nonalpha_discount: non_alpha_discount,
      no_vowel_discount: no_vowel_discount,
    })
    (ok true)
  )
)

(define-public (revoke_price_edition)
  (ok (and (is-eq contract-caller (var-get m_owner)) (var-set m_freeze_price true)))
)

(define-read-only (get_name_price (name (buff 48)))
  (let
    (
      (price_function (var-get m_price_function))
      (exponent (get-exp-at-index (get buckets price_function) (min u15 (- (len name) u1))))
      (no_vowel_discount (if (not (has-vowels-chars name)) (get no_vowel_discount price_function) u1))
      (nonalpha_discount (if (has-nonalpha-chars name) (get nonalpha_discount price_function) u1))
    )
    (* (/ (* (get coeff price_function) (pow (get base price_function) exponent)) (max nonalpha_discount no_vowel_discount)) u10)
  )
)

(define-read-only (get_info)
  {
    owner: (var-get m_owner),
    fee_collector: (var-get m_fee_collector),
    namespace: (var-get m_namespace),
    can_register_since_block: (var-get m_can_register_since_block),
    freeze_price: (var-get m_freeze_price),
    total_names: (var-get m_total_names),
    total_fee: (var-get m_total_fee),
    price_function: (var-get m_price_function),
  }
)

(define-private (iter_register (item { name: (buff 48), beneficiary: principal }))
  (let
    (
      (namespace (var-get m_namespace))
      (name (get name item))
      (price (get_name_price name))
      (earn_fee (- price BURN_FEE))
      (hashed_salted_name (hash160 (concat (concat (concat name 0x2e) namespace) SALT)))
    )
    (and
      (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns can-name-be-registered namespace name))
      (>= (stx-get-balance tx-sender) price)
      (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns can-receive-name (get beneficiary item)))
      (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hashed_salted_name BURN_FEE))
      (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name SALT 0x))
      (is-ok (stx-transfer? earn_fee tx-sender (var-get m_fee_collector)))
      (is-ok (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name (get beneficiary item) none))
      (var-set m_total_names (+ (var-get m_total_names) u1))
      (var-set m_total_fee (+ (var-get m_total_fee) earn_fee))
    )
  )
)

(define-private (set_price_lowest)
  (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price (var-get m_namespace) u1 u0 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1 u1))
)

(define-private (set_price_highest)
  (as-contract (contract-call? 'SP000000000000000000002Q6VF78.bns namespace-update-function-price (var-get m_namespace) BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN BN))
)

;;;;;;;; name price calculator, copy algorithm from BNS contract ;;;;;;;;;;;;;;
(define-private (min (a uint) (b uint))
  (if (<= a b) a b))

(define-private (max (a uint) (b uint))
  (if (> a b) a b))

(define-private (get-exp-at-index (buckets (list 16 uint)) (index uint))
  (unwrap-panic (element-at buckets index)))

(define-private (is-digit (char (buff 1)))
  (or 
    (is-eq char 0x30) ;; 0
    (is-eq char 0x31) ;; 1
    (is-eq char 0x32) ;; 2
    (is-eq char 0x33) ;; 3
    (is-eq char 0x34) ;; 4
    (is-eq char 0x35) ;; 5
    (is-eq char 0x36) ;; 6
    (is-eq char 0x37) ;; 7
    (is-eq char 0x38) ;; 8
    (is-eq char 0x39))) ;; 9

(define-private (is-vowel (char (buff 1)))
  (or 
    (is-eq char 0x61) ;; a
    (is-eq char 0x65) ;; e
    (is-eq char 0x69) ;; i
    (is-eq char 0x6f) ;; o
    (is-eq char 0x75) ;; u
    (is-eq char 0x79))) ;; y

(define-private (is-special-char (char (buff 1)))
  (or 
    (is-eq char 0x2d) ;; -
    (is-eq char 0x5f))) ;; _

(define-private (is-nonalpha (char (buff 1)))
  (or 
    (is-digit char)
    (is-special-char char)))

(define-read-only (has-vowels-chars (name (buff 48)))
  (> (len (filter is-vowel name)) u0))

(define-read-only (has-nonalpha-chars (name (buff 48)))
  (> (len (filter is-nonalpha name)) u0))
