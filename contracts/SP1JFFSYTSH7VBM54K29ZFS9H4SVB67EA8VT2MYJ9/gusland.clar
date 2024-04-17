;; GUSLAND v.1.0
;; guscoinstx.xyz

;; Storage
(define-map chosen-ids { number: uint } { round-id: uint, pick: uint, ticket: uint })
(define-map participants { round-id: uint, participant-ticket-id: uint } { ticket-id: uint, wallet: principal, block: uint })
(define-map winners { round-id: uint, winner-id: uint } { ticket-id: uint, winner-wallet: principal, block: uint })

;; Constants and Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant FEES-WALLET 'SP1CQ629JWQP67FA6A905NHFCV4ZDE9FT983CV3PZ)
(define-constant BURN-WALLET 'SP000000000000000000002Q6VF78)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-SALE-NOT-ACTIVE (err u102))
(define-constant ERR-SALE-ACTIVE (err u103))
(define-constant REACHED-BLOCK-PICK-LIMIT (err u104))
(define-constant REACHED-WINNER-TICKETS-LIMIT (err u105))
(define-constant REACHED-LIMIT-TICKETS (err u106))
(define-constant ERR-SOLD-OUT (err u107))

;; Variables
(define-data-var sale-active bool false)
(define-data-var limit-tickets uint u0)
(define-data-var sold-tickets uint u0)
(define-data-var winners-limit uint u5)
(define-data-var winner-id uint u1)
(define-data-var round uint u1)
(define-data-var participant-ticket-id uint u0)
(define-data-var price uint u0)
(define-data-var mint-limit uint u0)
(define-data-var win-ticket uint u0)
(define-data-var last-block uint u0)
(define-data-var last-vrf (buff 64) 0x00)
(define-data-var b-idx uint u0)
(define-data-var ticket-id uint u0)
(define-data-var pick uint u1)

;; Get the mint limit
(define-read-only (get-mint-limit)
    (ok (var-get mint-limit)))

;; Check sales active
(define-read-only (sale-enabled)
    (ok (var-get sale-active)))

;; Get a price for ticket
(define-read-only (get-price-in-gus)
    (ok (var-get price)))

;; Get a round info
(define-read-only (get-round-info)
    (ok (var-get round)))

;; Get a number sold tickets
(define-read-only (get-sold-tickets)
    (ok (var-get sold-tickets)))

;; Get a prize pool
(define-read-only (get-prize-pool)
    (ok (* (var-get price) (var-get sold-tickets))))

;; Get a winner limit
(define-read-only (get-winners-limit)
    (ok (var-get winners-limit)))

;; Get participant by round-id & ticket-id
(define-read-only (get-participant-info (id-round uint) (id uint))
    (ok (map-get? participants (tuple (round-id id-round) (participant-ticket-id id))))
)

;; Get winner by round-id & id
(define-read-only (get-winner-info (id-round uint) (id uint))
    (ok (map-get? winners (tuple (round-id id-round) (winner-id id))))
)

;; Set sale flag (only contract owner)
(define-public (flip-sale)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Set price (only contract owner)
(define-public (set-price-in-gus (new-price uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set price new-price)
    (ok true)))

;; Set mint limit (only contract owner)
(define-public (set-mint-limit (limit uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set mint-limit limit)
    (ok true)))

;; Claim ticket
(define-public (claim-ticket)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (< (var-get sold-tickets) (var-get mint-limit)) ERR-SOLD-OUT)
        (try! (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer (var-get price) tx-sender (as-contract tx-sender) none))
        (map-set participants { round-id: (var-get round), participant-ticket-id: (var-get participant-ticket-id) } { ticket-id: (var-get participant-ticket-id), wallet: tx-sender, block: block-height })    
        (var-set limit-tickets (+ (var-get limit-tickets) u1))
        (var-set sold-tickets (+ (var-get sold-tickets) u1))
        (print (map-get? participants (tuple (round-id (var-get round)) (participant-ticket-id (var-get participant-ticket-id)))))
        (var-set participant-ticket-id (+ (var-get participant-ticket-id) u1))
  (ok true))
)

;; Claim 5 tickets
(define-public (claim-five-tickets)
    (begin
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
    (ok true)))

;; Claim 10 tickets
(define-public (claim-ten-tickets)
    (begin
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
        (try! (claim-ticket))
    (ok true)))

;; Make a payment (only contract owner)
(define-public (finalize)
    (let
        ((prize-pool (* (var-get price) (var-get sold-tickets)))
        (winner-pool (/ (* u15 prize-pool) u100))
        (burn-pool (/ (* u15 prize-pool) u100))
        (fees (/ (* u10 prize-pool) u100)))
            (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
            (asserts! (not (var-get sale-active)) ERR-SALE-ACTIVE)
                (begin
                    (print "Winner #1")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer winner-pool tx-sender (unwrap-panic (get winner-wallet (map-get? winners (tuple (round-id (var-get round)) (winner-id u1))))) none)))
                    (print "Winner #2")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer winner-pool tx-sender (unwrap-panic (get winner-wallet (map-get? winners (tuple (round-id (var-get round)) (winner-id u2))))) none)))
                    (print "Winner #3")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer winner-pool tx-sender (unwrap-panic (get winner-wallet (map-get? winners (tuple (round-id (var-get round)) (winner-id u3))))) none)))
                    (print "Winner #4")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer winner-pool tx-sender (unwrap-panic (get winner-wallet (map-get? winners (tuple (round-id (var-get round)) (winner-id u4))))) none)))
                    (print "Winner #5")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer winner-pool tx-sender (unwrap-panic (get winner-wallet (map-get? winners (tuple (round-id (var-get round)) (winner-id u5))))) none)))
                    (print "Burn")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer burn-pool tx-sender BURN-WALLET none)))
                    (print "Service fees")
                    (try! (as-contract (contract-call? 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token transfer fees tx-sender FEES-WALLET none)))
                (ok true))))

