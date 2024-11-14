;; Corgi Soldiers are 3x more effective in battle

(define-constant err-unauthorized (err u401))

(define-constant corgi-soliders u3)
(define-constant contract (as-contract tx-sender))
(define-constant deployer tx-sender)

(define-data-var factor uint u1)
(define-data-var blocks-per-epoch uint u5)
(define-data-var supply-per-epoch uint u100000000)
(define-data-var last-reset-block uint u0)
(define-data-var current-epoch uint u0)

;; Storage
(define-map bids {bidder: principal, epoch: uint} {price: uint})
(define-map highest-bidder uint principal)
(define-map highest-bid uint uint)
(define-map bid-count uint uint)
(define-map prize-claimed uint bool)

;; --- Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Create a new bid
(define-private (bid (new-price uint))
    (let
    (
        ;; if bidder has already bid, add the new bid to the existing one
        (existing-bid (default-to u0 (get price (map-get? bids {bidder: tx-sender, epoch: (get-current-epoch)}))))
        (updated-bid (+ new-price existing-bid))
    )

    (map-set highest-bidder (get-current-epoch)
        (if
        (> updated-bid (default-to u0 (map-get? highest-bid (get-current-epoch))))
        tx-sender
        (default-to deployer (map-get? highest-bidder (get-current-epoch)))
        )
    )

    (map-set highest-bid (get-current-epoch)
        (if
        (> updated-bid (default-to u0 (map-get? highest-bid (get-current-epoch))))
        updated-bid
        (default-to u0 (map-get? highest-bid (get-current-epoch)))
        )
    )

    (map-set bids {bidder: tx-sender, epoch: (get-current-epoch)} {price: updated-bid})
    (map-set bid-count (get-current-epoch) (+ (default-to u0 (map-get? bid-count (get-current-epoch))) u1))
    (print {
        notification: "updated-bid",
        payload: {
        bidder: tx-sender,
        price: updated-bid,
        bid-count: (map-get? bid-count (get-current-epoch)),
        }
    })
    (ok (map-get? bid-count (get-current-epoch)))
    )
)

;; Get highest bid
(define-read-only (get-highest-bid (epoch uint))
    (map-get? highest-bid epoch)
)

;; Get higest bidder
(define-read-only (get-highest-bidder (epoch uint))
    (map-get? highest-bidder epoch)
)

;; Get latest bid of
(define-read-only (get-latest-bid-of (bidder principal) (epoch uint))
    (default-to u0 (get price (map-get? bids {bidder: bidder, epoch: epoch})))
)

;; Get winner: if max-bid-count
(define-read-only (get-winner (epoch uint))
    (default-to deployer (map-get? highest-bidder epoch))
)

;; Helper function to check if an epoch has passed
(define-private (epoch-passed)
    (> (- block-height (var-get last-reset-block)) (var-get blocks-per-epoch))
)

;; Increment the epoch if an epoch has passed
(define-private (try-reset-epoch)
    (if (epoch-passed)
        (let (
            (last-epoch (var-get current-epoch))
        )
            (var-set current-epoch (+ last-epoch u1))
            (var-set last-reset-block block-height)
            (print {
                notification: "epoch-reset",
                payload: {
                    epoch: (var-get current-epoch),
                    last-epoch: last-epoch,
                    last-reset-block: (var-get last-reset-block),
                    block-height: block-height,
                    winner: (get-winner last-epoch),
                    highest-bid: (get-highest-bid last-epoch),
                }
            })
            true
        )
        false
    )
)

(define-public (battle (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-kit tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (bid-amount (* ENERGY (get-factor)))
            (TOKENS (if (is-eq creature-id corgi-soliders) (* bid-amount u3) bid-amount))
            (original-sender tx-sender)
            (is-reset (try-reset-epoch))
        )
        (if is-reset
            (try! (as-contract (contract-call? .fuji-apples transfer (var-get supply-per-epoch) contract (get-winner (- (get-current-epoch) u1)) none)))
            false
        )
        (bid TOKENS)
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-kit get-untapped-amount creature-id tx-sender)))
            (energy-amount (* untapped-energy (get-factor)))
            (bid-amount (if (is-eq creature-id corgi-soliders) (* energy-amount u3) energy-amount))
        )
        bid-amount
    )
)

;; Getters
(define-read-only (get-factor)
    (var-get factor)
)

(define-read-only (get-blocks-per-epoch)
    (var-get blocks-per-epoch)
)

(define-read-only (get-per-epoch)
    (var-get supply-per-epoch)
)

(define-read-only (get-last-reset-block)
    (var-get last-reset-block)
)

(define-read-only (get-current-epoch)
    (var-get current-epoch)
)

;; Setters
(define-public (set-factor (new-factor uint))
    (begin
        (try! (is-authorized))
        (ok (var-set factor new-factor))
    )
)

(define-public (set-blocks-per-epoch (new-blocks-per-epoch uint))
    (begin
        (try! (is-authorized))
        (ok (var-set blocks-per-epoch new-blocks-per-epoch))
    )
)

(define-public (set-supply-per-epoch (new-supply-per-epoch uint))
    (begin
        (try! (is-authorized))
        (ok (var-set supply-per-epoch new-supply-per-epoch))
    )
)

;; Utility functions

(define-read-only (get-blocks-until-next-epoch)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-block)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (- (var-get blocks-per-epoch) blocks-in-current-epoch)
    )
)

(define-read-only (get-epoch-progress)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-block)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (/ (* blocks-in-current-epoch u100) (var-get blocks-per-epoch))
    )
)