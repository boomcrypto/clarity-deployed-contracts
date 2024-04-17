
;; SPDX-License-Identifier: BUSL-1.1

;;
;; lqstx-mint-endpoint-v1-01
;;
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-request-pending (err u1006))
(define-constant err-request-finalized-or-revoked (err u1007))
(define-constant err-not-whitelisted (err u1008))

(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

(define-constant max-uint u340282366920938463463374607431768211455)

(define-data-var paused bool true)
(define-data-var mint-delay uint u432) ;; mint available 3 day after cycle starts

;; corresponds to `first-burnchain-block-height` and `pox-reward-cycle-length` in pox-3
;; __IF_MAINNET__
(define-constant pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info)))
(define-constant activation-burn-block (get first-burnchain-block-height pox-info))
(define-constant reward-cycle-length (get reward-cycle-length pox-info))
;; (define-constant activation-burn-block u0)
;; (define-constant reward-cycle-length u200)
;; __ENDIF__

(define-data-var use-whitelist bool false)
(define-map whitelisted principal bool)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (is-paused)
    (var-get paused))

(define-read-only (is-paused-or-fail)
    (ok (asserts! (not (is-paused)) err-paused)))

(define-read-only (get-mint-request-or-fail (request-id uint))
    (contract-call? .lqstx-mint-registry get-mint-request-or-fail request-id))

(define-read-only (get-burn-request-or-fail (request-id uint))
    (contract-call? .lqstx-mint-registry get-burn-request-or-fail request-id))

(define-read-only (get-mint-requests-pending-or-default (user principal))
    (contract-call? .lqstx-mint-registry get-mint-requests-pending-or-default user))

(define-read-only (get-burn-requests-pending-or-default (user principal))
    (contract-call? .lqstx-mint-registry get-burn-requests-pending-or-default user))

(define-read-only (get-mint-requests-pending-amount)
    (contract-call? .lqstx-mint-registry get-mint-requests-pending-amount))

(define-read-only (get-mint-request-or-fail-many (request-ids (list 1000 uint)))
    (ok (map get-mint-request-or-fail request-ids)))

(define-read-only (get-burn-request-or-fail-many (request-ids (list 1000 uint)))
    (ok (map get-burn-request-or-fail request-ids)))

(define-read-only (validate-mint-request (request-id uint))
    (let (
            (request-details (try! (contract-call? .lqstx-mint-registry get-mint-request-or-fail request-id)))
            (request-id-idx (unwrap! (index-of? (get-mint-requests-pending-or-default (get requested-by request-details)) request-id) err-request-finalized-or-revoked)))
        (asserts! (>= burn-block-height (+ (get-first-burn-block-in-reward-cycle (+ (get requested-at request-details) u1)) (var-get mint-delay))) err-request-pending)
        (ok request-id-idx)))

;; @dev it favours smaller amounts as we do not allow partial burn
(define-read-only (validate-burn-request (request-id uint))
    (let (
            (request-details (try! (contract-call? .lqstx-mint-registry get-burn-request-or-fail request-id)))
            (request-id-idx (unwrap! (index-of? (get-burn-requests-pending-or-default (get requested-by request-details)) request-id) err-request-finalized-or-revoked))
            (vaulted-amount (contract-call? .token-vlqstx get-shares-to-tokens (get wrapped-amount request-details))))
        (asserts! (>= (stx-get-balance .lqstx-vault) vaulted-amount) err-request-pending)
        (ok { vaulted-amount: vaulted-amount, request-id-idx: request-id-idx })))

(define-read-only (get-reward-cycle (burn-block uint))
    (if (>= burn-block activation-burn-block)
        (some (/ (- burn-block activation-burn-block) reward-cycle-length))
        none))

(define-read-only (get-first-burn-block-in-reward-cycle (reward-cycle uint))
    (+ activation-burn-block (* reward-cycle-length reward-cycle)))

(define-read-only (get-mint-delay)
    (var-get mint-delay))

(define-read-only (is-whitelisted-or-mint-for-all (user principal))
    (or (not (var-get use-whitelist)) (default-to false (map-get? whitelisted user))))

;; public calls

;; @dev the requestor stx is held by the contract until mint can be finalized.
(define-public (request-mint (amount uint))
    (let (
            (sender tx-sender)
            (cycle (unwrap-panic (get-reward-cycle burn-block-height)))
            (request-details { requested-by: sender, amount: amount, requested-at: cycle, status: PENDING })
            (request-id (try! (contract-call? .lqstx-mint-registry set-mint-request u0 request-details))))
        (try! (is-paused-or-fail))
        (asserts! (is-whitelisted-or-mint-for-all sender) err-not-whitelisted)
        (try! (stx-transfer? amount sender .lqstx-vault))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending-amount (+ (get-mint-requests-pending-amount) amount)))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending sender (unwrap-panic (as-max-len? (append (get-mint-requests-pending-or-default sender) request-id) u1000))))
        (print { type: "mint-request", id: request-id, details: request-details })
        (ok request-id)))

