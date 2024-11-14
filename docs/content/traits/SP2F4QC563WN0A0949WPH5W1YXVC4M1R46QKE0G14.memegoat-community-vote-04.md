---
title: "Trait memegoat-community-vote-04"
draft: true
---
```
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

    (try! (contract-call? .memegoat-vault set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u0 true))
    (try! (contract-call? .memegoat-vault set-approval-status 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx u0 true))

    ;; tenmetsu
    (try! (contract-call? .memegoat-community-pools-v1 set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u22 true))
    (try! (contract-call? .memegoat-community-pools-v1 set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u23 true))
    (try! (contract-call? .memegoat-community-pools-v1 set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u24 true))
    (try! (contract-call? .memegoat-community-pools-v1 set-approval-status 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.tenmetsu u25 true))
    
    (ok true)
  )
)

;; PRIVATE CALLS
(define-private (get-votes-by-op-iter (op uint) (total uint))
  (+ total (get-votes-by-op op))
)
```
