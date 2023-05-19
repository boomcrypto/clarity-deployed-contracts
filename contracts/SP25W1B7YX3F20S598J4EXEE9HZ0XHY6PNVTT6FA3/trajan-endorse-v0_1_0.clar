;; Trajan endorsement Alpha
;; Contract that controls all Trajan endorsements
;; Written by Setzeus/StrataLabs and hz

;; endorsement
;; An endorsement is an NFT that marks a endorsement event & endorsement worth celebrating
;; endorsements are sent from one profile (user) to another (user) & have a life-cycle of 3 stages:
;; 1. Draft - The endorsement is drafted by the sender & submitted to the recipient (offchain)
;; 2. Pending - The endorsement is pending approval by the recipient or edited & sent back to the sender (offchain)
;; 3. Approved - The endorsement is approved by the recipient then minted & can be displayed on the recipient's profile

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant SIP-018-PREFIX 0x534950303138)
(define-constant APP-NAME "Trajan")
(define-constant APP-VERSION "0.1.0")

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;; (impl-trait 'ST1NXBK3K5YYMD6FD41MVNP3JS1GABZ8TRVX023PT.nft-trait.nft-trait)

(define-constant ADDRESS-VERSION (if (is-eq chain-id u1) 0x16 0x1a))

(define-constant APP-META-HASH 
    (sha256 
        (unwrap-panic
            (to-consensus-buff? {name: APP-NAME, version: APP-VERSION, chain-id: chain-id}))))

;; Define endorsement NFT
(define-non-fungible-token endorsement uint)
(define-data-var largest-nft-id uint u0)

;; Define endorsement Submission Map
(define-map endorsement-submission uint {
    sender: principal,
    recipient: principal,
    metadata-uri: (string-ascii 256),
    nonce: uint,
})


;;;;;;;;;;;;;;;;;;;;
;;;; Read Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;

;; Get endorsement
(define-read-only (get-endorsement (id uint))
    (map-get? endorsement-submission id)
)


;;;;;;;;;;;;;;;;;;;;;
;;;; SIP09 Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;
;; NOT SIP-009 compatible
;; Get token URL
;; Should we force IPFS file? How should we check for it?
(define-read-only (get-token-uri (id uint)) 
    (let 
        (
            (metadata (unwrap! (map-get? endorsement-submission id) (err u0)))
        )
        (ok (some (get metadata-uri metadata)))
    )
)

(define-read-only (get-last-token-id) 
    (ok (var-get largest-nft-id)))

;; Get token owner
(define-read-only (get-owner (id uint)) 
    (ok (nft-get-owner? endorsement id))
)

;; Transfer
;; Will *not* be allowed to transfer
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    ;; no transfers possible ma man
    (err u0)
)



;;;;;;;;;;;;;;;;;;;;;
;;;; Write Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Submit endorsement
;; @desc - Submits a endorsement draft from one profile to another
(define-public 
    (submit-endorsement 
        (sender principal) 
        (recipient principal) 
        (metadata-uri (string-ascii 256))
        (nonce uint)
        (recipient-signature (buff 65)))
    (begin

        ;; Assert that profile & bns-info are still intact
        (asserts! 
            (is-ok (check-blocked sender))
            (err "err-sender-profile-integrity"))
        (asserts! 
            (is-ok (check-blocked recipient))
            (err "err-sender-profile-integrity"))

        ;; Assert that tx-sender is sender
        (asserts! (is-eq tx-sender sender) (err "err-tx-sender-not-sender"))

        ;; Assert that tx-sender != recipient
        (asserts! 
            (not (is-eq tx-sender recipient)) 
            (err "err-tx-sender-recipient"))

        ;; Mint a new endorsement NFT
        (asserts! 
            (> (len metadata-uri) u0) 
            (err "err-metadata-uri-empty"))

        ;; assert nonce is not used
        (asserts! 
            (is-none (map-get? endorsement-submission nonce))   
            (err "err-nonce-used"))

        (let (
            (endorsement-hash 
                (build-endorsement-hash sender recipient metadata-uri nonce))
            (signer-pubkey 
                (unwrap! 
                    (secp256k1-recover? endorsement-hash recipient-signature) 
                    (err "err-signature-invalid")))
            (signer-principal 
                (unwrap! 
                    (principal-construct? ADDRESS-VERSION 
                        (hash160 signer-pubkey)) 
                    (err "err-signature-invalid")))
        )

        (asserts! 
            (is-eq signer-principal recipient) 
            (err "err-signature-invalid"))
        ;; Check if organization is-some

        (unwrap! 
            (nft-mint? endorsement nonce recipient) 
            (err "err-mint-failed"))
        
        ;; Update largest-nft-id
        (if 
            (< (var-get largest-nft-id) nonce)
            (var-set largest-nft-id nonce)
            true)

        ;; Map set the endorsement submission
        (map-insert endorsement-submission nonce {
            sender: sender,
            recipient: recipient,
            metadata-uri: metadata-uri,
            nonce: nonce,
        })
        (ok true)
    ))
)

(define-public 
    (first-time-endorsement
        (sender principal)
        (recipient principal) 
        (metadata-uri (string-ascii 256))
        (nonce uint)
        (recipient-signature (buff 65)))
    (begin
        (try! (contract-call? .trajan-protocol-v0 first-endorsement-lock sender recipient ))
        (try! (submit-endorsement sender recipient metadata-uri nonce recipient-signature))
        (ok true)))

;;;;;;;;;;;;;;;;;;;;;
;;;; Owner Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;

;; Burn|Reject endorsement
;; @desc - Function that allows profile-recipient to burn an endorsement
;; [allow(id)]
(define-public (burn-endorsement (id uint))
    (let
        ((recipient (unwrap!
            (get recipient (map-get? endorsement-submission id)) 
            (err "err-no-endorsement"))))

        ;; Assert that profile & bns-info are still intact
        (asserts! (is-ok (check-blocked tx-sender)) (err "err-sender-profile-integrity"))
        (asserts!
            (and
                (is-eq recipient tx-sender)
                (is-eq (unwrap! (nft-get-owner? endorsement id) (err "err-endorsement-not-found")) tx-sender))
        (err "err-sender-not-recipient"))

        ;; Burn the endorsement NFT
        (unwrap! (nft-burn? endorsement id recipient) (err "err-burn-failed"))
        (ok true)
    )
)


(define-private (check-blocked (profile principal)) 
    (contract-call? .trajan-protocol-v0 check-and-block-changed-name profile))


(define-read-only (build-endorsement-hash
    (sender principal)
    (recipient principal)
    (metadata-uri (string-ascii 256))
    (nonce uint))
    (let (
        (endorsement-meta
            (sha256
                (unwrap-panic
                    (to-consensus-buff?
                        {sender: sender, recipient: recipient, metadata-uri: metadata-uri, nonce: nonce}))))
        (meta-bytes
            (concat APP-META-HASH endorsement-meta)))
    (sha256 (concat SIP-018-PREFIX meta-bytes))
))
