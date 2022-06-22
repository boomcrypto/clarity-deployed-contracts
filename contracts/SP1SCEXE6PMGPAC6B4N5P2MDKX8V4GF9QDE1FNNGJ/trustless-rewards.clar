;; trustless-rewards


;; traits
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-NOT-ACTIVE (err u403))
(define-constant ERR-ALREADY-JOINED (err u405))
(define-constant ERR-JOIN-FAILED (err u500))
(define-constant OK-SUCCESS u200)
(define-constant DEFAULT-PRICE u100)

;; data maps and vars
(define-map lobbies {id: uint} {owner: principal, description: (string-ascii 99), balance: uint, price: uint, factor: uint, commission: uint, mapy: (string-ascii 30), length: (string-ascii 10), traffic: (string-ascii 10), curves: (string-ascii 10), hours: uint, active: bool})
(define-map scoreboard {lobby-id: uint, address: principal} {score: uint, rank: uint, sum-rank-factor: uint, rank-factor: uint, rewards: uint, rac: uint, nft: (string-ascii 99)})
(define-data-var lobby-count uint u0)
(define-data-var contract-owner principal tx-sender)

;; private functions
(define-private (increment-lobby-count)
  (begin
    (var-set lobby-count (+ (var-get lobby-count) u1))
    (var-get lobby-count)
  )
)

(define-private (add-balance (id uint) (participant principal) (amount uint))
  (begin
    (unwrap-panic (stx-transfer? amount participant (as-contract tx-sender)))
    (match
      (map-get? lobbies {id: id})
      lobby
      (map-set lobbies {id: id} (merge lobby {balance: (+ (default-to u0 (get balance (map-get? lobbies {id: id}))) amount)}))
      false
    )
  )
)


