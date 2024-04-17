;; SupplyAfrica - A Clarity Smart Contract
;; Author: Christopher Perceptions
;; Presented at W3Africa 2024
;; To Africa, with love

;; Errors
(define-constant ERR_ITEM_NOT_FOUND u404)
(define-constant ERR_NOT_AUTHORIZED u403)

;; Maps
(define-map items
  { id: uint }
  { owner: principal, status: (string-ascii 64) }
)

;; Data Variables
(define-data-var item-counter uint u0)

;; Register an item with initial status
(define-public (register-item (status (string-ascii 64)))
  (let ((id (var-get item-counter)))
    (map-insert items { id: id } { owner: tx-sender, status: status })
    (var-set item-counter (+ id u1))
    (ok id)))

;; Update an item's status
(define-public (update-item-status (id uint) (new-status (string-ascii 64)))
  (match (map-get? items { id: id })
    item (if (is-eq (get owner item) tx-sender)
              (begin
                (map-set items { id: id } { owner: (get owner item), status: new-status })
                (ok true))
              (err ERR_NOT_AUTHORIZED))
    (err ERR_ITEM_NOT_FOUND)))

;; Retrieve an item's information
(define-public (get-item-information (id uint))
  (match (map-get? items { id: id })
    item (ok item)
    (err ERR_ITEM_NOT_FOUND)))

;; John 3:16-17
;; Romans 10:9-13 