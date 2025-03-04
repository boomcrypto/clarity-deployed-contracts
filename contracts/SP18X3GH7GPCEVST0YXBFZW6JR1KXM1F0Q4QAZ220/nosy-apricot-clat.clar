(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token CLT)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance CLT address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply CLT)))

(define-read-only (get-name)
  (ok "CLINT"))

(define-read-only (get-symbol)
  (ok "CLT"))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (ok (asserts! (and (is-eq from tx-sender) (is-eq memo (print memo)) (try! (ft-transfer? CLT amount from to))) (err u101))))

(define-read-only (get-token-uri)
  (ok (some u"ipfs://ipfs/cltjhdsajhkadoisdjkdnmdj23ew9eicdmdmndskjdsio3e")))

(define-public (burn (count uint))
    (ft-burn? CLT count tx-sender))

(define-private (s (receiver { to: principal, amount: uint }))
  (is-err (ft-transfer? CLT (get amount receiver) tx-sender (get to receiver))))

(define-public (send_many (recipients (list 5000 { to: principal, amount: uint })))
  (ok (asserts! (is-eq (len (filter s recipients)) u0) (err u102))))

(ft-mint? CLT u10000000000000 tx-sender)
