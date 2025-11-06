;; title: aibtc-dao-users
;; version: 1.0.0
;; summary: An extension that tracks the current users and their reputation in the DAO.

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)
(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.dao-users)

;; constants
;;

;; contract details
(define-constant DEPLOYED_BURN_BLOCK burn-block-height)
(define-constant DEPLOYED_STACKS_BLOCK stacks-block-height)
(define-constant SELF (as-contract tx-sender))

;; error messages
(define-constant ERR_NOT_DAO_OR_EXTENSION (err u1500))
(define-constant ERR_USER_NOT_FOUND (err u1501))

;; data vars
;;

(define-data-var userCount uint u0) ;; total number of users

;; data maps
;;

;; central tracking for DAO users
(define-map UserIndexes
  principal
  uint
)
(define-map UserData
  uint ;; user index
  {
    address: principal,
    createdAt: uint,
    reputation: int, ;; increases/decreases from proposal bonds
  }
)

;; public functions
;;

(define-public (callback
    (sender principal)
    (memo (buff 34))
  )
  (ok true)
)

(define-public (get-or-create-user-index (address principal))
  (match (map-get? UserIndexes address)
    ;; user already exists, return the index
    value
    (ok value)
    ;; user does not exist, create a new one
    (let ((userIndex (+ u1 (var-get userCount))))
      (try! (is-dao-or-extension))
      (print {
        notification: "fake-dao-users/get-or-create-user-index",
        payload: {
          userIndex: userIndex,
          address: address,
          createdAt: burn-block-height,
          contractCaller: contract-caller,
          txSender: tx-sender,
        },
      })
      (map-insert UserIndexes address userIndex)
      (map-insert UserData userIndex {
        address: address,
        createdAt: burn-block-height,
        reputation: 0,
      })
      (var-set userCount userIndex)
      (ok userIndex)
    )
  )
)

(define-public (increase-user-reputation
    (address principal)
    (amount uint)
  )
  (let (
      (userIndex (unwrap! (get-user-index address) ERR_USER_NOT_FOUND))
      (userData (unwrap! (get-user-data-by-index userIndex) ERR_USER_NOT_FOUND))
      (increaseAmount (to-int amount))
    )
    (try! (is-dao-or-extension))
    (print {
      notification: "fake-dao-users/increase-user-reputation",
      payload: {
        userIndex: userIndex,
        address: address,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (map-set UserData userIndex
      (merge userData { reputation: (+ (get reputation userData) increaseAmount) })
    )
    (ok true)
  )
)

(define-public (decrease-user-reputation
    (address principal)
    (amount uint)
  )
  (let (
      (userIndex (unwrap! (get-user-index address) ERR_USER_NOT_FOUND))
      (userData (unwrap! (get-user-data-by-index userIndex) ERR_USER_NOT_FOUND))
      (decreaseAmount (to-int amount))
    )
    (try! (is-dao-or-extension))
    (print {
      notification: "fake-dao-users/decrease-user-reputation",
      payload: {
        userIndex: userIndex,
        address: address,
        contractCaller: contract-caller,
        txSender: tx-sender,
      },
    })
    (map-set UserData userIndex
      (merge userData { reputation: (- (get reputation userData) decreaseAmount) })
    )
    (ok true)
  )
)

;; read only functions
;;

;; returns the unique user count
(define-read-only (get-user-count)
  (var-get userCount)
)

;; returns (some data) if the user exists or none if unknown
(define-read-only (get-user-index (address principal))
  (map-get? UserIndexes address)
)

;; returns (some data) if the user exists or none if unknown
(define-read-only (get-user-data-by-index (userIndex uint))
  (map-get? UserData userIndex)
)

;; returns (some data) if the user exists or none if unknown
(define-read-only (get-user-data-by-address (address principal))
  (get-user-data-by-index (unwrap! (get-user-index address) none))
)

;; private functions
;;

;; returns ok if the caller is the DAO or an extension or err if not
(define-private (is-dao-or-extension)
  (ok (asserts!
    (or
      (is-eq tx-sender .fake-base-dao)
      (contract-call? .fake-base-dao is-extension contract-caller)
    )
    ERR_NOT_DAO_OR_EXTENSION
  ))
)
