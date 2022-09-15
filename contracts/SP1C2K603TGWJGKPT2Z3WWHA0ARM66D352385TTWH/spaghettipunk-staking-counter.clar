(define-constant ERR-NOT-AUTHORIZED u404)
(define-data-var admin principal tx-sender)
(define-data-var approved-contract principal (as-contract tx-sender))
(define-data-var removing-item-id uint u0)
(define-map staked-nfts { collection: principal } { ids: (list 5000 uint) })

(define-read-only (get-staked-nfts (collection principal))
    (default-to (list ) (get ids (map-get? staked-nfts {collection: collection}))))

(define-read-only (get-staked (collection principal))
    (len (get-staked-nfts collection)))

(define-public (set-staked (collection principal) (item uint) (switch bool))
    (let (
        (ids (get-staked-nfts collection))
    )
        (asserts! (or (is-eq contract-caller (var-get approved-contract)) (is-eq tx-sender (var-get admin))) (err ERR-NOT-AUTHORIZED))
        (if switch 
        (map-set staked-nfts { collection: collection} { ids: (unwrap-panic (as-max-len? (append ids item) u5000))})
        (begin 
            (var-set removing-item-id item)
            (map-set staked-nfts { collection: collection} { ids: (filter remove-item-id ids) })))
        (ok true)))

(define-private (remove-item-id (item-id uint))
  (if (is-eq item-id (var-get removing-item-id)) false true))

(define-public (approve-contract (contract principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set approved-contract contract))
    (err ERR-NOT-AUTHORIZED)))

(define-public (change-admin (address principal))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set admin address))
    (err ERR-NOT-AUTHORIZED)))