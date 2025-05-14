(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant OWNER tx-sender)
(define-constant VAULT-CA 'SP35DAESSEJTKD4VNZPMKZKF6VGBC1DWBNVX08445.vault) 
(define-constant DEPLOYER 'SP35DAESSEJTKD4VNZPMKZKF6VGBC1DWBNVX08445) 

(define-constant DECI u1000000)
(define-constant token-max-supply (* u1000000000 DECI))
(define-constant token-deploy-fee (* u10 DECI))
(define-constant token-first-buy (* u0 DECI))  

(define-constant err-not-contract-owner (err u1001))
(define-constant err-not-token-owner (err u1002))
(define-constant err-only-mint-once (err u9001))

(define-data-var token-uri (optional (string-utf8 256)) (some u"https://memefun.s3.ap-northeast-1.amazonaws.com/metadata/foz8ll486hp69fdxt7gz2xivhcn3v9ot.json?"))
(define-data-var is-minted bool false)


(define-fungible-token TRUMP token-max-supply)


(define-read-only (get-owner)
    (ok OWNER))

(define-read-only (get-name)
    (ok "TRUMP"))

(define-read-only (get-symbol)
    (ok "TRUMP")) 

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-max-supply)
    (ok token-max-supply))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance TRUMP who)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply TRUMP)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-public (mint (amount uint) (recipient principal)) 
    (begin 
        (asserts! (is-eq (var-get is-minted) false) err-only-mint-once) 
        (asserts! (is-eq tx-sender OWNER) err-not-contract-owner)
        (try! (ft-mint? TRUMP amount recipient))
        (var-set is-minted true)
        (ok true)
    )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34)))) 
    (begin
        (asserts! (is-eq sender tx-sender) err-not-token-owner)
        (try! (ft-transfer? TRUMP amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-public (burn (amount uint))
    (ft-burn? TRUMP amount tx-sender))

(try! (mint token-max-supply VAULT-CA))
(try! (stx-transfer? (+ token-first-buy token-deploy-fee) tx-sender DEPLOYER))