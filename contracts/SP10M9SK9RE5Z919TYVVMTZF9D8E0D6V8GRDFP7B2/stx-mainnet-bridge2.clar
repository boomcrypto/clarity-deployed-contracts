(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-NOT-REGISTERED-COLLECTION (err u1001))
(define-constant ERR-BRIDGE-PASSED (err u1002))
(define-constant ERR-NOT-SAME-PRINCIPAL (err u1003))
(define-constant ERR-NOT-OWNER (err u1004))
(define-constant ERR-BRIDGED-ALREADY (err u1005))

(define-data-var contract-owner principal tx-sender)
(define-data-var contract-operator principal tx-sender)
(define-constant contract-address (as-contract tx-sender))
(define-data-var payment-account principal tx-sender)
(define-data-var operator-public-key (buff 33) 0x)
(define-data-var bridge-fee uint u5000000) ;; 5 usd
(define-data-var collection-count uint u0)
(define-map bridge-nonce {collection: principal, id: uint} uint)
(define-map bridge-take-fee {collection: principal, id: uint, nonce: uint} bool)
(define-map bridged-to {collection: principal, id: uint, nonce: uint} principal)
(define-map collections {id: uint} principal)
(define-map collection-ids {collection: principal} uint)


(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)

(define-public (bridge-to-eth (nft-asset-contract <nft-trait>) (nft-id uint) (takeFee bool) (dest-address (string-ascii 42)))
    (let (
        (collection-id (map-get? collection-ids {collection: (contract-of nft-asset-contract)}))
        (nonce (default-to u0 (map-get? bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id})))
        )
        (asserts! (is-some collection-id) ERR-NOT-REGISTERED-COLLECTION)
        (asserts! (is-eq (mod nonce u2) u0) ERR-BRIDGE-PASSED)
        (map-set bridge-take-fee {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} takeFee)
        (map-set bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id} (+ nonce u1))
        (if (is-eq takeFee true) 
          (begin 
            (try! (stx-transfer? (get-bridge-fee (var-get bridge-fee)) tx-sender (var-get payment-account)))
          )
          false
        )
        (try! (contract-call? nft-asset-contract transfer nft-id tx-sender contract-address))
        (print {collection: (contract-of nft-asset-contract), id: nft-id, takeFee: takeFee, dest: dest-address, nonce: nonce})
        (ok true)
    )
)

(define-public (bridge-to-stx  (nft-asset-contract <nft-trait>) (nft-id uint) (takeFee bool) (dest-address principal))
    (let (
        (take-fee (if takeFee u1 u0))
        (nft-asset-address (contract-of nft-asset-contract))
        (collection-id (map-get? collection-ids {collection: (contract-of nft-asset-contract)}))
        (nonce (default-to u0 (map-get? bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id})))
        )
        (asserts! (is-eq tx-sender (var-get contract-operator)) ERR-NOT-AUTHORIZED)
        (asserts! (is-some collection-id) ERR-NOT-REGISTERED-COLLECTION)
        (asserts! (is-eq (mod nonce u2) u1) ERR-BRIDGE-PASSED)
        (if 
          (is-eq takeFee false) 
          (begin 
            (try! (as-contract (contract-call? nft-asset-contract transfer nft-id tx-sender dest-address)))
            (map-set bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id} (+ nonce u1))
          )
          false
        )
        (map-set bridge-take-fee {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} takeFee)
        (map-set bridged-to {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} dest-address)
        (print {collection: (contract-of nft-asset-contract), id: nft-id, takeFee: takeFee, dest: dest-address, nonce: nonce})
        (ok true)
    )
)

(define-public (claim-to-stx (nft-asset-contract <nft-trait>) (nft-id uint))
  (let (
    (nonce (default-to u0 (map-get? bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id})))
    (take-fee (default-to false (map-get? bridge-take-fee {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} )))
    (dest-address (map-get? bridged-to {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} ))
    (sender tx-sender)
    )

    (try! (stx-transfer? (get-bridge-fee (var-get bridge-fee)) tx-sender (var-get payment-account)))
    (try! (as-contract (contract-call? nft-asset-contract transfer nft-id tx-sender sender)))
    (map-set bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id} (+ nonce u1))
    (print {collection: (contract-of nft-asset-contract), id: nft-id, takeFee: take-fee, dest: dest-address, nonce: nonce})
    (ok true)
  )
)

(define-public (set-bridge-fee (fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (var-set bridge-fee fee)
    (ok true)))


(define-public (transfer-stx (address principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (try! (as-contract (stx-transfer? amount contract-address address)))
    (ok true))
)


(define-read-only (get-bridge-fee (usd-value uint)) 
  (let (
    (stx-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-1 get-price "STX"))
    )
    (default-to u0 (some (/ (* usd-value (get decimals stx-price)) (get last-price stx-price))))
  )
)


(define-public (add-collection (nft-asset-contract <nft-trait>))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? collection-ids {collection: (contract-of nft-asset-contract)})) ERR-BRIDGE-PASSED)
    (map-set collection-ids {collection: (contract-of nft-asset-contract)} (var-get collection-count))
    (map-set collections {id: (var-get collection-count)} (contract-of nft-asset-contract))
    (print {id: (var-get collection-count), collection: (contract-of nft-asset-contract)})
    (var-set collection-count (+ (var-get collection-count) u1))
    (ok true))
)


(define-public (set-operator-public-key (public-key (buff 33)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-operator)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (ok tx-sender) (principal-of? public-key)) ERR-NOT-SAME-PRINCIPAL)
    (var-set operator-public-key public-key)
    (ok true))
)

(define-public (set-payment-account (new-payment-account principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-operator)) ERR-NOT-AUTHORIZED)
    (var-set payment-account new-payment-account)
    (ok true))
)


(define-read-only (get-nonce (nft-asset-contract <nft-trait>) (nft-id uint)) 
  (let (
    (nonce (default-to u0 (map-get? bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id})))
  )
  (ok nonce))
)

(define-read-only (get-take-fee (nft-asset-contract <nft-trait>) (nft-id uint) (nonce uint)) 
  (let (
    (take-fee (default-to true (map-get? bridge-take-fee {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce})))
  )
  (ok take-fee))
)


(define-read-only (get-claimer (nft-asset-contract <nft-trait>) (nft-id uint)) 
  (let (
    (nonce (default-to u0 (map-get? bridge-nonce {collection: (contract-of nft-asset-contract), id: nft-id})))
    (dest-address (map-get? bridged-to {collection: (contract-of nft-asset-contract), id: nft-id, nonce: nonce} ))
  )
  (ok dest-address)
  )
)