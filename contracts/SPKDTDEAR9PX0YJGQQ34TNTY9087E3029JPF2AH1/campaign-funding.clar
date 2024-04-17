
;; title: campaign-funding
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant error-unknown (err u1))
(define-constant error-not-found (err u2))
(define-constant error-not-allowed (err u3))
(define-constant error-campaign-ended (err u4))
(define-constant error-campaign-already-refunded (err u5))
(define-constant error-campaign-not-ended (err u6))
(define-constant error-contribution-failed (err u7))
(define-constant error-refund-failed (err u8))
(define-constant error-campaign-succeeded-no-refund (err u9))
(define-constant error-already-refunded (err u10))
(define-constant error-already-collected (err u11))
(define-constant error-funding-failed (err u12))
(define-constant error-campaign-failed (err u13))

;; data vars
;;

;; used for campaign ids
(define-data-var campaign-id-nonce uint u0)

;; data maps
;;

;; Campaigns
(define-map campaigns uint {
	owner: principal, ;; address which created the campaign
    title: (string-utf8 200),
    ustx-goal: uint, ;; funding goal (in ustx, 1 ustx = 0.000001 stx)
    end-block-height: uint, ;; when this block height is reached, the campaign will end
    data-hash: (string-utf8 40), ;; hash of off-chain data (data is stored by the application and on-chain hash is compared to validate)
})

;; Campaign funding totals (by campaign ID)
(define-map campaign-funding-totals uint {
    funding-total-amount: uint,
    total-num-contributions: uint,
    is-collected: bool
})

;; Campaign contributions by campaign ID
(define-map campaign-contributions
    {
        campaign-id: uint,
        contributor: principal
    }
    {
        amount: uint,
        is-refunded: bool
    }
)

;; public functions
;;

;; Create a new campaign
(define-public (add-campaign
    (title (string-utf8 200))
    (ustx-goal uint)
    (num-blocks-until-end uint)
    (data-hash (string-utf8 40))
)
    (let ((campaign-id (+ (var-get campaign-id-nonce) u1)))
		(if (and
                (map-set campaigns campaign-id {
                    owner: tx-sender,
                    title: title,
                    ustx-goal: ustx-goal,
                    end-block-height: (+ num-blocks-until-end block-height),
                    data-hash: data-hash,
                })
                (map-set campaign-funding-totals campaign-id {
                    funding-total-amount: u0,
                    total-num-contributions: u0,
                    is-collected: false,
                }))
			(begin
				(var-set campaign-id-nonce campaign-id)
				(ok campaign-id))
			error-unknown
			)
	)
)

;; Update campaign data
(define-public (update-campaign-data
    (campaign-id uint)
    (title (string-utf8 200))
    (data-hash (string-utf8 40))
)
    (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) error-not-found))
        )
        ;; Only the campaign owner can update its data
        (asserts! (is-eq (get owner campaign) tx-sender) error-not-allowed)

        (map-set campaigns campaign-id {
            owner: tx-sender,
            title: title,
            ustx-goal: (get ustx-goal campaign),
            end-block-height: (get end-block-height campaign),
            data-hash: data-hash,
        })
        (ok campaign-id)
    )
)

;; back a campaign
;; increase the contributions by ID
(define-public (contribute-to-campaign
    (campaign-id uint)
    (amount uint)
)
   (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) error-not-found))
            (campaign-funding-total (unwrap! (map-get? campaign-funding-totals campaign-id) error-not-found))
            (previous-contribution-amount (default-to u0 (get amount (map-get? campaign-contributions { campaign-id: campaign-id, contributor: tx-sender }))))
        ) 

        ;; Can only contribute to campaigns that have not ended
        (asserts! (not (unwrap! (is-campaign-expired campaign-id) error-unknown)) error-campaign-ended)

        (begin
            ;; Transfer STX from the tx_sender to the contract
            (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) error-contribution-failed)

            (map-set campaign-funding-totals campaign-id {
                funding-total-amount: (+ amount (get funding-total-amount campaign-funding-total)),
                total-num-contributions: (+ u1 (get total-num-contributions campaign-funding-total)),
                is-collected: false
            })
            (map-set campaign-contributions
                { campaign-id: campaign-id, contributor: tx-sender }
                { amount: (+ amount previous-contribution-amount), is-refunded: false }
            )

            (ok true)
        )
   )
)

