
;; SPDX-License-Identifier: BUSL-1.1

;;
;; lqstx-mint-endpoint-v1-02
;;

(use-trait strategy-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.strategy-trait.strategy-trait)

;; __IF_MAINNET__
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; (use-trait sip-010-trait .sip-010-trait.sip-010-trait)
;; __ENDIF__

(define-constant err-unauthorised (err u3000))
(define-constant err-paused (err u7001))
(define-constant err-request-pending (err u7006))
(define-constant err-request-finalized-or-revoked (err u7007))
(define-constant err-not-whitelisted (err u7008))

(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

(define-constant max-uint u340282366920938463463374607431768211455)

(define-data-var paused bool true)
(define-data-var mint-delay uint u432) ;; mint available 3 day after cycle starts

;; __IF_MAINNET__
(define-data-var request-cutoff uint u300) ;; request must be made 300 blocks before prepare stage starts
(define-constant pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info)))
(define-constant activation-burn-block (get first-burnchain-block-height pox-info))
(define-constant reward-cycle-length (get reward-cycle-length pox-info))
(define-constant prepare-cycle-length (get prepare-cycle-length pox-info))
;; (define-data-var request-cutoff uint u10)
;; (define-constant activation-burn-block u0)
;; (define-constant reward-cycle-length u200)
;; (define-constant prepare-cycle-length u10)
;; __ENDIF__

(define-data-var use-whitelist bool false)
(define-map whitelisted principal bool)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (is-paused)
    (var-get paused))

(define-read-only (is-not-paused-or-fail)
    (ok (asserts! (not (is-paused)) err-paused)))

(define-read-only (get-mint-request-or-fail (request-id uint))
    (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-mint-request-or-fail request-id))

(define-read-only (get-burn-request-or-fail (request-id uint))
    (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-burn-request-or-fail request-id))

(define-read-only (get-mint-requests-pending-or-default (user principal))
    (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-mint-requests-pending-or-default user))

(define-read-only (get-burn-requests-pending-or-default (user principal))
    (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-burn-requests-pending-or-default user))

(define-read-only (get-mint-requests-pending-amount)
    (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-mint-requests-pending-amount))

(define-read-only (get-mint-request-or-fail-many (request-ids (list 1000 uint)))
    (ok (map get-mint-request-or-fail request-ids)))

(define-read-only (get-burn-request-or-fail-many (request-ids (list 1000 uint)))
    (ok (map get-burn-request-or-fail request-ids)))

(define-read-only (get-owner-mint-nft (id uint))
    (contract-call? .li-stx-mint-nft get-owner id))

(define-read-only (get-owner-burn-nft (id uint))
    (contract-call? .li-stx-burn-nft get-owner id))

(define-read-only (validate-mint-request (request-id uint))
    (let (
            (request-details (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-mint-request-or-fail request-id)))
            (recipient (unwrap! (get-owner-mint-nft request-id) err-request-finalized-or-revoked)))
        (asserts! (>= burn-block-height (+ (get-first-burn-block-in-reward-cycle (+ (get requested-at request-details) u1)) (var-get mint-delay))) err-request-pending)
        (ok recipient)))

;; @dev it favours smaller amounts as we do not allow partial burn
(define-read-only (validate-burn-request (request-id uint))
    (let (
            (request-details (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry get-burn-request-or-fail request-id)))
            (recipient (unwrap! (get-owner-burn-nft request-id) err-request-finalized-or-revoked))
            (vaulted-amount (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx get-shares-to-tokens (get wrapped-amount request-details))))
        (asserts! (>= (stx-get-balance 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault) vaulted-amount) err-request-pending)
        (ok { vaulted-amount: vaulted-amount, recipient: recipient })))

;; @dev get-reward-cycle measures end to end
(define-read-only (get-reward-cycle (burn-block uint))
    (/ (- burn-block activation-burn-block) reward-cycle-length))

(define-read-only (get-first-burn-block-in-reward-cycle (reward-cycle uint))
    (+ activation-burn-block (* reward-cycle-length reward-cycle)))

;; @dev get-request-cycle measures request-cutoff to request-cutoff
(define-read-only (get-request-cycle (burn-block uint))
    (/ (- (+ burn-block prepare-cycle-length (var-get request-cutoff)) activation-burn-block) reward-cycle-length))

