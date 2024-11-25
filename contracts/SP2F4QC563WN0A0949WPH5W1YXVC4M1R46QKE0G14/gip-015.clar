;;
;; MEMEGOAT PROPOSALS
;;
(impl-trait .proposal-trait.proposal-trait)

;; ERRS
(define-constant ERR-UNAUTHORISED (err u1000))
(define-constant ERR-NOT-QUALIFIED (err u1001))
(define-constant ERR-ALREADY-ACTIVATED (err u1002))
(define-constant ERR-NOT-ACTIVATED (err u1003))
(define-constant ERR-BELOW-MIN-PERIOD (err u2001))
(define-constant ERR-INVALID-OPTION (err u2002))
(define-constant ERR-HAS-VOTED (err u3002))

;; STORAGE
(define-data-var activated bool false)
(define-data-var duration uint u0)
(define-data-var start-block uint u0)
(define-data-var end-block uint u0)
(define-map votes {option: uint} uint)
(define-map vote-record principal bool)

;; READ-ONLY CALLS
(define-read-only (get-votes-by-op (op uint))
  (default-to u0 (map-get? votes {option: op}))
)

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-UNAUTHORISED))
)

(define-read-only (get-proposal-data)
  (ok {
    start-block: (var-get start-block),
    end-block: (var-get end-block),
    duration: (var-get duration)
  })
)

(define-read-only (get-votes)
  (ok {
    op1: {id: u0, votes: (get-votes-by-op u0)},
    op2: {id: u1, votes: (get-votes-by-op u1)},
    op3: {id: u2, votes: (get-votes-by-op u2)},
    op4: {id: u3, votes: (get-votes-by-op u3)}
  })
)

(define-read-only (get-total-votes)
  (let
    (
      (vote-opts (list u0 u1 u2 u3))
    )
    (ok (fold get-votes-by-op-iter vote-opts u0))
  )
)

(define-read-only (check-has-voted (addr principal))
 (default-to false (map-get? vote-record addr))
)

;; PUBLIC CALLS
(define-public (activate (duration_ uint))
  (begin
    (try! (is-dao-or-extension))
    (asserts! (not (var-get activated)) ERR-ALREADY-ACTIVATED)
    (asserts! (> duration_ u0) ERR-BELOW-MIN-PERIOD)
    (var-set activated true)
    (var-set duration duration_)
    (var-set start-block burn-block-height)
    (ok (var-set end-block (+ burn-block-height duration_)))
  )
)

(define-public (vote (opt uint))
  (let
    (
      (sender tx-sender)
      (has-stake (contract-call? .memegoat-staking-v1 get-user-stake-has-staked sender))
      (stake-amount (get deposit-amount (try! (contract-call? .memegoat-staking-v1 get-user-staking-data sender))))
      (curr-votes (get-votes-by-op opt))
    )
    (asserts! has-stake ERR-NOT-QUALIFIED)
    (asserts! (< opt u4) ERR-INVALID-OPTION)
    (asserts! (not (check-has-voted sender)) ERR-HAS-VOTED)

    (map-set votes {option: opt} (+ curr-votes stake-amount))
    (ok (map-set vote-record sender true))
  )
)

(define-public (execute (sender principal) (opt uint))
  (begin
    (try! (is-dao-or-extension))
    (let
        (
            (goat-bal (unwrap-panic (contract-call? .memegoatstx get-balance .memegoat-vault)))
            (leo-bal (unwrap-panic (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token get-balance .memegoat-vault)))
            (pomboo-bal (unwrap-panic (contract-call? 'SP1N4EXSR8DP5GRN2XCWZEW9PR32JHNRYW7MVPNTA.PomerenianBoo-Pomboo get-balance .memegoat-vault)))
            (thcam-bal (unwrap-panic (contract-call? 'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity get-balance .memegoat-vault)))
            (muneeb-bal (unwrap-panic (contract-call? 'SP2VGJQAB0T7R2Y9S2PJRNPDEW91CM2YCDYJGGPQS.mooneeb get-balance .memegoat-vault)))
            (ten-bal (unwrap-panic (contract-call? 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu get-balance .memegoat-vault)))
            (aew-bal (unwrap-panic (contract-call? 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aewbtc get-balance .memegoat-vault)))
            (walter-bal (unwrap-panic (contract-call? 'SP45RYP4W83SMSCG5C7MZCM1EFVRJY4K6D0E05Z6.walter get-balance .memegoat-vault)))
            (rock-bal (unwrap-panic (contract-call? 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock get-balance .memegoat-vault)))
            (stones-bal (unwrap-panic (contract-call? 'SPK5HH9QVYDNXNDCFH6W5AMRSR5K83ZMT4GPPK7M.flintstones get-balance .memegoat-vault)))
            (mst-bal (unwrap-panic (contract-call? 'SPKMQ8QD26HS1B2E9KXWCDKRF63X0RP8BZ361QTH.moneystack-stxcity get-balance .memegoat-vault)))
        )

        (try! (contract-call? .memegoat-vault set-approval-status 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP1N4EXSR8DP5GRN2XCWZEW9PR32JHNRYW7MVPNTA.PomerenianBoo-Pomboo u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP2VGJQAB0T7R2Y9S2PJRNPDEW91CM2YCDYJGGPQS.mooneeb u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aewbtc u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP45RYP4W83SMSCG5C7MZCM1EFVRJY4K6D0E05Z6.walter u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SPK5HH9QVYDNXNDCFH6W5AMRSR5K83ZMT4GPPK7M.flintstones u0 true))
        (try! (contract-call? .memegoat-vault set-approval-status 'SPKMQ8QD26HS1B2E9KXWCDKRF63X0RP8BZ361QTH.moneystack-stxcity u0 true))

        (if (> goat-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft .memegoatstx goat-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> leo-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token leo-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> pomboo-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP1N4EXSR8DP5GRN2XCWZEW9PR32JHNRYW7MVPNTA.PomerenianBoo-Pomboo pomboo-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> thcam-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity thcam-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> muneeb-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP2VGJQAB0T7R2Y9S2PJRNPDEW91CM2YCDYJGGPQS.mooneeb muneeb-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> ten-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu ten-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> aew-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aewbtc aew-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> walter-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP45RYP4W83SMSCG5C7MZCM1EFVRJY4K6D0E05Z6.walter walter-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> rock-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock rock-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> stones-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SPK5HH9QVYDNXNDCFH6W5AMRSR5K83ZMT4GPPK7M.flintstones stones-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )

        (if (> mst-bal u0)
            (try! (contract-call? .memegoat-vault transfer-ft 'SPKMQ8QD26HS1B2E9KXWCDKRF63X0RP8BZ361QTH.moneystack-stxcity mst-bal 'SPJTC4M0P9A78RKDHRVWFYJDV7WZYK35DMD6RK2G))
            true
        )
    )
    (ok true)
  )
)



;; PRIVATE CALLS
(define-private (get-votes-by-op-iter (op uint) (total uint))
  (+ total (get-votes-by-op op))
)