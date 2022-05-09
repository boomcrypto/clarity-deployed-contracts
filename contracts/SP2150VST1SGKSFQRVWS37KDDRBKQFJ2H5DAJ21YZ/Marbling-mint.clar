;; Marbling mint 
;; by KCV DAO 2022

;; sip010-ft-trait
(use-trait sip010-token .sip010-ft-trait.sip010-ft-trait) 

;; define constant values
(define-constant MINT-CONTRACT-OWNER tx-sender)
(define-constant MINT-BURN-ADDRESS 'SPGNRMVQFTQ2MB1WPC5X3YZE7HPEQN4EZPNGNC0H)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-FORBIDDEN (err u403))
(define-constant ERR-OUT-OF-WLCOUNT (err u503))
(define-constant ERR-OUT-OF-PUBMINT-COUNT (err u504))

;; define vars
(define-data-var wl-wallet-list (list 2000 principal) (list ))
(define-data-var is-wl-mint bool false)
(define-data-var is-sale-active bool false)

;; define maps
(define-map wl-wallet principal uint)
(define-map pub-wallet principal uint)
(define-map supporter-wallet principal uint)

;; Will be removed
(define-read-only (get-supporter-balance (account principal))
    (default-to u0 (map-get? supporter-wallet account)))

;; WL wallet info
(define-read-only (get-wl-balance (account principal))
    (default-to u0 (map-get? wl-wallet account)))

(define-read-only (get-wl-list)
    (var-get wl-wallet-list))

(define-read-only (get-sale-active)
    (var-get is-sale-active))

(define-read-only (get-wl-mint-active)
    (var-get is-wl-mint))

(define-read-only (get-pub-mint-count (account principal))
    (default-to u0 (map-get? pub-wallet account)))
 
;; operation code 
(define-public (wl-sale-init (NYC uint) (MIA uint) (BAN uint))
    (begin 
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? .Marbling init-mint NYC MIA BAN)))
        (var-set is-sale-active true)
        (var-set is-wl-mint true)
        (ok true)))

(define-public (pub-sale-init)
    (begin 
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (try! (as-contract (contract-call? .Marbling set-pubsale true)))        
        (var-set is-wl-mint false)
        (ok true)))

;; Marbling-mint
(define-public (claim)
    (begin    
        (asserts! (var-get is-sale-active) ERR-FORBIDDEN)
        (if (var-get is-wl-mint)             
            (let 
                ((presale-balance (get-wl-balance tx-sender)))
                (asserts! (> presale-balance u0) ERR-OUT-OF-WLCOUNT)
                (map-set wl-wallet tx-sender (- presale-balance u1))            
                (try! (contract-call? .Marbling mint-with-stx tx-sender)))
            (let
                ((pub-minted-count (get-pub-mint-count tx-sender)))
                (asserts! (< pub-minted-count u2) ERR-OUT-OF-PUBMINT-COUNT)
                (try! (contract-call? .Marbling mint-with-stx tx-sender))
                (map-set pub-wallet tx-sender (+ pub-minted-count u1))
            ))            
        (ok true))) 

;; Only available on wl-sale
(define-public (claim-wl-token (send-token <sip010-token>))
    (begin
        (asserts! (var-get is-sale-active) ERR-FORBIDDEN)        
        (asserts! (var-get is-wl-mint) ERR-FORBIDDEN)        
        (let ((presale-balance (get-wl-balance tx-sender)))
            (asserts! (> presale-balance u0) ERR-OUT-OF-WLCOUNT)
            (map-set wl-wallet tx-sender (- presale-balance u1))            
            (try! (contract-call? .Marbling mint-with-token tx-sender send-token))
            (ok true))))

;; Only available on wl-sale
(define-public (claim-for-supporter)
    (begin        
        (asserts! (var-get is-sale-active) ERR-FORBIDDEN)
        (asserts! (var-get is-wl-mint) ERR-FORBIDDEN)        
        (let
            ((cur-supporter-balance (get-supporter-balance tx-sender))) 
            (asserts! (> cur-supporter-balance u0) ERR-OUT-OF-WLCOUNT)            
            (try! (contract-call? .Marbling mint-for-supporter tx-sender))
            (map-set supporter-wallet tx-sender (- cur-supporter-balance u1))    
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

;; Funcs for supporter and WL   
(define-public (set-supporter-wallets (mint-cnt uint) (addresses (list 20 principal))) 
    (begin
        (asserts! (is-eq tx-sender MINT-CONTRACT-OWNER) ERR-NOT-AUTHORIZED)        
        (fold set-supporter-wallet-map addresses mint-cnt)
        (ok true)))

(define-private (set-supporter-wallet-map (single-address principal) (count uint))
    (begin
        (map-set supporter-wallet single-address count) count))

(define-public (set-wl-wallets (mint-cnt uint) (addresses (list 1000 principal))) 
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
