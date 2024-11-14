;; bunnyOrdy

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bunnyOrdy uint)

(define-constant DEPLOYER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u101)

(define-data-var BASE_URI (string-ascii 95) "https://ordinals.com/content/aa9eeecf49a5dd4a600540d15120d1436af0013dd5a2b7cee139a469d62f9deei0")
(define-data-var last-id uint u0)


(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (nft-transfer? bunnyOrdy id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bunnyOrdy token-id)))


(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get BASE_URI)))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))


(define-private (mint (recipient principal)) 
 (let
    (
    (id (+ (var-get last-id) u1))
    )
    
    (try! (nft-mint? bunnyOrdy id recipient))
    (var-set last-id id)
    (ok id)
 )
)

(try! (mint DEPLOYER))
(try! (mint DEPLOYER))
(try! (mint DEPLOYER))
(try! (mint DEPLOYER))
(try! (mint DEPLOYER))
