---
title: "Trait pay-to-vote"
draft: true
---
```
;; Election Smart Contract modified from original @betosmith2000 code to include payment for casting a vote.
;; The possibiltiy to close and re-open the vote has also been added

;; A simple vote smart contract for 2 candidates where
;; you can vote for your favorite candidate and find out
;; who is winning!

;; error consts
(define-constant ERR_STX_TRANSFER u0)

;; Variables for candidates
(define-data-var candidate1 int 0)
(define-data-var candidate2 int 0)
(define-data-var allowVote int 0)
(define-data-var price uint u1)

;; get price
(define-read-only (get-price)
    (var-get price))

;; get candidate1 read-only
(define-read-only (get-candidate1)
    (var-get candidate1))

;; get candidate2 read-only
(define-read-only (get-candidate2)
  (var-get candidate2))

;; Public function to get current winner
(define-public (get-winner)
    (ok (if (is-eq (var-get candidate1) (var-get candidate2)) 0 (if (> (var-get candidate1) (var-get candidate2)) 1 2))))

;; Public function to vote for candidate 1
(define-public (vote-for-candidate1)
    (begin
         ;; Pay to vote
        (unwrap! (stx-transfer? (var-get price) tx-sender (as-contract tx-sender)) (err ERR_STX_TRANSFER))
        (var-set candidate1 (+ (var-get candidate1) (if (is-eq (var-get allowVote) 1) 1 0)))
        (ok (var-get candidate1))))

;; Public function to vote for candidate 2
(define-public (vote-for-candidate2)
    (begin
      ;; Pay to vote
      (unwrap! (stx-transfer? (var-get price) tx-sender (as-contract tx-sender)) (err ERR_STX_TRANSFER))
      (var-set candidate2 (+ (var-get candidate2) (if (is-eq (var-get allowVote) 1) 1 0)))
      (ok (var-get candidate2))))

;; Public function to open the vote
(define-public (allow-vote)
  (begin
    (var-set allowVote 1)
    (ok (var-get allowVote))))

;; Public function to stop vote
(define-public (close-vote)
    (begin
        (var-set allowVote 0)
        (ok (var-get allowVote))))
```
