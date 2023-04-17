;; Trajan Achievement Alpha
;; Contract that controls all Trajan achievements
;; Written by Setzeus/StrataLabs

;; Achievement
;; An achievement is an NFT that marks a achievement event & endorsement worth celebrating
;; Achievements are sent from one column (user) to another (user) & have a life-cycle of 3 stages:
;; 1. Draft - The achievement is drafted by the sender & submitted to the receiver
;; 2. Pending - The achievement is pending approval by the receiver or edited & sent back to the sender
;; 3. Approved - The achievement is approved by the receiver & can be displayed on the receiver's profile

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define achievement NFT
(define-non-fungible-token achievement uint)

;; Define achievement Index
(define-data-var achievement-index uint u1)

;; Define Helper Bool
(define-data-var helper-bool bool false)

;; Definer Helper Draft
(define-data-var helper-draft {column-sender: bool, column-receiver: bool, date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), achievementURI: (string-ascii 128)} {column-sender: false, column-receiver: false, date-sent: u0, date-event: u0, title: "", endorsement: "", achievementURI: ""})

;; Define achievement Metadata Map
;; Change title to achievement
(define-map achievement-metadata uint { 
    column-sender: principal,
    column-receiver: principal,
    title: (string-ascii 256),
    date: uint,
    endorsement: (string-ascii 2048),
    achievementURI: (string-ascii 128),
    display: bool,
    approved: bool,
    organization: (optional (string-ascii 128)),
})


;; Define achievement Submission Map
(define-map achievement-submission uint {
    column-sender: principal,
    column-receiver: principal,
    status: bool,
    drafts: (list 25 {column-sender: bool, column-receiver: bool, date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), achievementURI: (string-ascii 128)})
})

;; Define Column Owner List
(define-map column-achievements principal (list 2500 uint))



;;;;;;;;;;;;;;;;;;;;
;;;; Read Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;

;; Get achievement
(define-read-only (get-achievement (id uint))
    (map-get? achievement-metadata id)
)

;; Get Latest Submission
(define-read-only (get-latest-submission (id uint))
    (let
        (
            (submission (unwrap! (map-get? achievement-submission id) (err "err-no-achievement")))
            (submission-drafts (get drafts submission))
            (latest-draft (unwrap! (element-at submission-drafts (- (len submission-drafts) u1)) (err "err-no-drafts")))
        )
        (ok latest-draft)
    )
)



;;;;;;;;;;;;;;;;;;;;;
;;;; SIP09 Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;


;; Get last token id
(define-public (get-last-token-id) 
    (ok (var-get achievement-index))
)

;; Get token URL
;; Should we force IPFS file? How should we check for it?
(define-public (get-token-uri (id uint)) 
    (let 
        (
            (metadata (unwrap! (map-get? achievement-metadata id) (err u0)))
        )
        (ok (get achievementURI metadata))
    )
)

;; Get token owner
(define-public (get-owner (id uint)) 
    (ok (nft-get-owner? achievement id))
)

;; Transfer
;; Will *not* be allowed to transfer
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (ok true)
)