;; public functions
;; anyone can create a lobby
(define-public (create-lobby 
  (description (string-ascii 99)) (price uint) (factor uint) (commission uint) 
  (mapy (string-ascii 30)) (length (string-ascii 10)) (traffic (string-ascii 10)) (curves (string-ascii 10)) (hours uint) 
)
    (let (
        (lobby-id (increment-lobby-count))
        )
        ;; (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (map-set lobbies {id: lobby-id} 
          {
            owner: tx-sender, description: description, balance: u0, price: price, factor: factor, commission: commission, 
            mapy: mapy, length: length, traffic: traffic, curves: curves, hours: hours, active: true
          }
        )
        (try! (join lobby-id))
        (ok lobby-id)
    )
)

(define-read-only (get-lobby (id uint))
    (ok (unwrap-panic (map-get? lobbies {id: id})))
)

;; anyone can join a lobby
(define-public (join (id uint))
    (let (
        (entry-price (default-to DEFAULT-PRICE (get price (map-get? lobbies {id: id}))))
        (joined (map-insert scoreboard {lobby-id: id, address: tx-sender} {score: u0, rank: u0, sum-rank-factor: u0, rank-factor: u0, rewards: u0, rac: u0, nft: ""}))
        )
        (unwrap-panic (map-get? lobbies {id: id}))
        (asserts! (default-to false (get active (map-get? lobbies {id: id}))) ERR-NOT-ACTIVE)
        (asserts! joined ERR-ALREADY-JOINED)
        (add-balance id tx-sender entry-price)
        (print {action: "join", lobby-id: id, address: tx-sender })
        (ok OK-SUCCESS)
    )
)

(define-public (disable-lobby (id uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (match
        (map-get? lobbies {id: id})
        lobby
        (map-set lobbies {id: id} (merge lobby {active: false}))
        false
        )
        (ok true)
    )
)

(define-read-only (get-score (lobby-id uint) (address principal))
    (ok (unwrap-panic (map-get? scoreboard {lobby-id: lobby-id, address: address})))
)

;; PUBLISH-MANY
(define-public (publish-result-many (run-result (list 50 { lobby-id: uint, address: principal, score: uint, rank: uint, sum-rank-factor: uint, rank-factor: uint, rewards: uint, rac: uint, nft: (string-ascii 99)})))
  (fold check-err
    (map publish-result run-result)
    (ok true)
  )
)
(define-private (publish-result (run-result { lobby-id: uint, address: principal, score: uint, rank: uint, sum-rank-factor: uint, rank-factor: uint, rewards: uint, rac: uint, nft: (string-ascii 99)}))
  (publish-only (get lobby-id run-result) (get address run-result) (get score run-result) (get rank run-result) (get sum-rank-factor run-result) (get rank-factor run-result) (get rewards run-result) (get rac run-result) (get nft run-result))
)
(define-private (publish-only (lobby-id uint) (address principal) (score uint) (rank uint) (sum-rank-factor uint) (rank-factor uint) (rewards uint) (rac uint) (nft (string-ascii 99)))
  (let
    (
      (publishOk (try! (publish lobby-id address score rank sum-rank-factor rank-factor rewards rac nft)))
    )
    (ok publishOk)
  )
)
(define-private (publish (lobby-id uint) (address principal) (score uint) (rank uint) (sum-rank-factor uint) (rank-factor uint) (rewards uint) (rac uint) (nft (string-ascii 99)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (unwrap-panic (map-get? scoreboard {lobby-id: lobby-id, address: address}))
        (asserts! (default-to false (get active (map-get? lobbies {id: lobby-id}))) ERR-NOT-ACTIVE)
        (map-set scoreboard {lobby-id: lobby-id, address: address} {score: score, rank: rank, sum-rank-factor: sum-rank-factor, rank-factor: rank-factor, rewards: rewards, rac: rac, nft: nft})
        (print {action: "publish", lobby-id: lobby-id, address: address, score: score, rank: rank, sum-rank-factor: sum-rank-factor, rank-factor: rank-factor, rewards: rewards, rac: rac, nft: nft})
        (ok true)
    )
)


(define-public (finish-result-many  (run-result (list 50 { lobby-id: uint, address: principal, score: uint, rank: uint, sum-rank-factor: uint, rank-factor: uint, rewards: uint, rac: uint, nft: (string-ascii 99)})))
  (fold check-err
    (map finish-result run-result)
    (ok true)
  )
)
(define-private (finish-result (run-result { lobby-id: uint, address: principal, score: uint, rank: uint, sum-rank-factor: uint, rank-factor: uint, rewards: uint, rac: uint, nft: (string-ascii 99)}))
    (finish-only (get lobby-id run-result) (get address run-result) (get score run-result) (get rank run-result) (get sum-rank-factor run-result) (get rank-factor run-result) (get rewards run-result) (get rac run-result) (get nft run-result))
)
(define-private (finish-only (lobby-id uint) (address principal) (score uint) (rank uint) (sum-rank-factor uint) (rank-factor uint) (rewards uint) (rac uint) (nft (string-ascii 99)))
  (let
    (
      (finishOk (try! (finish lobby-id address score rank sum-rank-factor rank-factor rewards rac nft)))
    )
    (ok finishOk)
  )
)
;; distribute rewards for all runs in a lobby
(define-private (finish (lobby-id uint) (address principal) (score uint) (rank uint) (sum-rank-factor uint) (rank-factor uint) (rewards uint) (rac uint) (nft (string-ascii 99)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (unwrap-panic (map-get? scoreboard {lobby-id: lobby-id, address: address}))
        (asserts! (default-to false (get active (map-get? lobbies {id: lobby-id}))) ERR-NOT-ACTIVE)
        (map-set scoreboard {lobby-id: lobby-id, address: address} {score: score, rank: rank, sum-rank-factor: sum-rank-factor, rank-factor: rank-factor, rewards: rewards, rac: rac, nft: nft})
        (try! (as-contract (stx-transfer? rac tx-sender address)))
        (print {action: "finish", lobby-id: lobby-id, address: address, score: score, rank: rank, sum-rank-factor: sum-rank-factor, rank-factor: rank-factor, rewards: rewards, rac: rac, nft: nft})
        (ok true)
    )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result
        err-value (err err-value)
    )
)

;; safety functions
(define-public (transfer-stx (address principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (unwrap-panic (as-contract (stx-transfer? amount (as-contract tx-sender) address)))
    (ok true))
)

(define-public (transfer-ft-token (address principal) (amount uint) (token <ft-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer amount tx-sender address none)))
    (ok true))
)

(define-public (transfer-nft-token (address principal) (id uint) (token <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? token transfer id tx-sender address)))
    (ok true))
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true))
)