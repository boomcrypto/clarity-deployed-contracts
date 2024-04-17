;; Most meme tokens are generated out of air
;; stx10 meme tokens are converted by stx: no 90% reservation, no back door in the contracts.

;; Airdrop condition: From block 143500-137457, each address that had sent transaction(s), totally 86346 addresses, each get 2383434090 $MEME

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token MEME)

(define-read-only (get-balance (address principal))
  (ok (ft-get-balance MEME address)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply MEME)))

(define-read-only (get-name)
  (ok "SonOfStx10"))

(define-read-only (get-symbol)
  (ok "MEME"))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (ok (asserts! (and (is-eq from tx-sender) (is-eq memo (print memo)) (try! (ft-transfer? MEME amount from to))) (err u101))))

(define-read-only (get-token-uri)
  (ok (some u"https://ipfs.io/ipfs/QmZmc74kVdh5FU8QK83SpqnL2nhANk6tLrCpuCivt91Wch")))

(define-public (burn (count uint))
    (ft-burn? MEME count tx-sender))

(define-private (iter (receiver { to: principal, amount: uint }))
  (is-err (ft-transfer? MEME (get amount receiver) tx-sender (get to receiver))))

(define-public (send_many (recipients (list 5000 { to: principal, amount: uint })))
  (ok (asserts! (is-eq (len (filter iter recipients)) u0) (err u102))))

(ft-mint? MEME u210000000000000 tx-sender)