;;;;;;;;;;;;;;;;;;;;;
;;;; Write Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Submit achievement
;; @desc - Submits a achievement draft from one column to another
;; @param - column:principal - The column recipient of the achievement, title: (string-ascii 256) - The title of the achievement, date: uint - The block-height date of the achievement, endorsement: (string-ascii 2048) - The endorsement of the achievement, achievementURI: (string-ascii 128) - The proof URI of the achievement
(define-public (submit-achievement (sender principal) (receiver principal) (title (string-ascii 256)) (date (optional uint)) (endorsement (string-ascii 2048)) (achievementURI (string-ascii 128)) (organization (optional (string-ascii 128))))
    (let
        (
            (current-index (var-get achievement-index))
            (next-index (+ current-index u1))
            (sender-column (unwrap! (contract-call? .trajan-protocol-alpha get-column tx-sender) (err "err-sender-not-column")))
            (receiver-column (unwrap! (contract-call? .trajan-protocol-alpha get-column receiver) (err "err-receiver-not-column")))
            (checked-date (default-to block-height date))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert that tx-sender is sender
        (asserts! (is-eq tx-sender sender) (err "err-tx-sender-not-sender"))

        ;; Assert that tx-sender != receiver
        (asserts! (not (is-eq tx-sender receiver)) (err "err-tx-sender-receiver"))

        ;; Assert that achievementURI is a valid IPFS file (?)
        (asserts! (and (is-eq (some "i") (element-at achievementURI u0)) (is-eq (some "p") (element-at achievementURI u1)) (is-eq (some "f") (element-at achievementURI u2)) (is-eq (some "s") (element-at achievementURI u3))) (err "err-invalid-achievementURI"))

        ;; If date is provided, assert that it is not in the future
        (asserts! (< checked-date (+ block-height u1)) (err "err-date-in-future"))

        ;; Mint a new achievement NFT
        (unwrap! (nft-mint? achievement current-index receiver) (err "err-mint-failed"))

        ;; Check if organization is-some
        (if (is-some organization)

            ;; Need to check org info 
            (let 
                (
                    (org (default-to "" organization))
                    (org-info (unwrap! (contract-call? .trajan-protocol-alpha get-organization-representatives org) (err "err-org-not-found")))
                )

                ;; Assert that sender is a representative of the org
                (asserts! (is-some (index-of org-info tx-sender)) (err "err-sender-not-representative"))
                
                ;; Map set the achievement metadata
                (map-set achievement-metadata current-index {
                    column-sender: sender,
                    column-receiver: receiver,
                    date: checked-date,
                    title: title,
                    endorsement: endorsement,
                    achievementURI: achievementURI,
                    display: true,
                    approved: false,
                    organization: (some org)
                })

            )

            ;; Not an org, Map set the achievement metadata w/ no org
            (map-set achievement-metadata current-index {
                column-sender: sender,
                column-receiver: receiver,
                date: checked-date,
                title: title,
                endorsement: endorsement,
                achievementURI: achievementURI,
                display: true,
                approved: false,
                organization: none
            })
        
        )

        ;; Map set the achievement submission
        (map-set achievement-submission current-index {
            column-sender: sender,
            column-receiver: receiver,
            status: false,
            drafts: (list {
                column-sender: true,
                column-receiver: false,
                date-sent: block-height,
                date-event: checked-date,
                title: title,
                endorsement: endorsement,
                achievementURI: achievementURI,
            } )
        })

        ;; Var set the achievement index
        (ok (var-set achievement-index next-index))

    )
)

;; Edit achievement
;; @desc - Submits a achievement draft for a single achievement (by either sender or receiver)
;; @param - id:uint - The id of the achievement, title: (string-ascii 256) - The title of the achievement, date: uint - The block-height date of the achievement, endorsement: (string-ascii 2048) - The endorsement of the achievement, achievementURI: (string-ascii 128) - The proof URI of the achievement
(define-public (edit-achievement (id uint) (title (string-ascii 256)) (date uint) (endorsement (string-ascii 2048)) (achievementURI (string-ascii 128)))
    (let
        (
            (metadata (unwrap! (map-get? achievement-metadata id) (err "err-no-achievement")))
            (metadata-approval (get approved metadata))
            (submission (unwrap! (map-get? achievement-submission id) (err "err-no-achievement")))
            (submission-sender (get column-sender submission))
            (submission-receiver (get column-receiver submission))
            (submission-drafts (get drafts submission))
            (submission-drafts-len (len submission-drafts))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert that tx-sender is either the sender or receiver of the achievement
        (asserts! (or (is-eq tx-sender submission-sender) (is-eq tx-sender submission-receiver)) (err "err-tx-sender-not-sender-receiver"))

        ;; Assert that len of drafts is less than 25
        (asserts! (< submission-drafts-len u25) (err "err-drafts-limit-reached"))

        ;; Assert that achievement is not already approved
        (asserts! (not metadata-approval) (err "err-achievement-already-approved"))

        ;; Assert that achievementURI is a valid IPFS file(?)
        (asserts! (and (is-eq (some "i") (element-at achievementURI u0)) (is-eq (some "p") (element-at achievementURI u1)) (is-eq (some "f") (element-at achievementURI u2)) (is-eq (some "s") (element-at achievementURI u3))) (err "err-invalid-achievementURI"))

        ;; Assert that date is not in the future (but do we need to check it's after Stacks launched?)
        (asserts! (< date (+ block-height u1)) (err "err-date-in-future"))

        ;; Check if tx-sender is sender or receiver
        (ok (if (is-eq tx-sender submission-sender)

            ;; Map-set by appending the draft to the drafts list as-max-len? 25
            (map-set achievement-submission id {
                column-sender: submission-sender,
                column-receiver: submission-receiver,
                status: false,
                drafts: (unwrap! (as-max-len? (append submission-drafts {
                    column-sender: true,
                    column-receiver: false,
                    date-sent: block-height,
                    date-event: date,
                    title: title,
                    endorsement: endorsement,
                    achievementURI: achievementURI,
                }) u25) (err "err-drafts-limit-reached"))
            })

            ;; Map-set by appending the draft to the drafts list as-max-len? 25
            (map-set achievement-submission id {
                column-sender: submission-sender,
                column-receiver: submission-receiver,
                status: false,
                drafts: (unwrap! (as-max-len? (append submission-drafts {
                    column-sender: false,
                    column-receiver: true,
                    date-sent: block-height,
                    date-event: date,
                    title: title,
                    endorsement: endorsement,
                    achievementURI: achievementURI,
                }) u25) (err "err-drafts-limit-reached"))
            })
        ))
    )
)



;;;;;;;;;;;;;;;;;;;;;
;;;; Owner Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Approve achievement
;; @desc - A multi-sig approval of a achievement draft to go live
;; @param - id:uint - The id of the achievement
(define-public (approve-achievement (id uint))
    (let
        (
            (metadata (unwrap! (map-get? achievement-metadata id) (err "err-no-achievement")))
            (achievement-status (get approved metadata))
            (submission (unwrap! (map-get? achievement-submission id) (err "err-no-achievement")))
            (submission-sender (get column-sender submission))
            (submission-receiver (get column-receiver submission))
            (submission-drafts (get drafts submission))
            (submission-drafts-len (len submission-drafts))
            (latest-draft (unwrap! (element-at submission-drafts (- submission-drafts-len u1)) (err "err-no-drafts")))
            (latest-draft-sender (get column-sender latest-draft))
            (latest-draft-receiver (get column-receiver latest-draft))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert that achievement is not already approved
        (asserts! (not achievement-status) (err "err-achievement-already-approved"))

        ;; Assert that tx-sender is either the sender or receiver of the achievement
        (asserts! (or (is-eq tx-sender submission-sender) (is-eq tx-sender submission-receiver)) (err "err-tx-sender-not-sender-receiver"))

        ;; Var-set latest-draft-submitted-helper
        (var-set helper-draft latest-draft)

        ;; Check if tx-sender is sender or receiver
        (if (is-eq tx-sender submission-sender)

            ;; If sender, check if already approved
            (if latest-draft-sender
                ;; Already approved, do nothing
                true
                ;; Remove the latest draft from the drafts list & re-append it by first merging latest-draft with an updated tuple field of {latest-draft-sender: true}
                (begin
                    ;; Remove latest draft from drafts list
                    (filter remove-latest-draft submission-drafts)
                    ;; Map-set the achievement submission
                    (map-set achievement-submission id 
                        (merge 
                            submission
                            {drafts: (unwrap! (as-max-len? 
                                (append submission-drafts 
                                    (merge latest-draft {column-sender: true})
                                ) u25) 
                            (err "err-drafts-limit-reached"))}
                        )
                    )
                )
            )

            ;; If receiver, check if already approved
            (if latest-draft-receiver
                ;; Already approved, do nothing
                true
                ;; Remove the latest draft from the drafts list & re-append it by first merging latest-draft with an updated tuple field of {latest-draft-receiver: true}
                (begin
                    ;; Remove latest draft from drafts list
                    (filter remove-latest-draft submission-drafts)
                    ;; Map-set the achievement submission
                    (map-set achievement-submission id 
                        (merge 
                            submission
                            {drafts: (unwrap! (as-max-len? 
                                (append submission-drafts 
                                    (merge latest-draft {column-receiver: true})
                                ) u25) 
                            (err "err-drafts-limit-reached"))}
                        )
                    )
                )
            )
        )

        ;; Refetch the latest draft (now updated from map-set above) & check if both sender & receiver have approved
        (let
            (
                (updated-submission (unwrap! (map-get? achievement-submission id) (err "err-no-achievement")))
                (updated-submission-drafts (get drafts submission))
                (updated-submission-drafts-len (len submission-drafts))
                (updated-latest-draft (unwrap! (element-at submission-drafts (- submission-drafts-len u1)) (err "err-no-drafts")))
                (updated-latest-draft-sender (get column-sender latest-draft))
                (updated-latest-draft-receiver (get column-receiver latest-draft))
            )

            ;; If both sender & receiver have approved, map-set the achievement metadata
            (ok (if (and latest-draft-sender latest-draft-receiver)
                (map-set achievement-metadata id 
                    (merge metadata {approved: true})
                )
                false
            ))
        )
    )
)

;; Burn|Reject achievement
;; @desc - Function that allows column-receiver to reject & burn a achievement
;; @param - id:uint - The id of the achievement
(define-public (burn-achievement (id uint))
    (let
        (
            (current-achievement (unwrap! (map-get? achievement-metadata id) (err "err-no-achievement")))
            (current-achievement-receiver (get column-receiver current-achievement))
            (current-achievement-nft-owner (unwrap! (nft-get-owner? achievement id) (err "err-no-owner")))
            (current-trajan-watchers (contract-call? .trajan-protocol-alpha get-trajan-watchers))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert tx-sender is either both the achievement receiver and the current owner of the achievement OR a Trajan watcher
        (asserts! (or (is-some (index-of current-trajan-watchers tx-sender)) (and (is-eq tx-sender current-achievement-receiver) (is-eq tx-sender current-achievement-nft-owner))) (err "err-sender-not-receiver"))

        ;; Burn the achievement NFT
        (unwrap! (nft-burn? achievement id current-achievement-nft-owner) (err "err-burn-failed"))

        ;; Map-delete the achievement metadata
        (map-delete achievement-metadata id)

        ;; Map-delete the achievement submission
        (map-delete achievement-submission id)

        ;; Filter remove achievement from column achievements

        (ok true)
    )
)

;; Display/Hide Individual achievement
;; @desc - Function that flips the display boolean of a achievement
;; @param - id:uint - The id of the achievement, display:bool - The display boolean of the achievement
(define-public (display-status (status bool) (id uint)) 
    (let
        (
            (current-achievement (unwrap! (map-get? achievement-metadata id) (err "err-no-achievement")))
            (current-achievement-receiver (get column-receiver current-achievement))
            (current-achievement-display (get display current-achievement))
            (current-achievement-nft-owner (unwrap! (nft-get-owner? achievement id) (err "err-no-owner")))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert tx-sender is both the achievement receiver and the current owner of the achievement
        (asserts! (and (is-eq tx-sender current-achievement-receiver) (is-eq tx-sender current-achievement-nft-owner)) (err "err-sender-not-receiver"))

        ;; Map-set the achievement metadata by merging current-achievement with a tuple of display:status
        (ok (map-set achievement-metadata id 
            (merge 
                current-achievement 
                {display: status}
            )
        ))

    )
)

;; Display/Hide All achievements
;; @desc - Function that flips the display boolean of all achievements for a given column-receiver
;; @param - receiver:principal - The column-receiver of the achievements, display:bool - The display boolean of the achievements
(define-public (display-status-all (status bool))
    (let
        (
            (current-column (unwrap! (contract-call? .trajan-protocol-alpha get-column tx-sender) (err "err-no-column")))
            (current-column-achievements (get column-achievements current-column))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Assert that current-column-achievements has a len => u1
        (asserts! (> (len current-column-achievements) u1) (err "err-no-achievements"))

        ;; Call change-status map to change display status of all achievements
        (ok (map change-status current-column-achievements))

    )
)

;; Helper display status all function
(define-private (change-status (achievement-id uint))

    (let 
        (
            (current-achievement (unwrap! (map-get? achievement-metadata achievement-id) (err "err-no-achievement")))
            (current-achievement-receiver (get column-receiver current-achievement))
            (current-achievement-display (get display current-achievement))
            (current-achievement-nft-owner (unwrap! (nft-get-owner? achievement achievement-id) (err "err-no-owner")))
        )

        ;; Assert that column & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-column) (err "err-sender-column-integrity")) (err "err-sender-column-integrity"))

        ;; Map-set the achievement metadata by merging current-achievement with a tuple of display:status
        (ok (map-set achievement-metadata achievement-id
            (merge 
                current-achievement
                {display: (var-get helper-bool)}
            )
        ))

    )

)

;; Helper function to remove the latest draft from the submission drafts list
(define-private (remove-latest-draft (draft {column-sender: bool, column-receiver: bool, date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), achievementURI: (string-ascii 128)})) 
    (not (is-eq draft (var-get helper-draft)))
)