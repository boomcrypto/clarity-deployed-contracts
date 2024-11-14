---
title: "Trait nakapack-nft-minter"
draft: true
---
```
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-MINT-NOT-LIVE (err u402))
(define-constant ERR-SOLD-OUT (err u403))
(define-constant ERR-NOT-ENOUGH-WHITELIST-PASSES (err u405))

(define-data-var bank-address principal 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)
(define-data-var price uint u8678670)
(define-data-var nft-contract principal .nakapack-nft)
(define-data-var whitelist-mint-live bool false)
(define-data-var mint-live bool false)
(define-data-var max-supply uint u5000)
(define-data-var ape-reserved uint u2500)
(define-data-var initial-mint-done bool false)
(define-data-var stacks-foundation-address principal 'SP3PR3ETRNRY4MRTCPAGG2VF7HBC577Q87R0GXQV6)

(define-map orangelist principal uint)
(define-map apelist principal uint)
(define-map mint-count principal uint)
(define-map ape-mint-count principal uint)

(define-private (is-owner)
    (is-eq tx-sender CONTRACT-OWNER))

(define-private (direct-mint (new-owner principal))
    (contract-call? .nakapack-nft mint new-owner))

(define-private (mnt)
    (let (
        (remaining-supply (unwrap-panic (get-remaining-supply)))
        (ape-passes (unwrap-panic (get-apelist-passes-remaining tx-sender)))
        (orange-passes (unwrap-panic (get-orangelist-passes-remaining tx-sender)))
        (total-minted (- (var-get max-supply) remaining-supply))
    )
        (asserts! (> remaining-supply u0) ERR-SOLD-OUT)
        (if (var-get mint-live)
            (direct-mint tx-sender)
            (if (var-get whitelist-mint-live)
                (if (> ape-passes u0)
                    (begin
                        (map-set ape-mint-count tx-sender (+ (default-to u0 (map-get? ape-mint-count tx-sender)) u1))
                        (direct-mint tx-sender))
                    (if (and (> orange-passes u0) (<= total-minted (- (var-get max-supply) (var-get ape-reserved))))
                        (begin
                            (map-set mint-count tx-sender (+ (default-to u0 (map-get? mint-count tx-sender)) u1))
                            (direct-mint tx-sender))
                        ERR-NOT-ENOUGH-WHITELIST-PASSES))
                ERR-MINT-NOT-LIVE))))

(define-private (mint-iter (ignore uint) (prior {minted: uint, error: (optional (response bool uint)), continue: bool, count: uint}))
    (if (and (< (get minted prior) (get count prior)) (get continue prior))
        (match (mnt)
            success (merge prior {minted: (+ u1 (get minted prior))})
            error (merge prior {error: (some (err error)), continue: false}))
        prior))

(define-private (clear-orangelist-iter (address principal) (next-index uint))
    (begin
        (map-delete orangelist address)
        (+ next-index u1)))

(define-private (add-orangelist-iter (entry {address: principal, quantity: uint}) (next-index uint))
    (begin
        (map-set orangelist (get address entry) (get quantity entry))
        (+ next-index u1)))

(define-private (clear-apelist-iter (address principal) (next-index uint))
    (begin
        (map-delete apelist address)
        (+ next-index u1)))

(define-private (add-apelist-iter (entry {address: principal, quantity: uint}) (next-index uint))
    (begin
        (map-set apelist (get address entry) (get quantity entry))
        (+ next-index u1)))

(define-private (direct-initial-mint (new-owner principal))
    (contract-call? .nakapack-nft mint (var-get stacks-foundation-address)))

(define-private (initial-mint-iter (ignore uint) (prior {minted: uint, error: (optional (response bool uint)), continue: bool, count: uint}))
    (if (and (< (get minted prior) (get count prior)) (get continue prior))
        (match (direct-initial-mint (var-get stacks-foundation-address))
            success (merge prior {minted: (+ u1 (get minted prior))})
            error (merge prior {error: (some (err error)), continue: false}))
        prior))

(define-read-only (get-max-supply)
    (ok (var-get max-supply)))

(define-read-only (get-ape-reserved)
    (ok (var-get ape-reserved)))

(define-read-only (get-price)
    (ok (var-get price)))

(define-read-only (is-mint-live)
    (ok (var-get mint-live)))

(define-read-only (is-whitelist-mint-live)
    (ok (var-get whitelist-mint-live)))

(define-read-only (get-mint-count (address principal))
    (ok (default-to u0 (map-get? mint-count address))))

(define-read-only (get-remaining-supply)
    (let ((last-id (unwrap-panic (contract-call? .nakapack-nft get-last-token-id))))
        (ok (- (var-get max-supply) last-id))))

(define-read-only (get-apelist-passes-remaining (address principal))
    (let (
        (minted (default-to u0 (map-get? ape-mint-count address)))
        (allowed (default-to u0 (map-get? apelist address)))
    )
        (ok (- allowed minted))))

(define-read-only (get-orangelist-passes-remaining (address principal))
    (let (
        (minted (default-to u0 (map-get? mint-count address)))
        (allowed (default-to u0 (map-get? orangelist address)))
    )
        (ok (- allowed minted))))

(define-read-only (is-initial-mint-done)
    (ok (var-get initial-mint-done)))

(define-public (set-max-supply (new-max-supply uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set max-supply new-max-supply)
        (ok true)))

(define-public (set-ape-reserved (new-ape-reserved uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set ape-reserved new-ape-reserved)
        (ok true)))

(define-public (set-price (new-price uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set price new-price)
        (ok true)))

(define-public (set-mint-live (live bool))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set mint-live live)
        (ok true)))

(define-public (set-whitelist-mint-live (live bool))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set whitelist-mint-live live)
        (ok true)))

(define-public (set-nft-contract (contract principal))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set nft-contract contract)
        (ok true)))

(define-public (set-bank-address (address principal))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set bank-address address)
        (ok true)))

(define-public (set-stacks-foundation-address (address principal))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (var-set stacks-foundation-address address)
        (ok true)))

(define-public (clear-orangelist (addresses (list 2000 principal)))
    (let ((index-reached (fold clear-orangelist-iter addresses u0)))
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (print {total-orangelist-cleared: index-reached})
        (ok true)))

(define-public (add-to-orangelist (entries (list 2000 {address: principal, quantity: uint})))
    (let ((index-reached (fold add-orangelist-iter entries u0)))
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (print {total-orangelist-added: index-reached})
        (ok true)))

(define-public (clear-apelist (addresses (list 2000 principal)))
    (let ((index-reached (fold clear-apelist-iter addresses u0)))
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (print {total-apelist-cleared: index-reached})
        (ok true)))

(define-public (add-to-apelist (entries (list 2000 {address: principal, quantity: uint})))
    (let ((index-reached (fold add-apelist-iter entries u0)))
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (print {total-apelist-added: index-reached})
        (ok true)))

(define-public (mint)
    (mint-multiple u1))

(define-public (mint-multiple (count uint))
    (let
        (
            (total-price (* (var-get price) count))
            (loop-result
                (begin
                    (try! (stx-transfer? total-price tx-sender (var-get bank-address)))
                    (fold mint-iter
                        (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25)
                        {minted: u0, error: none, continue: true, count: count}
                    )
                )
            )
        )
        (if (is-some (get error loop-result))
            (unwrap-panic (get error loop-result))
            (ok true))))

(define-public (initial-mint (count uint))
    (begin
        (asserts! (is-owner) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get initial-mint-done)) ERR-NOT-AUTHORIZED)
        (let
            (
                (loop-result
                    (begin
                        (fold initial-mint-iter
                            (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50)
                            {minted: u0, error: none, continue: true, count: count}
                        )
                    )
                )
            )
            (begin
                (var-set initial-mint-done true)
                (if (is-some (get error loop-result))
                    (unwrap-panic (get error loop-result))
                    (ok true))))))

```
