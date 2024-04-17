;; All meme tokens are generated out of air
;; STX10 meme tokens are converted by STX
;; All about meme tokens should be free and fair 
;; 
;; Airdrop condition: 
;; 1. From block 143500-137822, total 86166 addresses have sent transactions
;; 2. Total 2592 addresses have interacted with SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.inscription and SP1BMZTS416A3VTMN0SYTRMEJSCHW75RRAKXWF4DZ.stacks-inscription
;; For addresses in 1, each get 85% * 21000000000000 / 86166 = 207158275 $ALL
;; For addresses in 2, each get 15% * 21000000000000 / 2592 = 1215277777 $ALL
;; No reservations

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token ALL)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance ALL address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply ALL)))

(define-read-only (get-name)
  (ok "Son Of STX10"))

(define-read-only (get-symbol)
  (ok "ALL"))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (ok (asserts! (and (is-eq from tx-sender) (is-eq memo (print memo)) (try! (ft-transfer? ALL amount from to))) (err u101))))

(define-read-only (get-token-uri)
  (ok (some u"ipfs://ipfs/bafkreicmojux3laa6w6obd4lxwq6jojceezmlhevt2knqyrihf7lpko6gy")))

(define-public (burn (count uint))
    (ft-burn? ALL count tx-sender))

(define-private (s (receiver { to: principal, amount: uint }))
  (is-err (ft-transfer? ALL (get amount receiver) tx-sender (get to receiver))))

(define-public (send_many (recipients (list 5000 { to: principal, amount: uint })))
  (ok (asserts! (is-eq (len (filter s recipients)) u0) (err u102))))

(ft-mint? ALL u21000000000000 tx-sender)