;; Two traits pool contracts should implement
;;
;; The genesis pox contract implements pool-trait
;; Pools that run as a contract can implement pool-trait-ext with additional information from the user
(define-trait pool-trait ((delegate-stx (uint principal (optional uint)
              (optional (tuple (hashbytes (buff 20)) (version (buff 1))))) (response bool int))))
(define-trait pool-trait-ext ((delegate-stx (uint principal (optional uint)
              (optional (tuple (hashbytes (buff 20)) (version (buff 1))))
              (tuple (hashbytes (buff 20)) (version (buff 1)))
              uint) (response bool int))))
(define-trait pool-trait-ext2 ((delegate-stx (uint principal (optional uint)
              (optional (tuple (hashbytes (buff 20)) (version (buff 1))))
              (tuple (hashbytes (buff 20)) (version (buff 1)))
              uint) (response bool {kind: (string-ascii 32), code: uint}))))

(define-constant ERR_INVALID_PAYOUT u1)
(define-constant ERR_INVALID_STATUS u2)
(define-constant ERR_NAME_REGISTERED u3)
(define-constant ERR_NATIVE_FUNCTION_FAILED u4)
(define-constant ERR_NAME_NOT_ON_CHAIN u5)
(define-constant ERR_REGISTRATION u6)
(define-constant ERR_NAME_PRICE u7)
(define-constant ERR_PERMISSION_DENIED u403)
(define-constant ERR_NAME_NOT_REGISTERED u404)