(define-public (revoke-mint (request-id uint))
    (let (
            (request-details (try! (get-mint-request-or-fail request-id)))
            (mint-requests (get-mint-requests-pending-or-default (get requested-by request-details)))
            (request-id-idx (unwrap! (index-of? mint-requests request-id) err-request-finalized-or-revoked)))
        (try! (is-paused-or-fail))
        (asserts! (is-eq tx-sender (get requested-by request-details)) err-unauthorised)
        (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)
        (try! (contract-call? .lqstx-vault proxy-call .stx-transfer-proxy (unwrap-panic (to-consensus-buff? { ustx: (get amount request-details), recipient: (get requested-by request-details) }))))
        (try! (contract-call? .lqstx-mint-registry set-mint-request request-id (merge request-details { status: REVOKED })))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending-amount (- (get-mint-requests-pending-amount) (get amount request-details))))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending (get requested-by request-details) (pop mint-requests request-id-idx)))
        (ok true)))

(define-public (revoke-burn (request-id uint))
    (let (
            (request-details (try! (get-burn-request-or-fail request-id)))
            (burn-requests (get-burn-requests-pending-or-default (get requested-by request-details)))
            (request-id-idx (unwrap! (index-of? burn-requests request-id) err-request-finalized-or-revoked))
            (lqstx-amount (contract-call? .token-vlqstx get-shares-to-tokens (get wrapped-amount request-details))))
        (try! (is-paused-or-fail))
        (asserts! (is-eq PENDING (get status request-details)) err-request-finalized-or-revoked)
        (asserts! (is-eq tx-sender (get requested-by request-details)) err-unauthorised)
        (try! (contract-call? .lqstx-mint-registry transfer (get wrapped-amount request-details) (as-contract tx-sender) .token-vlqstx))
        (try! (contract-call? .token-vlqstx burn (get wrapped-amount request-details) (as-contract tx-sender)))
        (try! (contract-call? .token-lqstx transfer lqstx-amount (as-contract tx-sender) (get requested-by request-details) none))
        (try! (contract-call? .lqstx-mint-registry set-burn-request request-id (merge request-details { status: REVOKED })))
        (try! (contract-call? .lqstx-mint-registry set-burn-requests-pending (get requested-by request-details) (pop burn-requests request-id-idx)))
        (ok true)))

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

;; privileged calls

(define-public (finalize-mint (request-id uint))
    (let (
            (request-details (try! (get-mint-request-or-fail request-id)))
            (mint-requests (get-mint-requests-pending-or-default (get requested-by request-details)))
            (request-id-idx (try! (validate-mint-request request-id))))
        (try! (is-paused-or-fail))
        (try! (is-dao-or-extension))
        (try! (contract-call? .token-lqstx dao-mint (get amount request-details) (get requested-by request-details)))
        (try! (contract-call? .lqstx-mint-registry set-mint-request request-id (merge request-details { status: FINALIZED })))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending-amount (- (get-mint-requests-pending-amount) (get amount request-details))))
        (try! (contract-call? .lqstx-mint-registry set-mint-requests-pending (get requested-by request-details) (pop mint-requests request-id-idx)))
        (ok true)))

(define-public (finalize-mint-many (request-ids (list 1000 uint)))
    (fold check-err (map finalize-mint request-ids) (ok true)))

(define-public (request-burn (sender principal) (amount uint))
    (let (
            ;; @dev requested-at not used for burn
            (cycle (unwrap-panic (get-reward-cycle burn-block-height)))
            (vlqstx-amount (contract-call? .token-vlqstx get-tokens-to-shares amount))
            (request-details { requested-by: sender, amount: amount, wrapped-amount: vlqstx-amount, requested-at: cycle, status: PENDING })
            (request-id (try! (contract-call? .lqstx-mint-registry set-burn-request u0 request-details))))
        (try! (is-paused-or-fail))
        (try! (is-dao-or-extension))
        (try! (contract-call? .token-vlqstx mint amount tx-sender))
        (try! (contract-call? .token-vlqstx transfer vlqstx-amount tx-sender .lqstx-mint-registry none))
        (try! (contract-call? .lqstx-mint-registry set-burn-requests-pending sender (unwrap-panic (as-max-len? (append (get-burn-requests-pending-or-default sender) request-id) u1000))))
        (print { type: "burn-request", id: request-id, details: request-details })
        (ok { request-id: request-id, status: PENDING })))

(define-public (finalize-burn (request-id uint))
    (let (
            (request-details (try! (get-burn-request-or-fail request-id)))
            (transfer-vlqstx (try! (contract-call? .lqstx-mint-registry transfer (get wrapped-amount request-details) (as-contract tx-sender) .token-vlqstx)))
            (burn-requests (get-burn-requests-pending-or-default (get requested-by request-details)))
            (validation-data (try! (validate-burn-request request-id))))
        (try! (is-paused-or-fail))
        (try! (is-dao-or-extension))
        (try! (contract-call? .token-vlqstx burn (get wrapped-amount request-details) (as-contract tx-sender)))
        (try! (contract-call? .token-lqstx dao-burn (get vaulted-amount validation-data) (as-contract tx-sender)))
        (try! (contract-call? .lqstx-vault proxy-call .stx-transfer-proxy (unwrap-panic (to-consensus-buff? { ustx: (get vaulted-amount validation-data), recipient: (get requested-by request-details) }))))
        (try! (contract-call? .lqstx-mint-registry set-burn-request request-id (merge request-details { status: FINALIZED })))
        (try! (contract-call? .lqstx-mint-registry set-burn-requests-pending (get requested-by request-details) (pop burn-requests (get request-id-idx validation-data))))
        (ok true)))

(define-public (finalize-burn-many (request-ids (list 1000 uint)))
    (fold check-err (map finalize-burn request-ids) (ok true)))

;; private calls

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

