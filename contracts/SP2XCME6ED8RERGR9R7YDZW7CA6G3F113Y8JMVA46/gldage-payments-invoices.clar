;; title: aibtcdev-payments
;; version: 1.0.0
;; summary: An extension that provides payment processing for aibtcdev services.

;; traits
;;
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.invoices)
(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.resources)

;; constants
;;

;; initially scoped to service provider deploying a contract
(define-constant SELF (as-contract tx-sender))

;; errors
(define-constant ERR_UNAUTHORIZED (err u5000))
(define-constant ERR_INVALID_PARAMS (err u5001))
(define-constant ERR_NAME_ALREADY_USED (err u5002))
(define-constant ERR_SAVING_RESOURCE_DATA (err u5003))
(define-constant ERR_DELETING_RESOURCE_DATA (err u5004))
(define-constant ERR_RESOURCE_NOT_FOUND (err u5005))
(define-constant ERR_RESOURCE_DISABLED (err u5006))
(define-constant ERR_USER_ALREADY_EXISTS (err u5007))
(define-constant ERR_SAVING_USER_DATA (err u5008))
(define-constant ERR_USER_NOT_FOUND (err u5009))
(define-constant ERR_INVOICE_ALREADY_PAID (err u5010))
(define-constant ERR_SAVING_INVOICE_DATA (err u5011))
(define-constant ERR_INVOICE_NOT_FOUND (err u5012))
(define-constant ERR_RECENT_PAYMENT_NOT_FOUND (err u5013))

;; data vars
;;

;; tracking counts for each map
(define-data-var userCount uint u0)
(define-data-var resourceCount uint u0)
(define-data-var invoiceCount uint u0)

;; tracking overall contract revenue
(define-data-var totalRevenue uint u0)

;; dao can update payment address
(define-data-var paymentAddress principal 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.gldage-bank-account)

;; data maps
;;

;; tracks user indexes by address
(define-map UserIndexes
  principal ;; user address
  uint      ;; user index
)

;; tracks full user data keyed by user index
;; can iterate over full map with userCount data-var
(define-map UserData
  uint ;; user index
  {
    address: principal,
    totalSpent: uint,
    totalUsed: uint,
  }
)

;; tracks resource indexes by resource name
(define-map ResourceIndexes
  (string-utf8 50) ;; resource name
  uint             ;; resource index
)

;; tracks resources added by dao, keyed by resource index
;; can iterate over full map with resourceCount data-var
(define-map ResourceData
  uint ;; resource index
  {
    createdAt: uint,
    enabled: bool,
    name: (string-utf8 50),
    description: (string-utf8 255),
    price: uint,
    totalSpent: uint,
    totalUsed: uint,
    url: (optional (string-utf8 255)),
  }
)

;; tracks invoices paid by users requesting access to a resource
(define-map InvoiceData
  uint ;; invoice count
  {
    amount: uint,
    createdAt: uint,
    userIndex: uint,
    resourceName: (string-utf8 50),
    resourceIndex: uint,
  }
)

;; tracks last payment from user for a resource
(define-map RecentPayments
  {
    userIndex: uint,
    resourceIndex: uint,
  }
  uint ;; invoice count
)

;; public functions
;;

(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)

;; sets payment address used for invoices
(define-public (set-payment-address (newAddress principal))
  (begin
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; check that new address differs from current address
    (asserts! (not (is-eq newAddress (var-get paymentAddress))) ERR_UNAUTHORIZED)   
    ;; print details
    (print {
      notification: "set-payment-address",
      payload: {
        contractCaller: contract-caller,
        oldAddress: (var-get paymentAddress),
        newAddress: newAddress,
        txSender: tx-sender,
      }
    })
    ;; set new payment address
    (ok (var-set paymentAddress newAddress))
  )
)

