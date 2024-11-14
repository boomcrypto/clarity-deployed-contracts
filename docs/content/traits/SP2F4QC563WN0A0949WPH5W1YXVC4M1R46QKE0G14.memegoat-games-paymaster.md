---
title: "Trait memegoat-games-paymaster"
draft: true
---
```
;;
;; MEMEGOAT GAMES PAY MASTER
;;

(impl-trait .extension-trait.extension-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; ERRS
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-ZERO-VALUE (err u1001))
(define-constant ERR-NOT-OPERATOR (err u1002))
(define-constant ERR-INVALID-GAME-ID (err u1003))
(define-constant ERR-INVALID-USER (err u1004))
(define-constant ERR-USER-RECORD (err u1005))
(define-constant ERR-USER-TICKET-RECORD (err u1006))
(define-constant ERR-INVALID-BLOCK-TIME (err u1007))
(define-constant ERR-INVALID-TOURNAMENT-TYPE (err u1008))
(define-constant ERR-INVALID-TOKEN (err u1009))
(define-constant ERR-ALREADY-PAID (err u1010))
(define-constant ERR-NO-REWARDS-FOUND (err u1011))
(define-constant ERR-INVALID-AMOUNT (err u1012))
(define-constant ERR-AMOUNT-NOT-EQUAL (err u1013))
(define-constant ERR-AMOUNT-GREATER-THAN-RESERVE (err u1014))
(define-constant ERR-RECORD-NOT-FOUND (err u1015))

;; STORAGE
(define-constant TREASURY-FEE u2)
(define-constant GAME-ID u1)
(define-constant SPORT-ID u2)
(define-data-var game-ticket-price uint u0)
(define-data-var next-id-games uint u0)
(define-data-var next-id-sports uint u0)
(define-data-var total-tickets-sold uint u0)
(define-data-var stx-in-reserve uint u0)
(define-data-var game-operator principal 'SP3HFMZXVH7A2MFY0VR0N22C45HV2CCFA06GRQY28)
(define-data-var payment-token principal 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
(define-map tournament-record {game-id: uint, type: uint} {total-tickets-used: uint, total-no-players: uint, record-block: uint, no-of-claims: uint, total-claimed: uint, winners: (optional (list 1000 {addr: principal, amount: uint}))})
(define-map user-reward-records {user: principal, game-id: uint, type: uint} {rewards-won: uint, paid-out: bool})
(define-map user-ticket-records {user: principal} {total-tickets-bought: uint})

;; READ ONLY CALLS
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .memegoat-community-dao) (contract-call? .memegoat-community-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED))
)

(define-read-only (get-next-game-id (type uint))
    (if (is-eq type GAME-ID)
        (var-get next-id-games)
        (var-get next-id-sports)
    )
)

(define-read-only (is-operator)
	(ok (asserts! (is-eq tx-sender (var-get game-operator)) ERR-NOT-OPERATOR))
)

(define-read-only (get-game-operator)
    (ok (var-get game-operator))
)

(define-read-only (get-stx-reserve)
    (ok (var-get stx-in-reserve))
)

(define-read-only (get-total-tickets-sold)
    (ok (var-get total-tickets-sold))
)

(define-read-only (get-ticket-price)
    (ok (var-get game-ticket-price))
)

(define-read-only (get-payment-token)
  (ok (var-get payment-token))
)

(define-read-only (get-treasury-fee)
  (ok TREASURY-FEE)
)

(define-read-only (get-games-record (gid uint) (type uint))
  (ok (unwrap! (get-tournament-record-exists gid type) ERR-INVALID-GAME-ID))
)

(define-read-only (get-tournament-record-exists (gid uint) (type uint))
    (map-get? tournament-record {game-id: gid, type: type})
)

(define-read-only (calc-tickets (no-of-tickets uint))
    (* no-of-tickets (var-get game-ticket-price))
)

(define-read-only (get-user-rewards-record (gid uint) (type uint) (user principal))
    (ok (unwrap! (map-get? user-reward-records {user: user, game-id: gid, type: type}) ERR-RECORD-NOT-FOUND))
)

(define-read-only (get-user-tickets-record-exists (user principal))
    (map-get? user-ticket-records {user: user})
)

(define-read-only (get-user-tickets-record (user principal))
    (ok (default-to {total-tickets-bought: u0} (get-user-tickets-record-exists user)))
)

(define-public (set-ticket-price (price uint))
    (begin
        (try! (is-dao-or-extension))
        (asserts! (> price u0) ERR-ZERO-VALUE)
        (ok (var-set game-ticket-price price))
    )
)

(define-public (set-ticket-operator (operator_ principal))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set game-operator operator_))
    )
)

(define-public (set-payment-token (token principal))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set payment-token token))
    )
)

(define-public (store-tournament-record 
    (type uint)
    (token-trait <ft-trait>) 
    (rewards (list 1000 {addr: principal, amount: uint})) 
    (tournament-data {no-of-players: uint, total-tickets-used: uint}) 
    )
    (let
        (
            (gid (get-next-game-id type))
            (sender tx-sender)
            (tickets-used (get total-tickets-used tournament-data))
            (no-of-players (get no-of-players tournament-data))
            (total-stx-used (calc-tickets tickets-used))
            (treasury-fee (calc-treasury-fee total-stx-used))
            (stx-reserve (var-get stx-in-reserve))
            (expected-amt (+ (fold sum-reward-amount-iter rewards u0) treasury-fee))
        )

        ;; checks
        (try! (is-operator))
        ;; check that total-tickets-used is no zero amount
        (asserts! (and (> tickets-used u0) (> no-of-players u0)) ERR-ZERO-VALUE)
        ;; check that no zero amount is sent
        (asserts! (is-eq (len (filter check-reward-amount-iter rewards)) u0) ERR-INVALID-AMOUNT)
        ;; check that total stx reward is equivalent to total stx used
        (asserts! (<= expected-amt total-stx-used) ERR-AMOUNT-NOT-EQUAL)
        ;; check that allocated rewards are not greater than the reserve
        (asserts! (<= expected-amt stx-reserve) ERR-AMOUNT-GREATER-THAN-RESERVE)
        ;; check tournament type
        (asserts! (or (is-eq  type GAME-ID) (is-eq  type SPORT-ID)) ERR-INVALID-TOURNAMENT-TYPE)

        (map-set tournament-record {game-id: gid, type: type}
            {
                total-tickets-used: tickets-used,
                total-no-players: no-of-players,
                winners: (some rewards),
                no-of-claims: (len rewards),
                total-claimed: u0,
                record-block: burn-block-height
            }
        )

        ;; store user rewards
        (fold store-user-reward-iter rewards {gid: gid, type: type})
        
        (if (> treasury-fee u0)
            (begin
                ;; pay out treasury fee
                (as-contract (try! (contract-call? .memegoat-vault transfer-ft token-trait treasury-fee .memegoat-treasury)))  
                ;; update reserve
                (var-set stx-in-reserve (- stx-reserve treasury-fee))
            )
            true
        )

        ;; update tournament id
        (ok (store-next-game-id type gid))
    )
)

(define-public (buy-tickets (no-of-tickets uint) (token-trait <ft-trait>))
    (let
        (
            (sender tx-sender)
            (tickets-sold (var-get total-tickets-sold))
            (stx-reserve (var-get stx-in-reserve))
            (amount (calc-tickets no-of-tickets))
            (user-rec (unwrap! (get-user-tickets-record sender) ERR-USER-RECORD))
            (user-tickets (get total-tickets-bought user-rec))
            (updated-user-rec (merge user-rec {
                total-tickets-bought: (+ user-tickets no-of-tickets)
            }))
        )
        ;; checks
        (asserts! (is-eq (contract-of token-trait) (var-get payment-token)) ERR-INVALID-TOKEN)
        (asserts! (> amount u0) ERR-ZERO-VALUE)

        ;; transfer to vault
        (try! (contract-call? token-trait transfer amount tx-sender .memegoat-vault none))

        ;; update stx in reserve
        (var-set stx-in-reserve (+ amount stx-reserve))

        ;; update records
        (var-set total-tickets-sold (+ no-of-tickets tickets-sold))

        (ok (map-set user-ticket-records {user: sender} updated-user-rec))
    )
)

(define-public (claim-rewards (gid uint) (type uint) (token-trait <ft-trait>))
    (let
        (
            (sender tx-sender)
            (stx-reserve (var-get stx-in-reserve))
            (game-rec (try! (get-games-record gid type)))
            (user-tickets-rec (get-user-tickets-record-exists sender))
            (user-rec (unwrap! (get-user-rewards-record gid type sender) ERR-USER-RECORD))
            (reward (get rewards-won user-rec))
            (has-claimed (get paid-out user-rec))
            (updated-game-rec (merge game-rec {
                total-claimed: (+ (get total-claimed game-rec) u1)
            }))
            (updated-user-rec (merge user-rec {
                paid-out: true
            }))  
        )
        ;; checks
        (asserts! (is-eq (contract-of token-trait) (var-get payment-token)) ERR-INVALID-TOKEN)
        (asserts! (not has-claimed) ERR-ALREADY-PAID)
        (asserts! (<= reward stx-reserve) ERR-AMOUNT-GREATER-THAN-RESERVE)
        (asserts! (or (is-eq  type GAME-ID) (is-eq  type SPORT-ID)) ERR-INVALID-TOURNAMENT-TYPE)
        (asserts! (is-some user-tickets-rec) ERR-INVALID-USER)

        ;; transfer to user
        (as-contract (try! (contract-call? .memegoat-vault transfer-ft token-trait reward sender)))  

        ;; update stx in reserve
        (var-set stx-in-reserve (- stx-reserve reward)) 

        ;; update records
        (map-set tournament-record {game-id: gid, type: type} updated-game-rec)

        (ok (map-set user-reward-records {game-id: gid, type: type, user: sender} updated-user-rec))
    )
)

;; Private
(define-private (check-reward-amount-iter (rewards {addr: principal, amount: uint}))
  (not (> (get amount rewards) u0))
)

(define-private (sum-reward-amount-iter (rewards {addr: principal, amount: uint}) (amount uint))
  (begin 
    (+ amount (get amount rewards))
  )
)

(define-private (calc-treasury-fee (total-stx-used uint))
    (/ (* total-stx-used TREASURY-FEE) u100)
)

(define-private (store-user-reward-iter (record {addr: principal, amount: uint}) (tournament-rec {gid: uint, type: uint}))
    (let
        (
            (addr (get addr record))
            (amount (get amount record))
            (gid (get gid tournament-rec))
            (type (get type tournament-rec))
            (has-tickets (is-some (get-user-tickets-record-exists addr)))
            (record- (get-user-rewards-record-without-fail gid type addr))
            (updated-user-record (merge record- {
                rewards-won: amount
            }))
        )
        (if has-tickets
            (map-set user-reward-records {user: addr, game-id: gid, type: type} updated-user-record)
            false
        )
        tournament-rec
    )
)

(define-private (store-next-game-id (type uint) (prev-id uint))
    (if (is-eq type GAME-ID)
        (var-set next-id-games (+ prev-id u1))
        (var-set next-id-sports (+ prev-id u1))
    )
)

(define-private (get-user-rewards-record-without-fail (gid uint) (type uint) (user principal))
    (default-to {rewards-won: u0, paid-out: false} (map-get? user-reward-records {user: user, game-id: gid, type: type}))
)

;; --- Extension callback

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true)
)

(begin 
    (ok (var-set game-ticket-price u100000))
)
```
