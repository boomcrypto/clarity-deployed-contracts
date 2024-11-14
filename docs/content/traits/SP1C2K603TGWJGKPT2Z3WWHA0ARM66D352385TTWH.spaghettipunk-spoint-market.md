---
title: "Trait spaghettipunk-spoint-market"
draft: true
---
```
;; SPoint Market
;; Trustless on-chain escrow service to facilitate SPoint swap among SpaghettiPunk Club members
;;
(define-constant ERR-AMOUNT-TOO-HIGH (err u101))
(define-constant ERR-AMOUNT-TOO-LOW (err u102))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SYSTEM-PAUSED (err u402))
(define-constant ERR-MAKET-CAPACITY-EXCEEDED (err u403))
(define-constant MAX-SPOINT-AMOUNT u4200000000)

(define-data-var admin principal tx-sender)
(define-data-var volume-spoint uint u0)
(define-data-var volume-stx uint u0)
(define-data-var order-fee uint u100000)
(define-data-var trade-fee-percent uint u500)
(define-data-var min-spoint-trade-amount uint u1000000)
(define-data-var system-pause bool false)

;; private functions
(define-private (pay-fee) 
  (if (is-eq (var-get admin) tx-sender)
    (ok true)
    (begin
      (try! (stx-transfer? (var-get order-fee) tx-sender (var-get admin)))
      (ok true))))

;; admin functions 
(define-public (change-admin (new-admin principal)) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set admin new-admin)
        (ok true)))

(define-public (change-order-fee (new-fee uint)) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set order-fee new-fee)
        (ok true)))

(define-public (modify-order-fee-percent (new-fee uint)) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set trade-fee-percent new-fee)
        (ok true)))

(define-public (change-min-spoint-trade-amount (new-amount uint)) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set min-spoint-trade-amount new-amount)
        (ok true)))

(define-public (change-market-capacity (new-capacity uint)) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set market-capacity new-capacity)
        (ok true)))

(define-public (toggle-pause) 
    (begin 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (var-set system-pause (not (is-paused)))
        (ok true)))

(define-public (admin-cancel-order (spc-id uint)) 
    (let (
        (trade (map-get? orders {spc-id: spc-id}))
        (trade-maker (get maker (unwrap-panic trade)))
        ) 
        (asserts! (is-eq (var-get admin) tx-sender) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club transfer spc-id (as-contract tx-sender) trade-maker)))
        (map-delete orders {spc-id: spc-id})
        (unwrap-panic (delete-order spc-id trade-maker))
        (ok true)))

;; public functions
(define-public (place-order (spc-id uint) (amount uint) (price uint)) 
    (let (
        (balance (unwrap-panic (contract-call? 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.spoints get-balance spc-id)))
        (paid (pay-fee))
        ) 
        (asserts! (<= amount balance) ERR-AMOUNT-TOO-HIGH)
        (asserts! (>= amount (var-get min-spoint-trade-amount)) ERR-AMOUNT-TOO-LOW)
        (asserts! (not (is-paused)) ERR-SYSTEM-PAUSED)
        (try! (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club transfer spc-id tx-sender (as-contract tx-sender)))
        (unwrap-panic (create-order tx-sender spc-id amount price))
        (ok true)))

(define-public (cancel-order (spc-id uint)) 
    (let (
        (trade (map-get? orders {spc-id: spc-id}))
        (trade-maker (get maker (unwrap-panic trade)))
        ) 
        (asserts! (is-eq trade-maker tx-sender) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club transfer spc-id (as-contract tx-sender) trade-maker)))
        (unwrap-panic (delete-order spc-id trade-maker))
        (ok true)))

(define-public (modify-order (spc-id uint) (amount uint) (price uint)) 
    (let (
        (balance (unwrap-panic (contract-call? 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.spoints get-balance spc-id)))
        (trade (map-get? orders {spc-id: spc-id}))
        (trade-maker (get maker (unwrap-panic trade)))
        ) 
        (asserts! (is-eq trade-maker tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (<= amount balance) ERR-AMOUNT-TOO-HIGH)
        (unwrap-panic (delete-order spc-id trade-maker))
        (unwrap-panic (create-order tx-sender spc-id amount price))
        (ok true)))

(define-public (fulfil-order (spc-id uint) (receiver-id uint) (purchase-amount uint)) 
    (let (
        (balance (unwrap-panic (contract-call? 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.spoints get-balance receiver-id)))
        (trade (map-get? orders {spc-id: spc-id}))
        (trade-maker (get maker (unwrap-panic trade)))
        (spoint-amount (get amount (unwrap-panic trade)))
        (spoint-price (get price (unwrap-panic trade)))
        (stx-amount (/ (* purchase-amount spoint-price) u1000000))
        (fee (if (is-eq (var-get admin) tx-sender) u0 (/ (* stx-amount (var-get trade-fee-percent)) u10000)))
        ) 
        (asserts! (<= purchase-amount (- MAX-SPOINT-AMOUNT balance)) ERR-AMOUNT-TOO-HIGH)
        (asserts! (<= purchase-amount spoint-amount) ERR-AMOUNT-TOO-HIGH)
        (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
        (try! (as-contract (stx-transfer? fee (as-contract tx-sender) (var-get admin))))
        (try! (as-contract (stx-transfer? (- stx-amount fee) (as-contract tx-sender) trade-maker)))
        (try! (as-contract (contract-call? 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.spoints send spc-id receiver-id purchase-amount)))
        (var-set volume-spoint (+ (var-get volume-spoint) purchase-amount))
        (var-set volume-stx (+ (var-get volume-stx) stx-amount))
        (unwrap-panic (delete-order spc-id trade-maker))
        (if (> (- spoint-amount purchase-amount) (var-get min-spoint-trade-amount)) 
            (unwrap-panic (create-order trade-maker spc-id (- spoint-amount purchase-amount) spoint-price))            
            (try! (as-contract (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-club transfer spc-id (as-contract tx-sender) trade-maker)))
            )
        (print {action: "market-fulfil-order", buyer: tx-sender, buyer-id: receiver-id, stx-amount: stx-amount, purchase-amount: purchase-amount, price: spoint-price, seller: trade-maker, seller-id: spc-id })
        (ok true)))

;;storage
(define-data-var id-to-remove uint u0)
(define-data-var market-capacity uint u500)
(define-data-var orders-count uint u0)
(define-map address-orders-count principal uint)
(define-map orders { spc-id: uint } {maker: principal, spc-id: uint, amount: uint, price: uint})
(define-data-var orders-list (list 1000 {maker: principal, spc-id: uint, amount: uint, price: uint}) (list ))

;;read only functions 
(define-read-only (get-overall-volume-stx) (var-get volume-stx))

(define-read-only (get-overall-volume-spoint) (var-get volume-spoint))

(define-read-only (is-paused) (var-get system-pause))

(define-read-only (get-orders-list) (var-get orders-list))

(define-read-only (get-market-capacity) (var-get market-capacity))

(define-read-only (get-orders-count) (var-get orders-count))

(define-read-only (get-address-orders-count (address principal)) (default-to u0 (map-get? address-orders-count address)))

(define-read-only (get-open-order-by-id (spc-id uint)) (unwrap-panic (map-get? orders { spc-id: spc-id })))

(define-read-only (get-min-spoint-trade-amount) (var-get min-spoint-trade-amount))

(define-private (create-order (address principal) (id uint) (amount uint) (price uint)) 
    (begin 
        (asserts! (< (get-orders-count) (get-market-capacity)) ERR-MAKET-CAPACITY-EXCEEDED)
        (var-set orders-list (unwrap-panic (as-max-len? (append (var-get orders-list) {maker: address, spc-id: id, amount: amount, price: price}) u1000)))
        (map-set orders {spc-id: id} {maker: address, spc-id: id, amount: amount, price: price})
        (var-set orders-count (+ (get-orders-count) u1))
        (map-set address-orders-count address (+ (get-address-orders-count address) u1))
        (ok true)))

(define-private (delete-order (id uint) (address principal))  
    (begin 
        (var-set id-to-remove id)
        (var-set orders-list (unwrap-panic (as-max-len? (filter is-to-remove (var-get orders-list)) u1000)))
        (map-delete orders {spc-id: id})
        (var-set orders-count (- (get-orders-count) u1))
        (map-set address-orders-count address (- (get-address-orders-count address) u1))
        (ok true)))

(define-private (is-to-remove (trade {maker: principal, spc-id: uint, amount: uint, price: uint}))
  (if (is-eq (get spc-id trade) (var-get id-to-remove)) false true))
```
