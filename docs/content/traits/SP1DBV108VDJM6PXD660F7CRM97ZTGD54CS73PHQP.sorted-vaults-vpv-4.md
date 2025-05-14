---
title: "Trait sorted-vaults-vpv-4"
draft: true
---
```
;; Vaults Sorted 
;; Keep vaults sorted based by vault interest rate ascending 
;;

(impl-trait .sorted-vaults-trait-vpv-4.sorted-vaults-trait)

;; ---------------------------------------------------------
;; Constants
;; ---------------------------------------------------------

(define-constant ERR_NOT_AUTHORIZED u960401)
(define-constant ERR_WRONG_POSITION u960001)
(define-constant ERR_VAULT_ALREADY_INSERTED u960002)
(define-constant ERR_VAULT_UNKNOWN u960003)

;; ---------------------------------------------------------
;; Variables
;; ---------------------------------------------------------

(define-data-var vaults-summary
    {
      first-vault-id: (optional uint),
      last-vault-id: (optional uint),
      total-vaults: uint
    }
    {
      first-vault-id: none,
      last-vault-id: none,
      total-vaults: u0
    }
)

;; ---------------------------------------------------------
;; Maps
;; ---------------------------------------------------------

(define-map vaults 
  uint 
  {
    prev-vault-id: (optional uint),
    next-vault-id: (optional uint),
    interest-rate: uint
  }
)

;; ---------------------------------------------------------
;; Getters
;; ---------------------------------------------------------

(define-read-only (get-vaults-summary)
  (ok (var-get vaults-summary))
)

(define-read-only (get-vault (vault-id uint))
  (map-get? vaults vault-id)
)

(define-read-only (has-access)
  (begin
    (try! (contract-call? .controller-vpv-4 is-protocol-caller contract-caller))
    (ok true)
  )
)

;; ---------------------------------------------------------
;; Find position
;; ---------------------------------------------------------

(define-read-only (get-prev-vault-id (vault-id (optional uint))) 
  (let (
    (prev-vault-id (if (is-some vault-id) (get prev-vault-id (get-vault (unwrap-panic vault-id))) none))
    (result (if (is-some prev-vault-id) (unwrap-panic prev-vault-id) none))
  )
    result
  )
)

(define-public (get-next-vault-id (vault-id (optional uint))) 
  (let (
    (next-vault-id (if (is-some vault-id) (get next-vault-id (get-vault (unwrap-panic vault-id))) none))
    (result (if (is-some next-vault-id) (unwrap-panic next-vault-id) none))
  )
    (ok result)
  )
)

;; Find the actual position given prev/next hints.
;; Hints are kept off chain. But the list can change within the same block.
;; So we use the prev/next hints to find the actual position. 
(define-read-only (find-position (vault-id uint) (interest-rate uint) (prev-vault-id-hint (optional uint)))
  (begin
    (let (
      (check-pos-1 (check-position vault-id interest-rate prev-vault-id-hint)) 
      (next-vault-id (unwrap-panic (get-next-vault-id prev-vault-id-hint)))
    ) (if (get correct check-pos-1) check-pos-1
    (let (
      (check-pos-2 (check-position vault-id interest-rate next-vault-id)) 
      (prev-vault-id-1 (get-prev-vault-id prev-vault-id-hint))
    ) (if (get correct check-pos-2) check-pos-2
    (let (
      (check-pos-3 (check-position vault-id interest-rate prev-vault-id-1)) 
      (next-vault-id-1 (unwrap-panic (get-next-vault-id next-vault-id)))
    ) (if (get correct check-pos-3) check-pos-3
    (let (
      (check-pos-4 (check-position vault-id interest-rate next-vault-id-1)) 
      (prev-vault-id-2 (get-prev-vault-id prev-vault-id-1))
    ) (if (get correct check-pos-4) check-pos-4
    (let (
      (check-pos-5 (check-position vault-id interest-rate prev-vault-id-2)) 
      (next-vault-id-2 (unwrap-panic (get-next-vault-id next-vault-id-1)))
    ) (if (get correct check-pos-5) check-pos-5
    (let (
      (check-pos-6 (check-position vault-id interest-rate next-vault-id-2)) 
      (prev-vault-id-3 (get-prev-vault-id prev-vault-id-2))
    ) (if (get correct check-pos-6) check-pos-6
    (let (
      (check-pos-7 (check-position vault-id interest-rate prev-vault-id-3)) 
      (next-vault-id-3 (unwrap-panic (get-next-vault-id next-vault-id-2)))
    ) (if (get correct check-pos-7) check-pos-7
    (let (
      (check-pos-8 (check-position vault-id interest-rate next-vault-id-3)) 
      (prev-vault-id-4 (get-prev-vault-id prev-vault-id-3))
    ) (if (get correct check-pos-8) check-pos-8
    (let (
      (check-pos-9 (check-position vault-id interest-rate prev-vault-id-4)) 
      (next-vault-id-4 (unwrap-panic (get-next-vault-id next-vault-id-3)))
    ) (if (get correct check-pos-9) check-pos-9
    (let (
      (check-pos-10 (check-position vault-id interest-rate next-vault-id-4))
    ) (if (get correct check-pos-10) check-pos-10

      { correct: false, first: false, last: false, prev: none, next: none }
    ))))))))))))))))))))
  )
)

;; Check if given position is correct
(define-read-only (check-position (vault-id uint) (interest-rate uint) (prev-vault-id (optional uint)))
  (let (
    (next-vault-id (unwrap-panic (get-next-vault-id prev-vault-id)))
  )
    ;; List empty - position always correct
    (if (and (is-none (get first-vault-id (var-get vaults-summary))) (is-none (get last-vault-id (var-get vaults-summary))))
      { correct: true, first: true, last: true, prev: none, next: none }

      (let (
        (first-vault-id (unwrap-panic (get first-vault-id (var-get vaults-summary))))
        (last-vault-id (unwrap-panic (get last-vault-id (var-get vaults-summary))))
      )
        ;; First element in list - check interest-rate first element
        (if (<= interest-rate (get interest-rate (unwrap-panic (get-vault first-vault-id))))
          { correct: true, first: true, last: false, prev: none, next: (some first-vault-id) }

          ;; Last element in list - check interest-rate last element
          (if (>= interest-rate (get interest-rate (unwrap-panic (get-vault last-vault-id))))
            { correct: true, first: false, last: true, prev: (some last-vault-id), next: none }

            ;; Middle element in list - check given prev/next
            (if (and 
              (is-some prev-vault-id) 
              (is-some next-vault-id) 
              (<= (get interest-rate (unwrap-panic (get-vault (unwrap-panic prev-vault-id)))) interest-rate) 
              (>= (get interest-rate (unwrap-panic (get-vault (unwrap-panic next-vault-id)))) interest-rate) 
            )
              { correct: true, first: false, last: false, prev: prev-vault-id, next: next-vault-id }

              ;; None of the above - wrong position
              { correct: false, first: false, last: false, prev: none, next: none }
            )
          )
        )
      )
    )
  )
)

;; ---------------------------------------------------------
;; Update list
;; ---------------------------------------------------------

;; Insert new vault in list
;; Given prev/next hints
(define-public (insert (vault-id uint) (interest-rate uint) (prev-vault-id-hint (optional uint)))
  (let (
    (token-info (var-get vaults-summary))

    (position-find (find-position vault-id interest-rate prev-vault-id-hint))
    (prev-vault-id (get prev position-find))
    (next-vault-id (get next position-find))
  )
    (try! (contract-call? .controller-vpv-4 is-protocol-caller contract-caller))
    (asserts! (get correct position-find) (err ERR_WRONG_POSITION))
    (asserts! (is-none (get-vault vault-id)) (err ERR_VAULT_ALREADY_INSERTED))

    ;; Add new vault
    (map-set vaults vault-id { prev-vault-id: prev-vault-id, next-vault-id: next-vault-id, interest-rate: interest-rate })

    ;; Update prev/next vault
    (if (is-some prev-vault-id)
      (map-set vaults (unwrap-panic prev-vault-id)
        (merge (unwrap-panic (get-vault (unwrap-panic prev-vault-id))) { next-vault-id: (some vault-id) })
      )
      false
    )
    (if (is-some next-vault-id)
      (map-set vaults (unwrap-panic next-vault-id)
        (merge (unwrap-panic (get-vault (unwrap-panic next-vault-id))) { prev-vault-id: (some vault-id) })
      )
      false
    )

    (var-set vaults-summary
      {
        first-vault-id: (if (get first position-find) (some vault-id) (get first-vault-id (var-get vaults-summary))), 
        last-vault-id: (if (get last position-find) (some vault-id) (get last-vault-id (var-get vaults-summary))), 
        total-vaults: (+ (get total-vaults token-info) u1) 
      }
    )

    (print { vaults-list-insert-info: { vault-id: vault-id, interest-rate: interest-rate, prev-vault-id: prev-vault-id, next-vault-id: next-vault-id }})

    ;; Return vaults summary
    (ok (var-get vaults-summary))
  )
)

;; Reinsert vault in list
(define-public (reinsert (vault-id uint) (interest-rate uint) (prev-vault-id-hint (optional uint)))
  (begin
    (try! (remove vault-id))
    (insert vault-id interest-rate prev-vault-id-hint)
  )
)

;; Remove vault from list
(define-public (remove (vault-id uint))
  (let (
    (vault (get-vault vault-id))
    (prev-vault (get prev-vault-id (unwrap! vault (err ERR_VAULT_UNKNOWN))))
    (next-vault (get next-vault-id (unwrap! vault (err ERR_VAULT_UNKNOWN))))
  )
    
    (try! (contract-call? .controller-vpv-4 is-protocol-caller contract-caller))

    ;; Update prev vault
    (if (is-some prev-vault)
      (let (
        (prev-vault-id (unwrap-panic prev-vault))
      )
        (map-set vaults prev-vault-id 
          (merge (unwrap-panic (get-vault prev-vault-id)) { next-vault-id: next-vault })
        )
      )

      (var-set vaults-summary (merge (var-get vaults-summary) { first-vault-id: next-vault }))
    )

    ;; Update next vault
    (if (is-some next-vault)
      (let (
        (next-vault-id (unwrap-panic next-vault))
      )
        (map-set vaults next-vault-id 
          (merge (unwrap-panic (get-vault next-vault-id)) { prev-vault-id: prev-vault })
        )
      )

      (var-set vaults-summary (merge (var-get vaults-summary) { last-vault-id: prev-vault }))
    )

    ;; Remove from map
    (map-delete vaults vault-id)

    (if (is-eq (get total-vaults (var-get vaults-summary)) u1)
      ;; Remove last vault
      (var-set vaults-summary { total-vaults: u0, first-vault-id: none, last-vault-id: none })
      ;; Remove vault
      (var-set vaults-summary (merge (var-get vaults-summary) { total-vaults: (- (get total-vaults (var-get vaults-summary)) u1) }))
    )

    (print { vaults-list-remove-info: { vault-id: vault-id }})

    ;; Return vaults summary
    (ok (var-get vaults-summary))
  )
)
```
