;; Trajan endorsement Alpha
;; Contract that controls all Trajan endorsements
;; Written by Setzeus/StrataLabs

;; endorsement
;; An endorsement is an NFT that marks a endorsement event & endorsement worth celebrating
;; endorsements are sent from one profile (user) to another (user) & have a life-cycle of 3 stages:
;; 1. Draft - The endorsement is drafted by the sender & submitted to the receiver
;; 2. Pending - The endorsement is pending approval by the receiver or edited & sent back to the sender
;; 3. Approved - The endorsement is approved by the receiver & can be displayed on the receiver's profile

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define endorsement NFT
(define-non-fungible-token endorsement uint)

;; Define endorsement Index
(define-data-var endorsement-index uint u1)

;; Define Helper Bool
(define-data-var helper-bool bool false)

;; Definer Helper Draft
(define-data-var helper-draft {date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), endorsementURI: (string-ascii 128)} {date-sent: u0, date-event: u0, title: "", endorsement: "", endorsementURI: ""})

;; Define endorsement Metadata Map
;; Change title to endorsement
(define-map endorsement-metadata uint { 
    sender-profile: principal,
    receiver-profile: principal,
    sender-approval: bool,
    receiver-approval: bool,
    title: (string-ascii 256),
    date: uint,
    endorsement: (string-ascii 2048),
    endorsementURI: (string-ascii 128),
    display: bool,
    approved: bool,
    organization: (optional (string-ascii 128)),
})


;; Define endorsement Submission Map
(define-map endorsement-submission uint {
    sender-profile: principal,
    receiver-profile: principal,
    drafts: (list 25 {date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), endorsementURI: (string-ascii 128)})
})

;; Define profile Owner List
(define-map profile-endorsements principal (list 2500 uint))



;;;;;;;;;;;;;;;;;;;;
;;;; Read Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;

;; Get endorsement
(define-read-only (get-endorsement (id uint))
    (map-get? endorsement-metadata id)
)

;; Get Latest Submission
(define-read-only (get-latest-submission (id uint))
    (let
        (
            (submission (unwrap! (map-get? endorsement-submission id) (err "err-no-endorsement")))
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
    (ok (var-get endorsement-index))
)

;; Get token URL
;; Should we force IPFS file? How should we check for it?
(define-public (get-token-uri (id uint)) 
    (let 
        (
            (metadata (unwrap! (map-get? endorsement-metadata id) (err u0)))
        )
        (ok (get endorsementURI metadata))
    )
)

;; Get token owner
(define-public (get-owner (id uint)) 
    (ok (nft-get-owner? endorsement id))
)

;; Transfer
;; Will *not* be allowed to transfer
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (ok true)
)


;;;;;;;;;;;;;;;;;;;;;
;;;; Write Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Submit endorsement
;; @desc - Submits a endorsement draft from one profile to another
;; @param - profile:principal - The profile recipient of the endorsement, title: (string-ascii 256) - The title of the endorsement, date: uint - The block-height date of the endorsement, endorsement: (string-ascii 2048) - The endorsement of the endorsement, endorsementURI: (string-ascii 128) - The proof URI of the endorsement
(define-public (submit-endorsement (sender principal) (receiver principal) (title (string-ascii 256)) (date (optional uint)) (description (string-ascii 2048)) (endorsementURI (string-ascii 128)) (organization (optional (string-ascii 128))))
    (let
        (
            (current-index (var-get endorsement-index))
            (next-index (+ current-index u1))
            (sender-profile (unwrap! (contract-call? .trajan-protocol-alpha get-profile tx-sender) (err "err-sender-not-profile")))
            (receiver-profile (unwrap! (contract-call? .trajan-protocol-alpha get-profile receiver) (err "err-receiver-not-profile")))
            (checked-date (default-to block-height date))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert that tx-sender is sender
        (asserts! (is-eq tx-sender sender) (err "err-tx-sender-not-sender"))

        ;; Assert that tx-sender != receiver
        (asserts! (not (is-eq tx-sender receiver)) (err "err-tx-sender-receiver"))

        ;; Assert that endorsementURI is a valid IPFS file (?)
        (asserts! (and (is-eq (some "i") (element-at endorsementURI u0)) (is-eq (some "p") (element-at endorsementURI u1)) (is-eq (some "f") (element-at endorsementURI u2)) (is-eq (some "s") (element-at endorsementURI u3))) (err "err-invalid-endorsementURI"))

        ;; If date is provided, assert that it is not in the future
        (asserts! (< checked-date (+ block-height u1)) (err "err-date-in-future"))

        ;; Mint a new endorsement NFT
        (unwrap! (nft-mint? endorsement current-index receiver) (err "err-mint-failed"))

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
                
                ;; Map set the endorsement metadata
                (map-set endorsement-metadata current-index {
                    sender-profile: sender,
                    receiver-profile: receiver,
                    sender-approval: true,
                    receiver-approval: false,
                    date: checked-date,
                    title: title,
                    endorsement: description,
                    endorsementURI: endorsementURI,
                    display: true,
                    approved: false,
                    organization: (some org)
                })

            )

            ;; Not an org, Map set the endorsement metadata w/ no org
            (map-set endorsement-metadata current-index {
                sender-profile: sender,
                receiver-profile: receiver,
                sender-approval: true,
                receiver-approval: false,
                date: checked-date,
                title: title,
                endorsement: description,
                endorsementURI: endorsementURI,
                display: true,
                approved: false,
                organization: none
            })
        
        )

        ;; Map set the endorsement submission
        (map-set endorsement-submission current-index {
            sender-profile: sender,
            receiver-profile: receiver,
            drafts: (list {
                date-sent: block-height,
                date-event: checked-date,
                title: title,
                endorsement: description,
                endorsementURI: endorsementURI,
            } )
        })

        ;; Var set the endorsement index
        (ok (var-set endorsement-index next-index))

    )
)