(define-read-only (get-first-burn-block-in-request-cycle (reward-cycle uint))
    (- (+ activation-burn-block (* reward-cycle-length reward-cycle)) prepare-cycle-length (var-get request-cutoff)))

(define-read-only (get-mint-delay)
    (var-get mint-delay))

(define-read-only (get-request-cutoff)
    (var-get request-cutoff))

(define-read-only (is-whitelisted-or-mint-for-all (user principal))
    (or (not (var-get use-whitelist)) (default-to false (map-get? whitelisted user))))

;; public calls

(define-public (rebase)
	(let (
            (available-stx (stx-get-balance 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault))
            ;; __IF_MAINNET__
            (deployed-stx (unwrap-panic (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.public-pools-strategy get-amount-in-strategy)))
            ;; (deployed-stx (unwrap-panic (contract-call? .mock-strategy get-amount-in-strategy)))
            ;; __ENDIF__
            (pending-stx (get-mint-requests-pending-amount))
            (total-stx (- (+ available-stx deployed-stx) pending-stx)))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx set-reserve total-stx))
		(ok total-stx)))    

;; @dev the requestor stx is held by the contract until mint can be finalized.
(define-public (request-mint (amount uint))
    (let (            
            (sender tx-sender)
            (rebase-first (try! (rebase)))
            (cycle (get-request-cycle burn-block-height))
            (request-details { requested-by: sender, amount: amount, requested-at: cycle, status: PENDING })
            (request-id (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-request u0 request-details))))
        (try! (is-not-paused-or-fail))
        (asserts! (is-whitelisted-or-mint-for-all sender) err-not-whitelisted)
        (try! (stx-transfer? amount sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-requests-pending-amount (+ (get-mint-requests-pending-amount) amount)))
        (try! (contract-call? .li-stx-mint-nft mint request-id amount sender))
        (try! (rebase))
        (print { type: "mint-request", id: request-id, details: request-details })
        (ok request-id)))

(define-public (revoke-mint (request-id uint))
    (let (
            (rebase-first (try! (rebase)))
            (request-details (try! (get-mint-request-or-fail request-id)))
            (recipient (unwrap! (unwrap-panic (get-owner-mint-nft request-id)) err-request-finalized-or-revoked)))
        (try! (is-not-paused-or-fail))
        (asserts! (is-eq tx-sender recipient) err-unauthorised)
        (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault proxy-call 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.stx-transfer-proxy (unwrap-panic (to-consensus-buff? { ustx: (get amount request-details), recipient: recipient }))))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-request request-id (merge request-details { status: REVOKED })))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-requests-pending-amount (- (get-mint-requests-pending-amount) (get amount request-details))))
        (try! (contract-call? .li-stx-mint-nft burn request-id))
        (try! (rebase))
        (ok true)))

(define-public (request-burn (amount uint))
    (let (
            (sender tx-sender)
            (rebase-first (try! (rebase)))
            (cycle (get-request-cycle burn-block-height))
            (vlqstx-amount (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx get-tokens-to-shares amount))
            (request-details { requested-by: sender, amount: amount, wrapped-amount: vlqstx-amount, requested-at: cycle, status: PENDING })
            (request-id (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-burn-request u0 request-details))))
        (try! (is-not-paused-or-fail))
        (print { type: "burn-request", id: request-id, details: request-details })
        (if (>= (stx-get-balance 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault) amount)
            (begin
                (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-burn amount sender))
                (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault proxy-call 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.stx-transfer-proxy (unwrap-panic (to-consensus-buff? { ustx: amount, recipient: sender }))))
                (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-burn-request request-id (merge request-details { status: FINALIZED })))
                (try! (rebase))
                (ok {request-id: request-id, status: FINALIZED })
            )
            (begin
                (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx mint amount sender))
                (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx transfer vlqstx-amount sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry none))            
                (try! (contract-call? .li-stx-burn-nft mint request-id amount sender))
                (try! (rebase))
                (ok { request-id: request-id, status: PENDING })))))

