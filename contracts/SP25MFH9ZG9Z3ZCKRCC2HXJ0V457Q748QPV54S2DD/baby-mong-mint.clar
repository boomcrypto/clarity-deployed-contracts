;; baby-mong-mint 1.0

;; sip010-ft-trait
(use-trait sip010-token .sip010-ft-trait.sip010-ft-trait) 

;; define constant values
(define-constant MINT-CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-FORBIDDEN (err u403))
(define-constant ERR-OUT-OF-WLCOUNT (err u503))
(define-constant MAX-VIP-MINT u1)   

;; define vars
(define-data-var wl-wallet-list (list 25 principal) (list ))
(define-data-var is-wl-mint bool false)
(define-data-var is-sale-active bool false)
(define-data-var vip-mint-count uint u0)

;; define maps
(define-map wl-wallet principal uint)

;; WL wallet info
(define-read-only (get-wl-balance (account principal))
    (default-to u0 (map-get? wl-wallet account)))

(define-read-only (get-wl-list)
    (var-get wl-wallet-list))

(define-read-only (get-sale-active)
    (var-get is-sale-active))

(define-read-only (get-wl-mint-active)
    (var-get is-wl-mint))

;; operation code 
(define-public (wl-sale-init (NYC uint) (MIA uint) (BAN uint))
    (begin 
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? .baby-mong-nft init-mint NYC MIA BAN)))
        (var-set is-sale-active true)
        (var-set is-wl-mint true)
        (ok true)))

(define-public (pub-sale-init)
    (begin 
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? .baby-mong-nft set-pubsale true)))        
        (var-set is-wl-mint false)
        (ok true)))

;; marbling-mint
(define-public (claim)
    (begin    
        (asserts! (var-get is-sale-active) ERR-FORBIDDEN)
        (if (var-get is-wl-mint) 
            (begin
                (let ((presale-balance (get-wl-balance tx-sender)))
                    (asserts! (> presale-balance u0) ERR-OUT-OF-WLCOUNT)
                    (map-set wl-wallet tx-sender (- presale-balance u1))            
                (try! (contract-call? .baby-mong-nft mint-with-stx tx-sender))))
            (try! (contract-call? .baby-mong-nft mint-with-stx tx-sender)))
            (ok true))) 

;; Only available on wl-sale
(define-public (claim-wl-token (send-token <sip010-token>))
    (begin
        (asserts! (var-get is-sale-active) ERR-FORBIDDEN)        
        (asserts! (var-get is-wl-mint) ERR-FORBIDDEN)
        (begin
            (let ((presale-balance (get-wl-balance tx-sender)))
                (asserts! (> presale-balance u0) ERR-OUT-OF-WLCOUNT)
                (map-set wl-wallet tx-sender (- presale-balance u1))            
                (try! (contract-call? .baby-mong-nft mint-with-token tx-sender send-token))
                (ok true)))))

(define-public (claim-vip (target-wallet principal))
    (begin        
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (let
            ((cur-vip-count (var-get vip-mint-count))) 
            (asserts! (< cur-vip-count MAX-VIP-MINT) ERR-FORBIDDEN)
            (var-set vip-mint-count (+ u1 cur-vip-count))    
            (try! (contract-call? .baby-mong-nft mint-vip target-wallet))
            (ok true))))

;; Multiple Mint 
(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-wl-token-two (send-token <sip010-token>))
  (begin
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (ok true)))

(define-public (claim-wl-token-three (send-token <sip010-token>))
  (begin
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (ok true)))

(define-public (claim-wl-token-four (send-token <sip010-token>))
  (begin
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (ok true)))

(define-public (claim-wl-token-five (send-token <sip010-token>))
  (begin
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (try! (claim-wl-token send-token))
    (ok true)))
 
(define-public (set-wl-wallets (mint-cnt uint) (addresses (list 25 principal)))
    (begin
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set wl-wallet-list addresses)
        (fold set-wl-wallet-map addresses mint-cnt)
        (ok true)))

(define-private (set-wl-wallet-map (single-address principal) (count uint))
    (begin
        (map-set wl-wallet single-address count) count))

(define-public (set-wl-wallet (mint-cnt uint) (single-address principal))
    (begin
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (< mint-cnt u6) ERR-FORBIDDEN)
        (map-set wl-wallet single-address mint-cnt)
        (ok true)))
