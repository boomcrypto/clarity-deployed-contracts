(use-trait collection-contract .nft-trait.nft-trait)

(impl-trait .bitgear-traits-v0.character-trait)

(define-constant NOT-AUTHORIZED     u401)
(define-constant MAX-PLAYERS        u402)
(define-constant NOT-WHITELISTED    u403)
(define-constant NOT-FOUND          u404)

(define-constant contract-owner tx-sender)
(define-data-var dungeon-master principal tx-sender)

(define-map collections { address: principal }
  {
    players: (list 1000 principal)
  }
)

(define-map characters { address: principal }
  {
    name: (string-utf8 16),
    collection: principal,
    avatar: uint
  }
)

(define-public (add-collection (collection <collection-contract>))
  (if (is-eq (var-get dungeon-master) tx-sender)
    (ok (map-insert collections { address: (contract-of collection) } {players: (list)}))
    (err NOT-AUTHORIZED)
  )
)

(define-public (remove-collection (collection <collection-contract>))
  (if (is-eq (var-get dungeon-master) tx-sender)
    (ok (map-delete collections { address: (contract-of collection) }))
    (err NOT-AUTHORIZED)
  )
)

(define-public (roll-character (character-name (string-utf8 16)) (collection <collection-contract>) (token-id uint))
  (let (
    (pc-collections (unwrap! (map-get? collections { address: (contract-of collection) }) (err NOT-WHITELISTED)))
    (player-list (get players pc-collections))
  ) 
    (try! (get-player-list collection))
    (try! (is-owner collection token-id))
    (asserts! (< (len player-list) u1000) (err MAX-PLAYERS))
    (asserts! (map-insert characters { address: tx-sender } { 
      name: character-name,
      collection: (contract-of collection),
      avatar: token-id
    }) (err NOT-AUTHORIZED))
    (ok 
      (map-set collections { address: (contract-of collection) } {
        players: (unwrap-panic (as-max-len? (append player-list tx-sender) u1000))
      })
    )
  )
)

(define-read-only (get-character (address principal))
  (ok 
    (unwrap! (map-get? characters { address: address }) (err NOT-FOUND))
  )
)

(define-read-only (get-player-list (collection <collection-contract>))
  (let (
    (pc-collections (unwrap! (map-get? collections { address: (contract-of collection) }) (err NOT-WHITELISTED)))
    (player-list (get players pc-collections))
  ) 
    (ok player-list)
  )
)

(define-private (is-owner (collection <collection-contract>) (id uint)) 
  (ok 
    (asserts! 
      (is-eq 
        (unwrap! (unwrap-panic (as-contract (contract-call? collection get-owner id))) (err NOT-FOUND))
        tx-sender
      )
      (err NOT-AUTHORIZED)
    )
  )
)

(define-public (bestow (new-dm principal))
  (if (is-eq tx-sender contract-owner)
    (ok (var-set dungeon-master new-dm))
    (err NOT-AUTHORIZED)
  )
)