;; Refund contribution to given contributor
;; Can be called exactly once for each contributor, after the campaign is finished and if it has not met its goal
(define-public (refund-contribution
    (campaign-id uint)
    (contributor principal)
)
    (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) error-not-found))
            (contribution (unwrap! (map-get? campaign-contributions { campaign-id: campaign-id, contributor: contributor }) error-not-found))
            (campaign-funding-total (unwrap! (map-get? campaign-funding-totals campaign-id) error-not-found))
        )
        ;; Ensure the campaign is expired
        (asserts! (unwrap! (is-campaign-expired campaign-id) error-unknown) error-campaign-not-ended)
        ;; Ensure the campaign did not meet its funding goal
        (asserts! (< (get funding-total-amount campaign-funding-total) (get ustx-goal campaign)) error-campaign-succeeded-no-refund)
        ;; Ensure the contribution has not already been refunded
        (asserts! (not (get is-refunded contribution)) error-already-refunded)
        
        ;; Send STX back to the contributor
        (unwrap! (as-contract (stx-transfer? (get amount contribution) tx-sender contributor)) error-refund-failed)

        ;; Mark as refunded
        (map-set campaign-contributions
            {
                campaign-id: campaign-id,
                contributor: contributor
            }
            {
                amount: (get amount contribution),
                is-refunded: true
            }
        )
        
        (ok true)
    )
)

;; Send the contributed funds to the campaign owner, once finished
;; Can be called exactly once, after the campaign is finished and if it has met its goal
(define-public (fund-campaign
    (campaign-id uint)
)
    (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) error-not-found))
            (campaign-funding-total (unwrap! (map-get? campaign-funding-totals campaign-id) error-not-found))
        )
        ;; Ensure the campaign is expired
        (asserts! (unwrap! (is-campaign-expired campaign-id) error-unknown) error-campaign-not-ended)
        ;; Ensure the campaign met its funding goal
        (asserts! (>= (get funding-total-amount campaign-funding-total) (get ustx-goal campaign)) error-campaign-failed)
        ;; Ensure the funds have not already been collected
        (asserts! (not (get is-collected campaign-funding-total)) error-already-collected)
        
        ;; Send STX to the campaign owner
        (unwrap! (as-contract (stx-transfer? (get funding-total-amount campaign-funding-total) tx-sender (get owner campaign))) error-funding-failed)

        ;; Mark as collected
        (map-set campaign-funding-totals
            campaign-id
            {
                funding-total-amount: (get funding-total-amount campaign-funding-total),
                total-num-contributions: (get total-num-contributions campaign-funding-total),
                is-collected: true
            }
        )
        
        (ok true)
    )
)

;; read only functions
;;
(define-read-only (get-status)
    (ok u"ok")
)

(define-read-only (get-campaign (campaign-id uint))
    (let ((campaign (unwrap! (map-get? campaigns campaign-id) error-not-found)))
        (ok campaign)
    )
)

(define-read-only (is-campaign-expired (campaign-id uint))
    (let ((campaign (unwrap! (map-get? campaigns campaign-id) error-not-found)))
        (ok (>= block-height (get end-block-height campaign)))
    )
)

(define-read-only (get-campaign-funding-totals (campaign-id uint))
    (let ((funding-totals (unwrap! (map-get? campaign-funding-totals campaign-id) error-not-found)))
        (ok funding-totals)
    )
)

(define-read-only (get-contribution-info (campaign-id uint))
    (let ((contribution (unwrap! (map-get? campaign-contributions { campaign-id: campaign-id, contributor: tx-sender }) error-not-found)))
        (ok contribution)
    )
)
