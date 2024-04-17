;; bridge contract

;;(use-trait 'STX)
(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ownable-trait .ownable-trait.ownable-trait)
(use-trait bridge-token .bridge-token-trait.bridge-token-trait)

;; Error codes
(define-constant ERR-INTERNAL u500)

(define-constant ERR-TOKEN-EXISTS u10000)
(define-constant ERR-TOKEN-DOES-NOT-EXIST u10001)
(define-constant ERR-NOT-ALLOWED u10002)
(define-constant ERR-AMOUNT-IS-ZERO u10003)
(define-constant ERR-AMOUNT-IS-TOO-SMALL u10004)
(define-constant ERR-LOCK-ID-EXISTS u10006)
(define-constant ERR-WRONG-VERSION u10007)
(define-constant ERR-UNLOCK-EXISTS u10008)
(define-constant ERR-WRONG-RECIPIENT u10009)
(define-constant ERR-WRONG-DESTINATION u10010)
(define-constant ERR-WRONG-LOCK-SOURCE u10011)
(define-constant ERR-WRONG-SIGNATURE u10012)
(define-constant ERR-WRONG-PUBLIC-KEY u10013)
(define-constant ERR-NOT-STANDARD u10014)
(define-constant ERR-WRONG-TOKEN-SOURCE u10015)
(define-constant ERR-AMOUNT-IS-TOO-BIG u10016)
(define-constant ERR-WRONG-PRECISION u10017)
(define-constant ERR-WRONG-MIN-FEE u10018)
(define-constant ERR-WRONG-TOKEN-TYPE u10019)
(define-constant ERR-ASSET-DELETE-ERROR u10020)
(define-constant ERR-ASSET-SOURCE-DELETE-ERROR u10021)
(define-constant ERR-WRONG-SIGNATURE-LENGTH u10022)
(define-constant ERR-TRANSFER-OWNERSHIP-FAILED u10023)
(define-constant ERR-WRONG-OWNER u10024)
(define-constant ERR-TRANSFER-FEE-FAILED u10025)
(define-constant ERR-BRIDGE-IS-DISABLED u777)
(define-constant ERR-LOCK-EXISTS u20000)
(define-constant ERR-SAME-CHAIN u20001)
(define-constant ERR-LOCK-NOT-CREATED u20002)
(define-constant ERR-WRONG-LOCK-ID u20003)
(define-constant ERR-WRONG-UNLOCK-ID u20004)

;; Supported token types
(define-constant TOKEN-TYPE-BASE u100)
(define-constant TOKEN-TYPE-NATIVE u200)
(define-constant TOKEN-TYPE-WRAPPED u300)

;; Encoded chain id
(define-constant THIS-CHAIN 0x53544b5a) ;; "STKZ"
;; Token system precision
(define-constant SYSTEM-PRECISION u9)

(define-constant UNLOCK 0x756E6C6F636B) ;; "unlock"
(define-constant VERSION 0x01) ;; Version constant

(define-constant BP u10000) ;; 10 bp = 0.1 %
(define-constant ENV-VERSION (if (is-standard 'STB44HYPYAT2BB2QE513NSP81HTMYWBJP02HPGK6) 0x1a 0x1b)) ;; 0x1a - testnet, 0x1b - mainnet

(define-data-var base-fee-rate-bp uint u10)
(define-data-var validator-public-key (buff 33) 0x00)
;; Fee collector principal
(define-data-var fee-collector principal contract-caller)
;; Bridge owner principal
(define-data-var contract-owner principal contract-caller)
;; BIG RED BUTTON
(define-data-var is-bridge-enabled bool true)

;; locks map
(define-map locks
  {lock-id: (buff 16)}
  {
    sender: principal,
    recipient: (buff 32),
    amount: uint,
    destination: (buff 4),
    token-source: (buff 36)
  }
)
;; unlocks map
(define-map unlocks
  {chain-lock-id: (buff 20)}
  {value: bool}
)

;; supported assets map
(define-map assets
  {address: principal}
  {
    token-source: (buff 36),
    precision: uint,
    token-type: uint,
    min-fee: uint
  }
)

;; asset source map
(define-map asset-source-map
  {
    token-source: (buff 36),
  }
  {address: principal}
)

;; Add token to the bridge
(define-public 
  (add-token (token-source (buff 36)) (token <bridge-token>) (type uint) (min-fee uint))
  (begin
    (let (
        (token-address (contract-of token))
        (precision (try! (contract-call? token get-decimals)))
      )
      (try! (assert-valid-token-input token-source token-address precision type min-fee))
      (if (or (is-eq type TOKEN-TYPE-WRAPPED)
              (is-eq type TOKEN-TYPE-BASE))
        (asserts! (is-eq (try! (contract-call? token get-contract-owner)) .bridge) (err ERR-WRONG-OWNER))
        (asserts! (is-eq type TOKEN-TYPE-NATIVE) (err ERR-WRONG-TOKEN-TYPE))
      )
      (ok (try! (save-token token-source token-address precision min-fee type)))
    )
  )
)

;; Remove token from the bridge
(define-public 
  (remove-token (token-source (buff 36)) (token <bridge-token>) (new-owner principal))
  (begin
    (let (
        (token-address (contract-of token))
        (token-info (unwrap! (map-get? assets {address: token-address}) (err ERR-TOKEN-DOES-NOT-EXIST)))
        (token-type (get token-type token-info)))  
      ;; Check if owwner is calling the function
      (try! (assert-owner))
      ;; Check if token  principal is correct
      (try! (assert-principal token-address))
      ;; Check if owner principal is correct
      (asserts! (is-standard new-owner) (err ERR-NOT-STANDARD))
      ;; Check if token is correct
      (try! (assert-token-exists-in-asset-source-map token-source))
      (try! (assert-token-exists-in-assets-map token-address))
      ;; Check if token type is correct

      (if (or (is-eq token-type TOKEN-TYPE-NATIVE) (is-eq token-type TOKEN-TYPE-BASE))
          ;; Transfer all tokens to the new owner
          (asserts! (or (is-eq (try! (contract-call? token get-balance .bridge)) u0)
            (try! (as-contract (safe-transfer! token .bridge new-owner (try! (contract-call? token get-balance .bridge))))))
            (err ERR-TRANSFER-OWNERSHIP-FAILED))
          ;; Transfer ownership to the new owner
          (try! (assert-token-type token-type))
      )
      (if (or (is-eq token-type TOKEN-TYPE-WRAPPED) (is-eq token-type TOKEN-TYPE-BASE))
          ;; Transfer ownership to the new owner
          (asserts! (try! (as-contract (contract-call? token set-contract-owner new-owner)))
            (err ERR-TRANSFER-OWNERSHIP-FAILED))
          (try! (assert-token-type token-type))
      )
      ;; Remove token from the bridge
      (ok (try! (clean-assets-maps token-source token-address)))
    )
  )
)

;; Bridge lock method 
(define-public
  (lock
    (lock-id (buff 16))
    (trait-address <sip-010-token>)
    (amount uint)
    (recipient (buff 32))
    (destination (buff 4))
  )
  (begin
    ;; Check if input is valid
    (try! (assert-lock-input lock-id (contract-of trait-address) amount recipient destination))   
    (let 
      ((token-info (unwrap! (map-get? assets {address: (contract-of trait-address)}) (err ERR-TOKEN-DOES-NOT-EXIST)))
        (fee (calculate-fee amount (get min-fee token-info)))
        (token-type (get token-type token-info))
        (token-source (get token-source token-info))
        (precision (get precision token-info))
        (amount-to-lock (- amount fee))
        (sender contract-caller)
      )
      ;; check if token is supported
      (try! (assert-token-type token-type))
      (try! (create-lock lock-id token-source precision amount-to-lock recipient destination))
      ;; transfer fee to the fee collector
      (asserts! (try! (safe-transfer! trait-address sender (var-get fee-collector) fee)) (err ERR-TRANSFER-FEE-FAILED))
      ;; transfer tokens to the bridge
      (ok (try! (safe-transfer! trait-address sender .bridge amount-to-lock)))
    )    
  )
)

;; Bridge unlock method
(define-public
  (unlock
    (lock-id (buff 16))
    (recipient-principal principal)
    (system-amount uint)
    (lock-source (buff 4))
    (token <sip-010-token>)
    (signature (buff 65))
  )
  (begin
    ;; Check if input is valid
    (try! (assert-unlock-input lock-id recipient-principal system-amount lock-source (contract-of token) signature))
    (let (
        (token-info (unwrap! (map-get? assets {address: (contract-of token)}) (err ERR-TOKEN-DOES-NOT-EXIST)))
        (amount (from-system-precision system-amount (get precision token-info)))
        (token-type (get token-type token-info))
        (token-source (get token-source token-info))
        (precision (get precision token-info))
        (recipient (get hash-bytes (unwrap-panic (principal-destruct? recipient-principal))))
        (unlock-created (try! (create-unlock lock-id recipient system-amount lock-source token-source signature)))
      )
      ;; check if token is supported
      (try! (assert-token-type token-type))
      ;; create unlock
      (asserts! unlock-created (err ERR-INTERNAL))
      ;; transfer tokens to the recipient
      (ok (try! (as-contract (safe-transfer! token .bridge recipient-principal amount))))
    ) 
  )
)

;; Create lock
(define-private 
  (create-lock 
    (lock-id (buff 16))
    (token-source (buff 36))
    (precision uint)
    (amount-to-lock uint)
    (recipient (buff 32))
    (destination (buff 4))
  ) 
  (begin
    ;; check if destination is valid
    (asserts! (not (is-eq destination THIS-CHAIN)) (err ERR-SAME-CHAIN))
    ;; Lock-id should not exist, if it does, that means the lock is already created
    (asserts! (is-none (map-get? locks {lock-id: lock-id})) (err ERR-LOCK-ID-EXISTS))
    ;; create lock
    (asserts! (map-set locks
        {lock-id: lock-id}
        {
          sender: contract-caller,
          recipient: recipient,
          amount: (to-system-precision amount-to-lock precision),
          destination: destination,
          token-source: token-source
        }
      ) (err ERR-INTERNAL))
    (ok true)
  )
)

;; Create unlock
(define-private 
  (create-unlock
    (lock-id (buff 16))
    (recipient (buff 20))
    (system-amount uint)
    (lock-source (buff 4))
    (token-source (buff 36))
    (signature (buff 65))
  )
  (begin
    (let ((chain-lock-id (concat lock-source lock-id)))
      ;; Check that this is not the same chain as the lock source
      (asserts! (not (is-eq lock-source THIS-CHAIN)) (err ERR-SAME-CHAIN))
      ;; Unlock should not already exist, if it does, that means the unlock is already created
      (asserts! (is-none (map-get? unlocks {chain-lock-id: chain-lock-id})) (err ERR-UNLOCK-EXISTS))
      ;; Check that message was signed by the validator
      (asserts! (secp256k1-verify 
          ;; Hash of lock-id, recipient, system-amount, lock-source, token-source and unlock
          (keccak256 
            (concat lock-id 
              (concat recipient 
              (concat (unwrap-panic (to-consensus-buff? system-amount))
              (concat lock-source 
              (concat token-source UNLOCK))))
            )
          )
          signature
          (var-get validator-public-key))
          (err ERR-WRONG-SIGNATURE))
      ;; create unlock
      (ok (map-set unlocks 
        {chain-lock-id: chain-lock-id}
        {value: true}
      ))
    )
  )
)

;; Calculate fee based on the amount and the base fee rate
(define-private 
  (calculate-fee (amount uint) (min-fee uint))
  (begin
    (let 
      ((fee (/ (* amount (var-get base-fee-rate-bp)) BP)))
      (if (< fee min-fee) min-fee fee)
    )
  )
)

;; Method to transfer tokens using the trait
(define-private 
  (safe-transfer! 
    (token <sip-010-token>) 
    (sender principal) 
    (recipient principal) 
    (amount uint)
  )
  (ok (try! (contract-call? token transfer amount sender recipient none)))
)

;; Method returns token principal on Stacks by the token source
(define-read-only 
  (get-token-by-source
    (token-source (buff 36))
  )
  (match 
      (map-get? asset-source-map {token-source: token-source})
      value (ok value)
      (err ERR-TOKEN-DOES-NOT-EXIST))
)

;; Method returns token config by the token address
(define-read-only 
  (get-token-native (native-address principal))
  (match 
      (map-get? assets {address: native-address})
      value (ok value)
      (err ERR-TOKEN-DOES-NOT-EXIST))
)

;; Convert amount to system precision
(define-read-only 
  (to-system-precision
    (amount uint)
    (precision uint)
  )
  (begin
    (if (> precision SYSTEM-PRECISION) 
      (/ amount (pow u10 (- precision SYSTEM-PRECISION)))
      (if (< precision SYSTEM-PRECISION)
          (* amount (pow u10 (- SYSTEM-PRECISION precision)))
          amount
      )
    )
  )
)

;; Convert amount from system precision
(define-read-only 
  (from-system-precision 
    (amount uint)
    (precision uint)
  )
  (begin 
    (if (> precision SYSTEM-PRECISION) 
        (* amount (pow u10 (- precision SYSTEM-PRECISION)))
      (if (< precision SYSTEM-PRECISION)
        (/ amount (pow u10 (- SYSTEM-PRECISION precision)))
        amount
      )
    )
  )
)

;; Returns owner principal
(define-read-only 
	(get-contract-owner)
  (ok (var-get contract-owner))
)

;; Set owner principal
(define-public 
	(set-contract-owner 
    (owner principal)
  )
	(begin
		(try! (assert-owner))
    (asserts! (is-standard owner) (err ERR-NOT-ALLOWED))
		(ok (var-set contract-owner owner))
	)
)

;; Returns base fee rate in basis points
(define-read-only 
	(get-base-fee-rate-bp)
  (ok (var-get base-fee-rate-bp))
)

;; Set base fee rate in basis points
(define-public 
	(set-base-fee-rate-bp 
    (value uint)
  )
	(begin
		(try! (assert-owner))
    (asserts! (> value u0) (err ERR-AMOUNT-IS-ZERO))
    (asserts! (>= BP value) (err ERR-AMOUNT-IS-TOO-BIG))
		(ok (var-set base-fee-rate-bp value))
	)
)

;; Returns fee collector principal
(define-read-only 
	(get-fee-collector)
  (ok (var-get fee-collector))
)

;; Set fee collector principal
(define-public 
	(set-fee-collector 
    (collector principal)
  )
	(begin
		(try! (assert-owner))
    (asserts! (is-standard collector) (err ERR-NOT-ALLOWED))
		(ok (var-set fee-collector collector))
	)
)

;; Returns validator public key
(define-read-only 
	(get-validator-public-key)
  (ok (var-get validator-public-key))
)

;; Set validator public key
(define-public 
	(set-validator-public-key 
    (public-key (buff 33))
  )
	(begin
		(try! (assert-owner))
		(try! (assert-public-key-length public-key))
		(ok (var-set validator-public-key public-key))
	)
)

;; Returns is bridge enabled state
(define-read-only 
	(get-is-bridge-enabled)
  (ok (var-get is-bridge-enabled))
)

;; Change is bridge enabled state
(define-public 
	(set-is-bridge-enabled 
    (enabled bool)
  )
	(begin
		(try! (assert-owner))
		(ok (var-set is-bridge-enabled enabled))
	)
)

;; Set token min fee
(define-public 
  (set-token-min-fee (native-address principal) (fee uint)) 
  (begin 
    (try! (assert-owner))
    (try! (assert-principal native-address))
    (try! (assert-min-fee fee))
    (let ((asset (unwrap! (map-get? assets { address: native-address }) (err ERR-TOKEN-DOES-NOT-EXIST))))
      (ok (map-set assets { address: native-address} (merge asset { min-fee: fee })))
    )
  )
)

;; Method returns lock data by the lock-id
(define-read-only 
  (get-lock (lock-id (buff 16)))
  (match 
      (map-get? locks {lock-id: lock-id})
      value (ok value)
      (err ERR-WRONG-LOCK-ID))
)

;; Method returns is lock claimed with the given lock-id
(define-read-only 
  (is-claimed (lock-id (buff 20)))
  (begin 
    (match 
      (map-get? unlocks {chain-lock-id: lock-id})
      value (ok value)
      (err ERR-WRONG-UNLOCK-ID))
  )
)

;; Add new token to the bridge asset and asset-source maps
(define-private 
  (save-token
    (token-source (buff 36))
    (token principal)
    (precision uint)
    (min-fee uint)
    (token-type uint)
  ) 
  (begin  
    (asserts! (map-set assets
      {address: token}
      {
        token-source: token-source,
        precision: precision,
        token-type: token-type,
        min-fee: min-fee
      }
    ) (err ERR-INTERNAL))
    (asserts! (map-set asset-source-map 
      {token-source: token-source}
      {address: token}
    ) (err ERR-INTERNAL))
    (ok true)
  )
)

;; Remove token from the bridge asset and asset-source maps
(define-private 
  (clean-assets-maps
    (token-source (buff 36))
    (token-address principal)
  ) 
  (begin 
    (asserts! (map-delete assets {address: token-address}) (err ERR-ASSET-DELETE-ERROR))
    (asserts! (map-delete asset-source-map {token-source: token-source}) (err ERR-ASSET-SOURCE-DELETE-ERROR))
    (ok true)
  )
)

;; Validate that caller has enough permission to call the function
(define-private 
  (is-valid-owner)
  (is-eq contract-caller (var-get contract-owner))
)

;; Ensure contract-caller is allowed to call the function
(define-private 
  (assert-owner)
  (ok (asserts! (is-valid-owner) (err ERR-NOT-ALLOWED)))
)

;; Ensure that principal is valid
(define-private 
  (assert-principal
    (address principal)
  )
  (ok (asserts! (is-standard address) (err ERR-NOT-STANDARD)))
)

;; Ensure that token type is valid
(define-private 
  (assert-token-type
    (token-type uint)
  )
  (ok (asserts! 
    (or (is-eq token-type TOKEN-TYPE-BASE) 
        (is-eq token-type TOKEN-TYPE-NATIVE)
        (is-eq token-type TOKEN-TYPE-WRAPPED)
    ) (err ERR-WRONG-TOKEN-TYPE)))
)

;; Ensure that token source has valid length
(define-private 
  (assert-token-source-length 
    (source (buff 36))
  )
  (ok (asserts! (is-eq (len source) u36) (err ERR-WRONG-TOKEN-SOURCE)))
)

;; Ensure that public key has valid length
(define-private 
  (assert-public-key-length 
    (public-key (buff 33))
  )
  (ok (asserts! (is-eq (len public-key) u33) (err ERR-WRONG-PUBLIC-KEY)))
)

;; Ensure that token precision is valid
(define-private 
  (assert-precision 
    (precision uint)
  )
  (ok (asserts! (> precision u0) (err ERR-WRONG-PRECISION)))
)

;; Ensure that token min fee is valid
(define-private 
  (assert-min-fee 
    (min-fee uint)
  )
  (ok (asserts! (> min-fee u0) (err ERR-WRONG-MIN-FEE)))
)

;; Ensure token-source is not registered in the bridge
(define-private 
  (assert-token-not-exists-in-asset-source-map 
    (token-source (buff 36))
  )
  (ok (asserts! 
      (is-none (map-get? asset-source-map {token-source: token-source}))
      (err ERR-TOKEN-EXISTS))
  )
)

;; Ensure token-source is registered in the bridge
(define-private 
  (assert-token-exists-in-asset-source-map 
    (token-source (buff 36))
  )
  (ok (asserts! 
        (is-some (map-get? asset-source-map {token-source: token-source}))
        (err ERR-TOKEN-DOES-NOT-EXIST))
  )
)

;; Ensure token principal is not registered in the bridge
(define-private 
  (assert-token-not-exists-in-assets-map 
    (token principal)
  )
  (ok (asserts! 
      (is-none (map-get? assets {address: token}))
      (err ERR-TOKEN-EXISTS)
    )
  )
)

;; Ensure token principal is registered in the bridge
(define-private 
  (assert-token-exists-in-assets-map 
    (token principal)
  )
  (ok (asserts! 
      (is-some (map-get? assets {address: token}))
      (err ERR-TOKEN-DOES-NOT-EXIST)
    )
  )
)

;; Ensure add-token input is valid
(define-private 
  (assert-valid-token-input 
    (token-source (buff 36))
    (token principal)
    (precision uint)
    (type uint)
    (min-fee uint)
  )
  (begin 
    (try! (assert-owner))
    (try! (assert-principal token))
    (try! (assert-token-source-length token-source))
    (try! (assert-precision precision))
    (try! (assert-min-fee min-fee))
    (try! (assert-token-type type))
    (try! (assert-token-not-exists-in-asset-source-map token-source))
    (try! (assert-token-not-exists-in-assets-map token))
    (ok true)
  )
)

;; Ensure lock input is valid
(define-private 
  (assert-lock-input
    (lock-id (buff 16))
    (token-address principal)
    (amount uint)
    (recipient (buff 32))
    (destination (buff 4))
  ) 
  (begin 
    (asserts! (var-get is-bridge-enabled) (err ERR-BRIDGE-IS-DISABLED))
    (asserts! (is-eq (len lock-id) u16) (err ERR-WRONG-LOCK-ID))
    (asserts! (is-eq VERSION (unwrap! (element-at lock-id u0) (err ERR-INTERNAL))) (err ERR-WRONG-VERSION))
    (try! (assert-principal token-address))
    (asserts! (is-eq (len recipient) u32) (err ERR-WRONG-RECIPIENT))
    (asserts! (is-eq (len destination) u4) (err ERR-WRONG-DESTINATION))
    (asserts! (> amount u0) (err ERR-AMOUNT-IS-ZERO))
    (try! (assert-token-exists-in-assets-map token-address))
    (ok true)
  )
)

;; Ensure unlock input is valid
(define-private 
  (assert-unlock-input
    (lock-id (buff 16))
    (recipient principal)
    (system-amount uint)
    (lock-source (buff 4))
    (token principal)
    (signature (buff 65))
  ) 
  (begin
    (asserts! (var-get is-bridge-enabled) (err ERR-BRIDGE-IS-DISABLED))
    (asserts! (is-eq VERSION (unwrap! (element-at lock-id u0) (err ERR-INTERNAL))) (err ERR-WRONG-VERSION))
    (asserts! (is-standard recipient) (err ERR-WRONG-RECIPIENT))
    (asserts! (> system-amount u0) (err ERR-AMOUNT-IS-ZERO))
    (asserts! (is-eq (len lock-source) u4) (err ERR-WRONG-LOCK-SOURCE))
    (try! (assert-principal token))
    (asserts! (or (is-eq (len signature) u65) (is-eq (len signature) u64)) (err ERR-WRONG-SIGNATURE-LENGTH))
    (ok true)
  )
)

(set-fee-collector 'SP3A8FDNDJK7N75AD8C49Y0B92TR47W3F6TMF9MV8)
(set-validator-public-key 0x02acd399d678d76d85cfc055e3b93ced1e883ed021de54c5707155f29b9f67933f)