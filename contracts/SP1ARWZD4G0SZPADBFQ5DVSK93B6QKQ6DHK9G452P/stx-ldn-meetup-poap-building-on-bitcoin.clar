(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)


(define-non-fungible-token stx-ldn-meetup-poap-building-on-bitcoin uint)

;; Define constants 
(define-constant ERR-NO-MORE-NFTS u25)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)


(define-constant ERR-LISTING u106)
(define-constant ERR-ONE-PER-WALLET u1)

(define-map prompt-data principal { token-id: uint, url: (string-ascii 456) })

;; Define Variables
(define-data-var base-uri (string-ascii 200) "https://drive.google.com/file/d/12KKRsibpRafoFPZJYYyhMLMA6rVQ8E_7/view?usp=sharing")


(define-data-var last-cards-id uint u0)
(define-data-var deployer principal tx-sender)
(define-data-var mint-limit uint u25)
(define-data-var nft-price uint u0)

(define-map token-count principal uint)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; SIP009: Transfer token to a specified principal
;; #[allow(unchecked_data)]
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (trnsfr id sender recipient)))
;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? stx-ldn-meetup-poap-building-on-bitcoin id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-cards-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))

;; Default Minting
;; #[allow(unchecked_data)]
(define-public (mint (recipient principal) (image-url (string-ascii 456)))
    (let
        (
            (token-id (+ (var-get last-cards-id) u1))
            (current-balance (get-balance tx-sender))
        )
        (asserts! (is-none (map-get? prompt-data recipient)) (err ERR-ONE-PER-WALLET))
        (try! (nft-mint? stx-ldn-meetup-poap-building-on-bitcoin token-id recipient))
        (var-set last-cards-id token-id)
        (map-insert prompt-data recipient {token-id: token-id, url: image-url})
        (map-set token-count recipient (+ current-balance u1))
        (ok token-id)
    )
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? stx-ldn-meetup-poap-building-on-bitcoin id sender recipient)
    success
      (let
        ((sender-balance (get-balance sender))
        (recipient-balance (get-balance recipient)))
          (map-set token-count
            sender
            (- sender-balance u1))
          (map-set token-count
            recipient
            (+ recipient-balance u1))
          (ok success))
    error (err error)))



(define-read-only (check-map (token-holder principal)) 
(ok (map-get? prompt-data token-holder))
)

;; #[allow(unchecked_data)]
(define-public (change-uri (set-image-uri (string-ascii 200))) 
(begin 
  (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
  (var-set base-uri set-image-uri)
  (ok true)
)
)