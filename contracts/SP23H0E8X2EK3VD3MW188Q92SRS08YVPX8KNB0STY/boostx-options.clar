;; (impl-trait 'SP337NP61BD34ES77QK4XZP6R9AXV235GV6W1YMNT.boostx-options-trait.boostx-options-trait)
(impl-trait 'SP23H0E8X2EK3VD3MW188Q92SRS08YVPX8KNB0STY.boostx-options-trait.boostx-options-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant NOT-FOUND (err u100))
(define-constant NOT-AUTHORIZED (err u101))
(define-constant INVALID-ADDRESS (err u102))
(define-constant CONTRACT-CURRENTLY-SET (err u103))
(define-constant INVALID-ID (err u104))
(define-constant EMPTY-LIST (err u105))
(define-constant EMPTY-URI (err u106))

(define-constant owner tx-sender)

(define-data-var referee (optional uint) none)
(define-data-var sponsor1 (optional uint) none)
(define-data-var sponsor2 (optional uint) none)
(define-data-var sponsor3 (optional uint) none)

(define-data-var bns-contract principal 'SP2JMM3PH9AGMASBD11SHG4HWDS6CTY9MGN6CW48G.BNS-V2)
(define-read-only (get-bns-contract)
    (var-get bns-contract)
)
(define-public (update-bns-contract (newContract <nft-trait>))
    (begin
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (asserts! (not (is-eq (get-bns-contract) (contract-of newContract)))
            CONTRACT-CURRENTLY-SET
        )
        (ok (var-set bns-contract (contract-of newContract)))
    )
)

(define-data-var storageUri (string-utf8 255) u"")
(define-read-only (get-storage-uri)
    (var-get storageUri)
)
(define-public (update-storage-uri (uri (string-utf8 255)))
    (begin
        (asserts! (> (len uri) u0) EMPTY-URI)
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (ok (var-set storageUri uri))
    )
)

(define-read-only (get-options-id-tuple)
    {
        referee: (var-get referee),
        sponsor1: (var-get sponsor1),
        sponsor2: (var-get sponsor2),
        sponsor3: (var-get sponsor3),
    }
)

(define-read-only (get-options-id-list)
    (let (
            (referer-bns-id (default-to u0 (var-get referee)))
            (sponsorer1 (default-to u0 (var-get sponsor1)))
            (sponsorer2 (default-to u0 (var-get sponsor2)))
            (sponsorer3 (default-to u0 (var-get sponsor3)))
        )
        (let (
                (append-list-1 (if (> referer-bns-id u0)
                    (list referer-bns-id)
                    (list)
                ))
                (append-list-2 (if (> sponsorer1 u0)
                    (append append-list-1 sponsorer1)
                    append-list-1
                ))
                (append-list-3 (if (> sponsorer2 u0)
                    (append append-list-2 sponsorer2)
                    append-list-2
                ))
                (append-list-final (if (> sponsorer3 u0)
                    (append append-list-3 sponsorer3)
                    append-list-3
                ))
            )
            (ok append-list-final)
        )
    )
)

(define-private (validate-id
        (args {
            id: uint,
            arg-bns-contract: <nft-trait>,
        })
        (res bool)
    )
    (let (
            (bns-contract-arg (get arg-bns-contract args))
            (bns-id (get id args))
            (id-owner (unwrap!
                (unwrap! (contract-call? bns-contract-arg get-owner bns-id) false)
                false
            ))
            ;; Returns the BNS ID's princpal
        )
        (asserts! (is-standard id-owner) false)
        res
    )
)
(define-private (re-arg
        (id uint)
        (arg-bns-contract <nft-trait>)
    )
    {
        id: id,
        arg-bns-contract: arg-bns-contract,
    }
)
(define-public (update-sponsor
        (sponsors (list 3 uint))
        (arg-bns-contract <nft-trait>)
    )
    (let ((rearged-values (map re-arg sponsors
            (list arg-bns-contract arg-bns-contract arg-bns-contract)
        )))
        (asserts! (> (len sponsors) u0) EMPTY-LIST)
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (asserts! (is-eq (var-get bns-contract) (contract-of arg-bns-contract))
            NOT-AUTHORIZED
        )
        (asserts! (fold validate-id rearged-values true) INVALID-ID)

        (if (is-eq (len sponsors) u1)
            (var-set sponsor1 (element-at? sponsors u0))
            (if (is-eq (len sponsors) u2)
                (begin
                    (var-set sponsor1 (element-at? sponsors u0))
                    (var-set sponsor2 (element-at? sponsors u1))
                    true
                )
                (if (is-eq (len sponsors) u3)
                    (begin
                        (var-set sponsor1 (element-at? sponsors u0))
                        (var-set sponsor2 (element-at? sponsors u1))
                        (var-set sponsor3 (element-at? sponsors u2))
                        true
                    )
                    false
                )
            )
        )
        (ok true)
    )
)

(define-public (set-referee
        (ref-id (optional uint))
        (arg-bns-contract <nft-trait>)
    )
    (let (
            (id (unwrap! ref-id NOT-FOUND))
            (id-owner (unwrap!
                (unwrap! (contract-call? arg-bns-contract get-owner id) NOT-FOUND)
                NOT-FOUND
            ))
            ;; Returns the BNS ID's princpal
        )
        (asserts! (is-some ref-id) INVALID-ID)
        (asserts! (is-eq tx-sender owner) NOT-AUTHORIZED)
        (asserts! (is-eq (var-get bns-contract) (contract-of arg-bns-contract))
            NOT-AUTHORIZED
        )
        (asserts! (is-standard id-owner) INVALID-ADDRESS)
        ;; This validates the ID has a valid princpal address
        (if (is-none (var-get referee))
            (ok (var-set referee ref-id))
            (ok false)
        )
    )
)