;; Update for next round (only contract owner)
(define-public (update)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get sale-active)) ERR-SALE-ACTIVE)
        (var-set limit-tickets u0)
        (var-set sold-tickets u0)
        (var-set winner-id u1)
        (var-set participant-ticket-id u0)
        (var-set price u0)
        (var-set mint-limit u0)
        (var-set win-ticket u0)
        (var-set last-block u0)
        (var-set last-vrf 0x00)
        (var-set b-idx u0)
        (var-set ticket-id u0)
        (var-set winners-limit u5)
        (var-set pick u1)
        (var-set round (+ (var-get round) u1))
    (ok true)))

;; RNG MAGIC
;; Pick winners (only contract owner)
(define-public (pick-five-tickets)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
            (try! (pick-win-ticket))
            (try! (pick-win-ticket))
            (try! (pick-win-ticket))
            (try! (pick-win-ticket))
            (try! (pick-win-ticket))
    (ok true)))

(define-private (pick-win-ticket)
    (let ((limit-tickets-ids (var-get limit-tickets)))
        (asserts! (> limit-tickets-ids u0) REACHED-LIMIT-TICKETS)
        (asserts! (> (var-get winners-limit) u0) REACHED-WINNER-TICKETS-LIMIT)
        (let ((random-id (try! (cycle-random-id limit-tickets-ids))))
    (ok random-id))))

(define-private (swap-container (id uint) (idx uint) (ids-limit-tickets uint))
    (let ((top (- ids-limit-tickets u1))
          (top-id (default-to top (get ticket (map-get? chosen-ids { number: top })))))
        (map-set chosen-ids { number: top } { round-id: (var-get round), pick: (var-get pick), ticket: id })
        (map-set chosen-ids { number: idx } { round-id: (var-get round), pick: (var-get pick), ticket: top-id })
        (var-set limit-tickets top)))
      
(define-private (cycle-random-id (limit-tickets-ids uint))
     (let ((byte-idx (var-get b-idx)))
          (if (is-eq (var-get last-block) block-height)
              (begin
                  (asserts! (< byte-idx u62) REACHED-BLOCK-PICK-LIMIT)
                  (let ((picked-idx (mod (rand byte-idx) limit-tickets-ids))
                        (picked-id (default-to picked-idx (get ticket (map-get? chosen-ids { number: picked-idx })))))
                      (swap-container picked-id picked-idx limit-tickets-ids)
                      (var-set b-idx (+ byte-idx u2))
                      (var-set win-ticket picked-id)
                      (var-set pick (+ (var-get pick) u1))
                      (var-set winners-limit (- (var-get winners-limit) u1))
                      (map-set winners { round-id: (var-get round), winner-id: (var-get winner-id) } { ticket-id: (var-get win-ticket), winner-wallet: (unwrap-panic (get wallet (map-get? participants (tuple (round-id (var-get round)) (participant-ticket-id (var-get win-ticket)))))), block: block-height})
                      (print (map-get? winners (tuple (round-id (var-get round)) (winner-id (var-get winner-id)))))
                      (var-set winner-id (+ (var-get winner-id) u1))
                      (ok picked-id)))
              (begin
                  (set-vrf)
                  (let ((picked-idx (mod (rand byte-idx) limit-tickets-ids))
                        (picked-id (default-to picked-idx (get ticket (map-get? chosen-ids { number: picked-idx })))))
                      (var-set last-block block-height)
                      (swap-container picked-id picked-idx limit-tickets-ids)
                      (var-set b-idx u2)
                      (var-set win-ticket picked-id)
                      (var-set pick (+ (var-get pick) u1))
                      (var-set winners-limit (- (var-get winners-limit) u1))
                      (map-set winners { round-id: (var-get round), winner-id: (var-get winner-id) } { ticket-id: (var-get win-ticket), winner-wallet: (unwrap-panic (get wallet (map-get? participants (tuple (round-id (var-get round)) (participant-ticket-id (var-get win-ticket)))))), block: block-height})
                      (print (map-get? winners (tuple (round-id (var-get round)) (winner-id (var-get winner-id)))))
                      (var-set winner-id (+ (var-get winner-id) u1))
                      (ok picked-id))))))

(define-private (set-vrf)
    (var-set last-vrf (sha512 (unwrap-panic (get-block-info? vrf-seed (- block-height u1))))))

(define-private (rand (byte-idx uint))
    (let ((vrf (var-get last-vrf)) )
        (+ 
            (* (buff-to-uint-be (unwrap-panic (element-at vrf byte-idx))) u256)
            (buff-to-uint-be (unwrap-panic (element-at vrf (+ byte-idx u1))))
        )
    )
)