(use-trait fund-registry-trait .fund-registry-trait-v1-1.fund-registry-trait)

;; 
;; Constants
;; 

(define-constant ERR_FUND_NOT_FOUND (err u20001))
(define-constant ERR_INVALID_TX (err u20002))
(define-constant ERR_TX_NOT_MINED (err u20003))
(define-constant ERR_WRONG_SENDER (err u20004))
(define-constant ERR_WRONG_RECEIVER (err u20005))
(define-constant ERR_TX_ALREADY_ADDED (err u20006))

;; 
;; Maps
;; 

(define-map user-fund-funding 
  {
    fund-id: uint,
    user-address: (buff 33)   ;; address before encoding
  }
  uint
)

(define-map total-fund-funding uint uint)

(define-map tx-parsed (buff 1024) bool)

;; 
;; Getters
;; 

(define-read-only (get-user-fund-funding (fund-id uint) (user-address (buff 33)))
  (default-to 
    u0
    (map-get? user-fund-funding { fund-id: fund-id, user-address: user-address })
  )
)

(define-read-only (get-total-fund-funding (fund-id uint))
  (default-to 
    u0
    (map-get? total-fund-funding fund-id)
  )
)

(define-read-only (get-tx-parsed (tx (buff 1024)))
  (default-to 
    false
    (map-get? tx-parsed tx)
  )
)

;; 
;; Parse
;; 

(define-public (add-user-funding
  (fund-registry <fund-registry-trait>)
  (block { header: (buff 80), height: uint })
  (prev-blocks (list 10 (buff 80)))
  (tx (buff 1024))
  (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
  (sender-index uint)
  (receiver-index uint)
  (sender-address (buff 33))
  (receiver-address (buff 33))
)
  (let (
    (sats (try! (parse-and-validate-tx block prev-blocks tx proof sender-index receiver-index sender-address receiver-address)))
    (fund-id (unwrap! (unwrap! (contract-call? fund-registry get-fund-id-by-address receiver-address) ERR_FUND_NOT_FOUND) ERR_FUND_NOT_FOUND))
    (current-total (get-total-fund-funding fund-id))
    (current-user-total (get-user-fund-funding fund-id sender-address))
  )
    (try! (contract-call? .main check-is-enabled))
    (asserts! (not (get-tx-parsed tx)) ERR_TX_ALREADY_ADDED)

    (map-set total-fund-funding fund-id (+ current-total sats))
    (map-set user-fund-funding { fund-id: fund-id, user-address: sender-address } (+ current-user-total sats))
    (map-set tx-parsed tx true)
    (ok sats)
  )
)

(define-read-only (parse-and-validate-tx 
  (block { header: (buff 80), height: uint })
  (prev-blocks (list 10 (buff 80)))
  (tx (buff 1024))
  (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint })
  (sender-index uint)
  (receiver-index uint)
  (sender-address (buff 33))
  (receiver-address (buff 33))
)
  (let (
    (was-mined (try! (contract-call? .clarity-bitcoin was-tx-mined-prev? block prev-blocks tx proof)))
    (parsed-tx (try! (contract-call? .clarity-bitcoin parse-tx tx)))

    (sender (unwrap! (element-at (get outs parsed-tx) sender-index) ERR_INVALID_TX))
    (receiver (unwrap! (element-at (get outs parsed-tx) receiver-index) ERR_INVALID_TX))
  )
    (asserts! was-mined ERR_TX_NOT_MINED)
    (asserts! (is-eq sender-address (get scriptPubKey sender)) ERR_WRONG_SENDER)
    (asserts! (is-eq receiver-address (get scriptPubKey receiver)) ERR_WRONG_RECEIVER)

    (ok (get value receiver))
  )
)
