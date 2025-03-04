(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant OWNER tx-sender)
(define-constant VAULT-CA 'SP2VACC9K38NVPBG8EKC5V9FTQ6JBKHY05RSVDWJ3.vault) 
(define-constant DEPLOYER 'SP2VACC9K38NVPBG8EKC5V9FTQ6JBKHY05RSVDWJ3) 

(define-constant DECI u1000000)
(define-constant token-max-supply (* u1000000000 DECI))
(define-constant token-deploy-fee (* u10 DECI))
(define-constant token-first-buy (* u1 DECI))  

(define-constant err-not-contract-owner (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-only-mint-once (err u9001))

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://memefun.s3.ap-northeast-1.amazonaws.com/metadata/jtslx500g5sauibckgrvsu2h0pi8vmkd.json?"))
(define-data-var is-minted bool false)


(define-fungible-token LNM token-max-supply)


(define-read-only (get-owner)
    (ok OWNER))

(define-read-only (get-name)
    (ok "Luigi Nicholas Mangione"))

(define-read-only (get-symbol)
    (ok "LNM")) 

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-max-supply)
    (ok token-max-supply))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance LNM who)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply LNM)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-public (mint (amount uint) (recipient principal)) 
    (begin 
        (asserts! (is-eq (var-get is-minted) false) err-only-mint-once) 
        (asserts! (is-eq tx-sender OWNER) err-not-contract-owner)
        (try! (ft-mint? LNM amount recipient))
        (var-set is-minted true)
        (ok true)
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) 
    (begin
        (asserts! (is-eq sender tx-sender) err-not-token-owner)
        (try! (ft-transfer? LNM amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (burn (amount uint))
    (ft-burn? LNM amount tx-sender))

(try! (mint token-max-supply VAULT-CA))
(try! (stx-transfer? (+ token-first-buy token-deploy-fee) tx-sender DEPLOYER))