;; adds active resource that invoices can be generated for
(define-public (add-resource (name (string-utf8 50)) (description (string-utf8 255)) (price uint) (url (optional (string-utf8 255))))
  (let
    (
      (newCount (+ (get-total-resources) u1))
    )
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; check all values are provided
    (asserts! (> (len name) u0) ERR_INVALID_PARAMS)
    (asserts! (> (len description) u0) ERR_INVALID_PARAMS)
    (asserts! (> price u0) ERR_INVALID_PARAMS)
    (and (is-some url) (asserts! (> (len (unwrap-panic url)) u0) ERR_INVALID_PARAMS))
    ;; update ResourceIndexes map, check name is unique
    (asserts! (map-insert ResourceIndexes name newCount) ERR_NAME_ALREADY_USED)
    ;; update ResourceData map
    (asserts! (map-insert ResourceData
      newCount
      {
        createdAt: burn-block-height,
        enabled: true,
        name: name,
        description: description,
        price: price,
        totalSpent: u0,
        totalUsed: u0,
        url: url,
      }
    ) ERR_SAVING_RESOURCE_DATA)
    ;; increment resourceCount
    (var-set resourceCount newCount)
    ;; print details
    (print {
      notification: "add-resource",
      payload: {
        contractCaller: contract-caller,
        resourceData: (unwrap! (get-resource newCount) ERR_RESOURCE_NOT_FOUND),
        resourceIndex: newCount,
        txSender: tx-sender
      }
    })
    ;; return new count
    (ok newCount)
  )
)

;; toggles enabled status for resource
(define-public (toggle-resource (resourceIndex uint))
  (let
    (
      (resourceData (unwrap! (get-resource resourceIndex) ERR_RESOURCE_NOT_FOUND))
      (newStatus (not (get enabled resourceData)))
    )
    ;; verify resource > 0
    (asserts! (> resourceIndex u0) ERR_INVALID_PARAMS)
    ;; check if caller is authorized
    (try! (is-dao-or-extension))
    ;; update ResourceData map
    (map-set ResourceData
      resourceIndex
      (merge resourceData {
        enabled: newStatus
      })
    )
    ;; print details
    (print {
      notification: "toggle-resource",
      payload: {
        resourceIndex: resourceIndex,
        resourceData: (unwrap! (get-resource resourceIndex) ERR_RESOURCE_NOT_FOUND),
        txSender: tx-sender,
        contractCaller: contract-caller
      }
    })
    ;; return based on set status
    (ok newStatus)
  )
)

;; toggles enabled status for resource by name
(define-public (toggle-resource-by-name (name (string-utf8 50)))
  (toggle-resource (unwrap! (get-resource-index name) ERR_RESOURCE_NOT_FOUND))
)

;; allows a user to pay an invoice for a resource
(define-public (pay-invoice (resourceIndex uint) (memo (optional (buff 34))))
  (let
    (
      (newCount (+ (get-total-invoices) u1))
      (lastAnchoredBlock (- burn-block-height u1))
      (resourceData (unwrap! (get-resource resourceIndex) ERR_RESOURCE_NOT_FOUND))
      (userIndex (unwrap! (get-or-create-user contract-caller) ERR_USER_NOT_FOUND))
      (userData (unwrap! (get-user-data userIndex) ERR_USER_NOT_FOUND))
    )
    ;; check that resourceIndex is > 0
    (asserts! (> resourceIndex u0) ERR_INVALID_PARAMS)
    ;; check that resource is enabled
    (asserts! (get enabled resourceData) ERR_RESOURCE_DISABLED)
    ;; update InvoiceData map
    (asserts! (map-insert InvoiceData
      newCount
      {
        amount: (get price resourceData),
        createdAt: burn-block-height,
        userIndex: userIndex,
        resourceName: (get name resourceData),
        resourceIndex: resourceIndex,
      }
    ) ERR_SAVING_INVOICE_DATA)
    ;; update RecentPayments map
    (map-set RecentPayments
      {
        userIndex: userIndex,
        resourceIndex: resourceIndex,
      }
      newCount
    )
    ;; update UserData map
    (map-set UserData
      userIndex
      (merge userData {
        totalSpent: (+ (get totalSpent userData) (get price resourceData)),
        totalUsed: (+ (get totalUsed userData) u1)
      })
    )
    ;; update ResourceData map
    (map-set ResourceData
      resourceIndex
      (merge resourceData {
        totalSpent: (+ (get totalSpent resourceData) (get price resourceData)),
        totalUsed: (+ (get totalUsed resourceData) u1)
      })
    )
    ;; update total revenue
    (var-set totalRevenue (+ (var-get totalRevenue) (get price resourceData)))
    ;; increment counter
    (var-set invoiceCount newCount)
    ;; print details
    (print {
      notification: "pay-invoice",
      payload: {
        contractCaller: contract-caller,
        invoiceData: (unwrap! (get-invoice newCount) ERR_INVOICE_NOT_FOUND),
        invoiceIndex: newCount,
        recentPayment: (unwrap! (get-recent-payment resourceIndex userIndex) ERR_RECENT_PAYMENT_NOT_FOUND),
        resourceData: (unwrap! (get-resource resourceIndex) ERR_RESOURCE_NOT_FOUND),
        resourceIndex: resourceIndex,
        totalRevenue: (var-get totalRevenue),
        txSender: tx-sender,
        userIndex: userIndex,
        userData: (unwrap! (get-user-data userIndex) ERR_USER_NOT_FOUND)
      }
    })
    ;; make transfer
    (if (is-some memo)
      (try! (stx-transfer-memo? (get price resourceData) contract-caller (var-get paymentAddress) (unwrap-panic memo)))
      (try! (stx-transfer? (get price resourceData) contract-caller (var-get paymentAddress)))
    )
    ;; return new count
    (ok newCount)
  )
)