;; Edit endorsement
;; @desc - Submits a endorsement draft for a single endorsement (by either sender or receiver)
;; @param - id:uint - The id of the endorsement, title: (string-ascii 256) - The title of the endorsement, date: uint - The block-height date of the endorsement, endorsement: (string-ascii 2048) - The endorsement of the endorsement, endorsementURI: (string-ascii 128) - The proof URI of the endorsement
(define-public (edit-endorsement (id uint) (title (string-ascii 256)) (date uint) (description (string-ascii 2048)) (endorsementURI (string-ascii 128)))
    (let
        (
            (metadata (unwrap! (map-get? endorsement-metadata id) (err "err-no-endorsement")))
            (metadata-approval (get approved metadata))
            (submission (unwrap! (map-get? endorsement-submission id) (err "err-no-endorsement-submission")))
            (submission-sender (get sender-profile submission))
            (submission-receiver (get receiver-profile submission))
            (submission-drafts (get drafts submission))
            (submission-drafts-len (len submission-drafts))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert that tx-sender is either the sender or receiver of the endorsement
        (asserts! (or (is-eq tx-sender submission-sender) (is-eq tx-sender submission-receiver)) (err "err-tx-sender-not-sender-receiver"))

        ;; Assert that len of drafts is less than 25
        (asserts! (< submission-drafts-len u25) (err "err-drafts-limit-reached"))

        ;; Assert that endorsement is not already approved
        (asserts! (not metadata-approval) (err "err-endorsement-already-approved"))

        ;; Assert that endorsementURI is a valid IPFS file(?)
        (asserts! (and (is-eq (some "i") (element-at endorsementURI u0)) (is-eq (some "p") (element-at endorsementURI u1)) (is-eq (some "f") (element-at endorsementURI u2)) (is-eq (some "s") (element-at endorsementURI u3))) (err "err-invalid-endorsementURI"))

        ;; Assert that date is not in the future (but do we need to check it's after Stacks launched?)
        (asserts! (< date (+ block-height u1)) (err "err-date-in-future"))

        ;; Check if tx-sender is sender or receiver
        (ok (if (is-eq tx-sender submission-sender)

            ;; Tx-sender is Sender -> Update both endorsement-metadata & endorsement-submission maps accordingly
            (begin 

                ;; Map-set endorsement metadata by reseting approvals
                (map-set endorsement-metadata id (merge 
                    metadata
                    {sender-approval: true, receiver-approval: false}
                ))

                ;; Map-set endorsement submission by appending the draft to the drafts list as-max-len? 25
                (map-set endorsement-submission id {
                    sender-profile: submission-sender,
                    receiver-profile: submission-receiver,
                    drafts: (unwrap! (as-max-len? (append submission-drafts {
                        profile-sender: true,
                        profile-receiver: false,
                        date-sent: block-height,
                        date-event: date,
                        title: title,
                        endorsement: description,
                        endorsementURI: endorsementURI,
                    }) u25) (err "err-drafts-limit-reached"))
                })

            )

            ;; Tx-sender is Receiver -> Update both endorsement-metadata & endorsement-submission maps accordingly
            (begin 

                ;; Map-set endorsement metadata by reseting approvals
                (map-set endorsement-metadata id (merge 
                    metadata
                    {sender-approval: false, receiver-approval: true}
                ))

                ;; Map-set by appending the draft to the drafts list as-max-len? 25
                (map-set endorsement-submission id {
                    sender-profile: submission-sender,
                    receiver-profile: submission-receiver,
                    drafts: (unwrap! (as-max-len? (append submission-drafts {
                        profile-sender: false,
                        profile-receiver: true,
                        date-sent: block-height,
                        date-event: date,
                        title: title,
                        endorsement: description,
                        endorsementURI: endorsementURI,
                    }) u25) (err "err-drafts-limit-reached"))
                })

            )

            
        ))
    )
)



;;;;;;;;;;;;;;;;;;;;;
;;;; Owner Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Approve endorsement
;; @desc - A multi-sig approval of a endorsement draft to go live
;; @param - id:uint - The id of the endorsement
(define-public (approve-endorsement (id uint))
    (let
        (
            (metadata (unwrap! (map-get? endorsement-metadata id) (err "err-no-endorsement")))
            (metadata-sender-approval (get sender-approval metadata))
            (metadata-receiver-approval (get receiver-approval metadata))
            (endorsement-status (get approved metadata))
            (submission (unwrap! (map-get? endorsement-submission id) (err "err-no-endorsement")))
            (submission-sender (get sender-profile submission))
            (submission-receiver (get receiver-profile submission))
            (submission-drafts (get drafts submission))
            (submission-drafts-len (len submission-drafts))
            (latest-draft (unwrap! (element-at submission-drafts (- submission-drafts-len u1)) (err "err-no-drafts")))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert that endorsement is not already approved
        (asserts! (not endorsement-status) (err "err-endorsement-already-approved"))

        ;; Assert that tx-sender is either the sender or receiver of the endorsement
        (asserts! (or (is-eq tx-sender submission-sender) (is-eq tx-sender submission-receiver)) (err "err-tx-sender-not-sender-receiver"))

        ;; Var-set latest-draft-submitted-helper
        (var-set helper-draft latest-draft)

        ;; Check if tx-sender is sender or receiver
        (ok (if (is-eq tx-sender submission-sender)

            ;; If sender, check if already approved
            (if metadata-sender-approval
                ;; Already approved, do nothing
                true
                ;; Not approved, update endorsement-metadata accordingly
                (map-set endorsement-metadata id (merge 
                    metadata
                    {sender-approval: true, approved: true}
                ))
            )

            ;; If receiver, check if already approved
            (if metadata-receiver-approval
                ;; Already approved, do nothing
                true
                ;; Not approved, update endorsement-metadata accordingly
                (map-set endorsement-metadata id (merge 
                    metadata
                    {receiver-approval: true, approved: true}
                ))
            )
        ))
    )
)

;; Burn|Reject endorsement
;; @desc - Function that allows profile-receiver to reject & burn a endorsement
;; @param - id:uint - The id of the endorsement
(define-public (burn-endorsement (id uint))
    (let
        (
            (current-endorsement (unwrap! (map-get? endorsement-metadata id) (err "err-no-endorsement")))
            (current-endorsement-receiver (get receiver-profile current-endorsement))
            (current-endorsement-nft-owner (unwrap! (nft-get-owner? endorsement id) (err "err-no-owner")))
            (current-trajan-watchers (contract-call? .trajan-protocol-alpha get-trajan-watchers))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert tx-sender is either both the endorsement receiver and the current owner of the endorsement OR a Trajan watcher
        (asserts! (or (is-some (index-of current-trajan-watchers tx-sender)) (and (is-eq tx-sender current-endorsement-receiver) (is-eq tx-sender current-endorsement-nft-owner))) (err "err-sender-not-receiver"))

        ;; Burn the endorsement NFT
        (unwrap! (nft-burn? endorsement id current-endorsement-nft-owner) (err "err-burn-failed"))

        ;; Map-delete the endorsement metadata
        (map-delete endorsement-metadata id)

        ;; Map-delete the endorsement submission
        (ok (map-delete endorsement-submission id))

    )
)

;; Display/Hide Individual endorsement
;; @desc - Function that flips the display boolean of a endorsement
;; @param - id:uint - The id of the endorsement, display:bool - The display boolean of the endorsement
(define-public (display-status (status bool) (id uint)) 
    (let
        (
            (current-endorsement (unwrap! (map-get? endorsement-metadata id) (err "err-no-endorsement")))
            (current-endorsement-receiver (get receiver-profile current-endorsement))
            (current-endorsement-display (get display current-endorsement))
            (current-endorsement-nft-owner (unwrap! (nft-get-owner? endorsement id) (err "err-no-owner")))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert tx-sender is both the endorsement receiver and the current owner of the endorsement
        (asserts! (and (is-eq tx-sender current-endorsement-receiver) (is-eq tx-sender current-endorsement-nft-owner)) (err "err-sender-not-receiver"))

        ;; Map-set the endorsement metadata by merging current-endorsement with a tuple of display:status
        (ok (map-set endorsement-metadata id 
            (merge 
                current-endorsement 
                {display: status}
            )
        ))

    )
)

;; Display/Hide All endorsements
;; @desc - Function that flips the display boolean of all endorsements for a given profile-receiver
;; @param - receiver:principal - The profile-receiver of the endorsements, display:bool - The display boolean of the endorsements
(define-public (display-status-all (status bool))
    (let
        (
            (current-profile (unwrap! (contract-call? .trajan-protocol-alpha get-profile tx-sender) (err "err-no-profile")))
            (current-profile-endorsements (get profile-endorsements current-profile))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Assert that current-profile-endorsements has a len => u1
        (asserts! (> (len current-profile-endorsements) u1) (err "err-no-endorsements"))

        ;; Call change-status map to change display status of all endorsements
        (ok (map change-status current-profile-endorsements))

    )
)

;; Helper display status all function
(define-private (change-status (endorsement-id uint))

    (let 
        (
            (current-endorsement (unwrap! (map-get? endorsement-metadata endorsement-id) (err "err-no-endorsement")))
            (current-endorsement-receiver (get receiver-profile current-endorsement))
            (current-endorsement-display (get display current-endorsement))
            (current-endorsement-nft-owner (unwrap! (nft-get-owner? endorsement endorsement-id) (err "err-no-owner")))
        )

        ;; Assert that profile & bns-info are still intact
        (asserts! (unwrap! (contract-call? .trajan-protocol-alpha protocol-check-for-corrupted-profile) (err "err-sender-profile-integrity")) (err "err-sender-profile-integrity"))

        ;; Map-set the endorsement metadata by merging current-endorsement with a tuple of display:status
        (ok (map-set endorsement-metadata endorsement-id
            (merge 
                current-endorsement
                {display: (var-get helper-bool)}
            )
        ))

    )

)

;; Helper function to remove the latest draft from the submission drafts list
(define-private (remove-latest-draft (draft {profile-sender: bool, profile-receiver: bool, date-sent: uint, date-event: uint, title: (string-ascii 256), endorsement: (string-ascii 2048), endorsementURI: (string-ascii 128)})) 
    (not (is-eq draft (var-get helper-draft)))
)