;; list of registered pools
(define-map registry 
   uint
   (tuple 
      (name (tuple (namespace (buff 20)) (name (buff 48))))
      (delegatee principal)
      (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
      (url (string-ascii 250))
      (contract (optional principal))
      (extended-contract (optional principal))
      (extended2-contract (optional principal))
      (minimum-ustx (optional uint))
      (locking-period (list 12 uint))
      (payout (string-ascii 5))
      (date-of-payout (string-ascii 80))
      (fees (string-ascii 80))
      (status uint)))

;; list of means of payout
(define-map payouts
   (string-ascii 5)
   (tuple 
      (name (string-ascii 80) )
   ))

(define-map statuses
   uint
   (string-ascii 80)
)

(define-map lookup
   principal
   uint)
   
(define-data-var last-id uint u0)

(define-private (get-id? (delegatee principal))
   (map-get? lookup delegatee))

(define-private (get-owner (name (tuple (namespace (buff 20)) (name (buff 48)))))
   (match (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve (get namespace name) (get name name))
      entry (some (get owner entry))
      error none))

(define-private (can-register (name (tuple (namespace (buff 20)) (name (buff 48)))))
   (match (contract-call? 'SP000000000000000000002Q6VF78.bns can-name-be-registered  (get namespace name) (get name name))
      result result
      error false))

(define-private (can-receive-name (user principal))
 (match (contract-call? 'SP000000000000000000002Q6VF78.bns can-receive-name user)
      result result
      error false))

(define-private (register-name (name (tuple (namespace (buff 20)) (name (buff 48)))) (user principal))
   (match (print (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder (hash160 (concat (concat (concat (get name name) 0x2e) (get namespace name)) 0x00)) (unwrap! (get-name-price name) (err ERR_NAME_PRICE))))
      result-preorder
         (match (print (contract-call? 'SP000000000000000000002Q6VF78.bns name-register  (get namespace name) (get name name) 0x00 0x00 ))
            result-register (ok true)
            error (err (to-uint error)))
      error (err (to-uint error))))

(define-private (get-name-price (name (tuple (namespace (buff 20)) (name (buff 48)))))
   (print (contract-call? 'SP000000000000000000002Q6VF78.bns get-name-price (get namespace name) (get name name))))



(define-private (to-response (success bool))
   (if success
      (ok true)
      (err ERR_NATIVE_FUNCTION_FAILED)))


(define-public (add-payout (symbol (string-ascii 5)) (name (string-ascii 80)))
   (ok (map-insert payouts symbol {name: name})))

(define-public (add-status (status uint) (name (string-ascii 80)))
   (ok (map-insert statuses status name)))

;; register a new pool that implements the simple pool trait like genesis "pox" contract.
(define-public (register (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-register name delegatee pox-address url (some (contract-of contract)) none none minimum-ustx locking-period payout date-of-payout fees status))

;; register a new pool that implements the extended pool trait
(define-public (register-ext (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait-ext>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-register name delegatee pox-address url none (some (contract-of contract)) none minimum-ustx locking-period payout date-of-payout fees status))

;; register a new pool that implements the extended pool trait 2
(define-public (register-ext2 (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait-ext2>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-register name delegatee pox-address url none none (some (contract-of contract)) minimum-ustx locking-period payout date-of-payout fees status))

(define-private (base-register (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract (optional principal))
                           (extended-contract (optional principal))
                           (extended2-contract (optional principal))
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
  (let ((id (+ (get-last-id) u1)))
      (unwrap! (map-get? payouts payout) (err ERR_INVALID_PAYOUT))
      (unwrap! (map-get? statuses status) (err ERR_INVALID_STATUS))
      (match (get-owner name)
         owner (asserts! (is-eq tx-sender owner) (err ERR_PERMISSION_DENIED))
         (begin
            (asserts! (and (can-receive-name tx-sender) (can-register name))  (err ERR_NAME_NOT_ON_CHAIN))
            (unwrap! (register-name name tx-sender) (err ERR_REGISTRATION))))
      (if (is-none (map-get? lookup delegatee))
         (begin         
            (var-set last-id id) 
            (map-insert registry id 
               {name: name,
               delegatee: delegatee,
               pox-address: pox-address,
               url: url, 
               contract: contract,
               extended-contract: extended-contract,
               extended2-contract: extended2-contract,
               minimum-ustx: minimum-ustx,
               locking-period: locking-period,
               payout: payout,
               date-of-payout: date-of-payout,
               fees: fees,
               status: status})
            (map-insert lookup delegatee id)
            (ok id))
         (err ERR_NAME_REGISTERED))))

(define-public (update (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-update name delegatee pox-address url (some (contract-of contract)) none none minimum-ustx locking-period payout date-of-payout fees status))

(define-public (update-ext (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait-ext>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-update name delegatee pox-address url none (some (contract-of contract)) none minimum-ustx locking-period payout date-of-payout fees status))

(define-public (update-ext2 (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract <pool-trait-ext2>)
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))
   (base-update name delegatee pox-address url none none (some (contract-of contract)) minimum-ustx locking-period payout date-of-payout fees status))

(define-private (base-update (name (tuple (namespace (buff 20)) (name (buff 48))))
                           (delegatee principal)
                           (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
                           (url (string-ascii 250))
                           (contract (optional principal))
                           (extended-contract (optional principal))
                           (extended2-contract (optional principal))
                           (minimum-ustx (optional uint))
                           (locking-period (list 12 uint))
                           (payout (string-ascii 5))
                           (date-of-payout (string-ascii 80))
                           (fees (string-ascii 80))
                           (status uint))

   (if (is-eq tx-sender (unwrap! (get-owner name) (err ERR_NAME_NOT_ON_CHAIN)))
      (let ((id (unwrap! (get-id? delegatee) (err ERR_NAME_NOT_REGISTERED))))
         (unwrap! (map-get? payouts payout) (err ERR_INVALID_PAYOUT))
         (unwrap! (map-get? statuses status) (err ERR_INVALID_STATUS))

         (to-response (map-set registry id
            {name: name, 
               delegatee: delegatee,
               pox-address: pox-address,
               url: url, 
               contract: contract,
               extended-contract: extended-contract,
               extended2-contract: extended2-contract,
               minimum-ustx: minimum-ustx,
               locking-period: locking-period,
               payout: payout,
               date-of-payout: date-of-payout,
               fees: fees,
               status: status})))
         
      (err ERR_PERMISSION_DENIED)))

(define-read-only (get-last-id) (var-get last-id))

(define-read-only (get-pool-by-delegatee (delegatee principal))
 (map-get? registry (unwrap! (get-id? delegatee) none)))

(define-read-only (get-pool (pool-id uint))
   (map-get? registry pool-id)
)

(define-private (add-registry-data (pool-id uint) (result (list 20 (optional (tuple
   (contract (optional principal))
   (delegatee principal)
   (extended-contract (optional principal))
   (extended2-contract (optional principal))
   (locking-period (list 12 uint))
   (minimum-ustx (optional uint))
   (name (tuple (name (buff 48)) (namespace (buff 20))))
   (payout (string-ascii 5))
   (pox-address (list 12 (tuple (hashbytes (buff 20)) (version (buff 1)))))
   (url (string-ascii 250))
   (date-of-payout (string-ascii 80))
   (fees (string-ascii 80))
   (status uint))))))
   (unwrap-panic (as-max-len? (append result (map-get? registry pool-id)) u20)))

(define-read-only (get-pools (pool-ids (list 20 uint)))
   (fold add-registry-data pool-ids (list)))

(add-payout "BTC" "Bitcoin")
(add-payout "STX" "Stacks")

(add-status u0 "in development")
(add-status u1 "in production")
(add-status u11 "open for stacking")
(add-status u21 "closed for stacking")
(add-status u99 "retired")
