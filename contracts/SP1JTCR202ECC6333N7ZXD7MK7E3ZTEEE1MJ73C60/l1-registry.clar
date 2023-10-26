(define-constant ERR_UNAUTHORIZED (err u4000))
(define-constant ERR_TRANSFER (err u1100))
(define-constant ERR_NOT_OWNED_BY_REGISTRY (err u1101))
(define-constant ERR_INVALID_NAME (err u1102))
(define-constant ERR_DUPLICATE_INSCRIPTION (err u1103))
(define-constant ERR_INSCRIPTION_NOT_REGISTERED (err u1104))

(define-map inscriptions-name-map (buff 35) uint)
(define-map name-inscriptions-map uint (buff 35))

(define-data-var extension-var principal .l1-bridge-v1)

(define-private (is-extension)
  (ok (asserts! (is-eq (var-get extension-var) contract-caller) ERR_UNAUTHORIZED))
)

;; Validation of caller
;; Move name into self
;; save inscription ID
(define-public (wrap (name-id uint) (owner principal) (inscription-id (buff 35)))
  (let
    (
      (self (as-contract tx-sender))
      (name-details (try! (validate-name-owned-by-registry name-id)))
    )
    ;; #[filter(inscription-id, name-id)]
    (try! (is-extension))
    (asserts! (map-insert name-inscriptions-map name-id inscription-id) ERR_DUPLICATE_INSCRIPTION)
    (asserts! (map-insert inscriptions-name-map inscription-id name-id) ERR_DUPLICATE_INSCRIPTION)
    (log-bridge-action "wrap" inscription-id owner name-details)
    (ok name-details)
  )
)

(define-public (unwrap (inscription-id (buff 35)) (recipient principal))
  (let
    (
      (name-id (unwrap! (map-get? inscriptions-name-map inscription-id) ERR_INSCRIPTION_NOT_REGISTERED))
      (name-details (try! (get-name-properties name-id)))
    )
    ;; #[filter(name-id, recipient, inscription-id)]
    (try! (is-extension))
    (map-delete name-inscriptions-map name-id)
    (map-delete inscriptions-name-map inscription-id)
    (unwrap-panic (as-contract (contract-call? .bnsx-registry transfer name-id tx-sender recipient)))
    (log-bridge-action "unwrap" inscription-id recipient name-details)
    (ok name-details)
  )
)

;; Getters

(define-read-only (get-inscription-id (name-id uint))
  (map-get? name-inscriptions-map name-id)
)

(define-read-only (get-name-id (inscription-id (buff 35)))
  (map-get? inscriptions-name-map inscription-id)
)

(define-read-only (get-inscription-name-properties (inscription-id (buff 35)))
  (get-name-properties (unwrap! (map-get? inscriptions-name-map inscription-id) ERR_INSCRIPTION_NOT_REGISTERED))
)

;; Validation

(define-read-only (validate-name-owned-by-registry (name-id uint))
  (let
    (
      (self (as-contract tx-sender))
      (name-details (try! (get-name-properties name-id)))
    )
    (asserts! (is-eq self (get owner name-details)) ERR_NOT_OWNED_BY_REGISTRY)
    (ok name-details)
  )
)

(define-read-only (get-name-properties (name-id uint))
  (ok (unwrap! (contract-call? .bnsx-registry get-name-properties-by-id name-id) ERR_INVALID_NAME)))

;; Logging

;; #[allow(unchecked_data)]
(define-private (log-bridge-action 
    (topic (string-ascii 10))
    (inscription-id (buff 35))
    (account principal)
    (name-details {
      id: uint,
      owner: principal,
      name: (buff 48),
      namespace: (buff 20),
    })
  )
  (print (merge { topic: topic, inscription-id: inscription-id, account: account } name-details))
)

;; Extension management

(define-public (update-extension (new-extension principal))
  (begin
    ;; #[filter(new-extension)]
    (try! (is-extension))
    (var-set extension-var new-extension)
    (ok new-extension)
  )
)

(define-read-only (get-extension) (var-get extension-var))