(define-public (pay-invoice-by-resource-name (name (string-utf8 50)) (memo (optional (buff 34))))
  (pay-invoice (unwrap! (get-resource-index name) ERR_RESOURCE_NOT_FOUND) memo)
)


;; read only functions
;;

;; returns total registered users
(define-read-only (get-total-users)
  (var-get userCount)
)

;; returns user index for address if known
(define-read-only (get-user-index (user principal))
  (map-get? UserIndexes user)
)

;; returns user data by user index if known
(define-read-only (get-user-data (index uint))
  (map-get? UserData index)
)

;; returns user data by address if known
(define-read-only (get-user-data-by-address (user principal))
  (get-user-data (unwrap! (get-user-index user) none))
)

;; returns total registered resources
(define-read-only (get-total-resources)
  (var-get resourceCount)
)

;; returns resource index for name if known
(define-read-only (get-resource-index (name (string-utf8 50)))
  (map-get? ResourceIndexes name)
)

;; returns resource data by resource index if known
(define-read-only (get-resource (index uint))
  (map-get? ResourceData index)
)

;; returns resource data by resource name if known
(define-read-only (get-resource-by-name (name (string-utf8 50)))
  (get-resource (unwrap! (get-resource-index name) none))
)

;; returns total registered invoices
(define-read-only (get-total-invoices)
  (var-get invoiceCount)
)

;; returns invoice data by invoice index if known
(define-read-only (get-invoice (index uint))
  (map-get? InvoiceData index)
)

;; returns invoice index by user index and resource index if known
(define-read-only (get-recent-payment (resourceIndex uint) (userIndex uint))
  (map-get? RecentPayments {
    userIndex: userIndex,
    resourceIndex: resourceIndex,
  })
)

;; returns invoice data by user index and resource index if known
(define-read-only (get-recent-payment-data (resourceIndex uint) (userIndex uint))
  (get-invoice (unwrap! (get-recent-payment resourceIndex userIndex) none))
)

;; returns invoice data by user address and resource name if known
(define-read-only (get-recent-payment-data-by-address (name (string-utf8 50)) (user principal))
  (get-recent-payment-data (unwrap! (get-resource-index name) none) (unwrap! (get-user-index user) none))
)

;; returns payment address
(define-read-only (get-payment-address)
  (some (var-get paymentAddress))
)

;; returns total revenue
(define-read-only (get-total-revenue)
  (var-get totalRevenue)
)

;; returns aggregate contract data
(define-read-only (get-contract-data)
  {
    paymentAddress: (get-payment-address),
    totalInvoices: (get-total-invoices),
    totalResources: (get-total-resources),
    totalRevenue: (get-total-revenue),
    totalUsers: (get-total-users)
  }
)

;; private functions
;;

(define-private (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.gldage-base-dao)
    (contract-call? 'SP2XCME6ED8RERGR9R7YDZW7CA6G3F113Y8JMVA46.gldage-base-dao is-extension contract-caller)) ERR_UNAUTHORIZED
  ))
)

(define-private (get-or-create-user (address principal))
  (match (map-get? UserIndexes address)
    value (ok value) ;; return index if found
    (let
      (
        ;; increment current index
        (newCount (+ (get-total-users) u1))
      )
      ;; update UserIndexes map, check address is unique
      (asserts! (map-insert UserIndexes address newCount) ERR_USER_ALREADY_EXISTS)
      ;; update UserData map
      (asserts! (map-insert UserData 
        newCount
        {
          address: address,
          totalSpent: u0,
          totalUsed: u0,
        }
      ) ERR_SAVING_USER_DATA)
      ;; save new index
      (var-set userCount newCount)
      ;; return new index
      (ok newCount)
    )
  )
)