(define-public (revoke-burn (request-id uint))
    (let (
            (rebase-first (try! (rebase)))
            (request-details (try! (get-burn-request-or-fail request-id)))
            (recipient (unwrap! (unwrap-panic (get-owner-burn-nft request-id)) err-request-finalized-or-revoked))
            (lqstx-amount (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx get-shares-to-tokens (get wrapped-amount request-details))))
        (try! (is-not-paused-or-fail))
        (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)
        (asserts! (is-eq tx-sender recipient) err-unauthorised)
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry transfer (get wrapped-amount request-details) recipient 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx burn (get wrapped-amount request-details) recipient))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-burn-request request-id (merge request-details { status: REVOKED })))
        (try! (contract-call? .li-stx-burn-nft burn request-id))
        (try! (rebase))
        (ok true)))

(define-public (finalize-mint (request-id uint))
    (let (
            (rebase-first (try! (rebase)))
            (request-details (try! (get-mint-request-or-fail request-id)))
            (recipient (unwrap! (unwrap-panic (get-owner-mint-nft request-id)) err-request-finalized-or-revoked)))
        (try! (validate-mint-request request-id))
        (try! (is-not-paused-or-fail))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-mint (get amount request-details) recipient))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-request request-id (merge request-details { status: FINALIZED })))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-mint-requests-pending-amount (- (get-mint-requests-pending-amount) (get amount request-details))))
        (try! (contract-call? .li-stx-mint-nft burn request-id))
        (try! (rebase))
        (ok true)))

(define-public (finalize-mint-many (request-ids (list 1000 uint)))
    (fold check-err (map finalize-mint request-ids) (ok true)))

(define-public (finalize-burn (request-id uint))
    (let (            
            (rebase-first (try! (rebase)))
            (request-details (try! (get-burn-request-or-fail request-id)))
            (transfer-vlqstx (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry transfer (get wrapped-amount request-details) (as-contract tx-sender) 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx)))
            (recipient (unwrap! (unwrap-panic (get-owner-burn-nft request-id)) err-request-finalized-or-revoked))
            (validation-data (try! (validate-burn-request request-id))))
        (try! (is-not-paused-or-fail))        
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx burn (get wrapped-amount request-details) (as-contract tx-sender)))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-burn (get vaulted-amount validation-data) (as-contract tx-sender)))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-vault proxy-call 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.stx-transfer-proxy (unwrap-panic (to-consensus-buff? { ustx: (get vaulted-amount validation-data), recipient: recipient }))))
        (try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-registry set-burn-request request-id (merge request-details { status: FINALIZED })))
        (try! (contract-call? .li-stx-burn-nft burn request-id))
        (try! (rebase))
        (ok true)))

(define-public (finalize-burn-many (request-ids (list 1000 uint)))
    (fold check-err (map finalize-burn request-ids) (ok true)))

;; governance calls

(define-public (set-use-whitelist (new-use bool))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set use-whitelist new-use))))

(define-public (set-whitelisted (user principal) (new-whitelisted bool))
    (begin
        (try! (is-dao-or-extension))
        (set-whitelisted-private user new-whitelisted)))

(define-public (set-whitelisted-many (users (list 1000 principal)) (new-whitelisteds (list 1000 bool)))
    (begin
        (try! (is-dao-or-extension))
        (fold check-err (map set-whitelisted-private users new-whitelisteds) (ok true))))

(define-public (set-paused (new-paused bool))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set paused new-paused))))

(define-public (set-mint-delay (new-delay uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set mint-delay new-delay))))

(define-public (set-request-cutoff (new-cutoff uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set request-cutoff new-cutoff))))

;; privileged calls

;; private calls

(define-private (sum-strategy-amounts (strategy <strategy-trait>) (accumulator (response uint uint)))
	(ok (+ (try! (contract-call? strategy get-amount-in-strategy)) (try! accumulator)))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior
        ok-value result
        err-value (err err-value)))

(define-private (pop (target (list 1000 uint)) (idx uint))
    (match (slice? target (+ idx u1) (len target))
        some-value (unwrap-panic (as-max-len? (concat (unwrap-panic (slice? target u0 idx)) some-value) u1000))
        (unwrap-panic (slice? target u0 idx))))

(define-private (set-whitelisted-private (user principal) (new-whitelisted bool))
    (ok (map-set whitelisted user new-whitelisted)))

