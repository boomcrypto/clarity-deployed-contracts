;; title: NFT Album contract    
;; version: v 0.004 
;; summary: This NFT contract is designed to take sell either a full album or individual tracks on the gated.so platform.
;; description: Gated Music Album 

;; traits
;;

;; token definitions
(define-non-fungible-token radio-silence uint)
(define-non-fungible-token you-make-it-alright uint)
(define-non-fungible-token mortals uint)
(define-non-fungible-token buzz-head uint)
(define-non-fungible-token grey uint)
(define-non-fungible-token exile uint)
(define-non-fungible-token i-shouldnt-break uint)
(define-non-fungible-token bbq-to-braai uint)
;;

;; Error handling
(define-constant ERR-SUPPLY-LIMIT-REACHED (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u104)) 
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-LISTING u106)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-INVALID-PERCENTAGE u114)


;; Supply setup for album
(define-constant album-supply u100)

;; Supply setup for tracks
(define-constant track-1-supply u100)
(define-constant track-2-supply u100)
(define-constant track-3-supply u100)
(define-constant track-4-supply u100)
(define-constant track-5-supply u100)
(define-constant track-6-supply u100)
(define-constant track-7-supply u100)
(define-constant track-8-supply u100)

(define-constant BASE_IPFS_URL "https://fuchsia-tropical-alligator-381.mypinata.cloud/ipfs/")
(define-constant track-count u8)
(define-constant album-price u78000000)

(define-constant track-price u10000000) 
(define-constant musician-fee u4000000)
(define-constant artist-fee u2500000)   
(define-constant special-artist-fee u2500000)
(define-constant provider-fee u500000) 
(define-constant gated-fee u500000) 


(define-constant DEPLOYER tx-sender)


;; Contributors
(define-constant track-1-contributor-1 'SP27817Y26A3SAEJSDF2RSHXAE37BQ2S8QEK05NWK)
(define-constant track-1-contributor-2 'SP3ZZAXRRARG41FER70DEVCM7M1556CKBA6SQ4FMG)

(define-constant track-2-contributor-1 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V)
(define-constant track-2-contributor-2 'SP3A3X5A41JN2RSGRAD3Y72FPEJ9TVKH71PY7NFS6)

(define-constant track-3-contributor-1 'SPZRAE52H2NC2MDBEV8W99RFVPK8Q9BW8H88XV9N)
(define-constant track-3-contributor-2 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8)

(define-constant track-4-contributor-1 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA)
(define-constant track-4-contributor-2 'SP640CYVPSHVF2N2YPT0Q49VASAT9CHYNSQGBAAT)

(define-constant track-5-contributor-1 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0)
(define-constant track-5-contributor-2 'SP1M57B9C0A89CCKZ43W5PEW43BCNFNFX3SGX7J5K)

(define-constant track-6-contributor-1 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB)
(define-constant track-6-contributor-2 'SP3NZE3E8PNM4N9RC7NCXG6FPQQS1HTGXZQG4REQG)

(define-constant track-7-contributor-1 'SP342MMZRDFSC556F193N76D87SCTYX7SSHD8H3XD)
(define-constant track-7-contributor-2 'SP1WZJ9NV8AG971XX3MDPQE3D2H8SQ4S5D57P1YZY)

(define-constant track-8-contributor-1 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV)
(define-constant track-8-contributor-2 'SP1SF6C6GC6F6FJ8CQYMXZTVHYJDXPS8ARHPSSZNJ)

(define-constant special-artist 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3)
(define-constant provider 'SP3V0KZBGK20CMEE74KY0J0H0MHYSGWVAREKWMCPQ)
(define-constant gated 'SP2BRB6P0BK6T35DHTGXCV6MZ5TGRN5E0RKZ1T8B5)
;;

;; data vars
(define-data-var album-token-id uint u1)
(define-data-var track-1-token-id uint u1)
(define-data-var track-2-token-id uint u1)
(define-data-var track-3-token-id uint u1)
(define-data-var track-4-token-id uint u1)
(define-data-var track-5-token-id uint u1)
(define-data-var track-6-token-id uint u1)
(define-data-var track-7-token-id uint u1)
(define-data-var track-8-token-id uint u1)
;;

;; data maps
;;

;; public functions
(define-public (mint-album (recipient principal)) 

    (begin

    
    (asserts! (>= album-supply (var-get album-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? special-artist-fee contract-caller special-artist))

    
    (try! (stx-transfer? artist-fee contract-caller track-1-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-1-contributor-2))
    (try! (nft-mint? radio-silence (var-get track-1-token-id) recipient))
    (var-set track-1-token-id (+ (var-get track-1-token-id) u1))
    
    (try! (stx-transfer? artist-fee contract-caller track-2-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-2-contributor-2))
    (try! (nft-mint? you-make-it-alright (var-get track-2-token-id) recipient))
    (var-set track-2-token-id (+ (var-get track-2-token-id) u1))

    (try! (stx-transfer? artist-fee contract-caller track-3-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-3-contributor-2))
    (try! (nft-mint? mortals (var-get track-3-token-id) recipient))
    (var-set track-3-token-id (+ (var-get track-3-token-id) u1))

    (try! (stx-transfer? artist-fee contract-caller track-4-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-4-contributor-2))
    (try! (nft-mint? buzz-head (var-get track-4-token-id) recipient))
    (var-set track-4-token-id (+ (var-get track-4-token-id) u1))

    (try! (stx-transfer? artist-fee contract-caller track-5-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-5-contributor-2))
    (try! (nft-mint? grey (var-get track-5-token-id) recipient))
    (var-set track-5-token-id (+ (var-get track-5-token-id) u1))

    (try! (stx-transfer? artist-fee contract-caller track-6-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-6-contributor-2))
    (try! (nft-mint? exile (var-get track-6-token-id) recipient))
    (var-set track-6-token-id (+ (var-get track-6-token-id) u1))

     (try! (stx-transfer? artist-fee contract-caller track-7-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-7-contributor-2))
    (try! (nft-mint? i-shouldnt-break (var-get track-7-token-id) recipient))
    (var-set track-7-token-id (+ (var-get track-7-token-id) u1))

    (try! (stx-transfer? artist-fee contract-caller track-8-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-8-contributor-2))
    (try! (nft-mint? bbq-to-braai (var-get track-8-token-id) recipient))
    (var-set track-8-token-id (+ (var-get track-8-token-id) u1))

    (var-set album-token-id (+ (var-get album-token-id) u1))

    (ok true)
    )
)

(define-public (mint-track-1 (recipient principal))
    (begin
    (asserts! (>= track-1-supply (var-get track-1-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-1-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-1-contributor-2))
    (try! (nft-mint? radio-silence (var-get track-1-token-id) recipient))
    (var-set track-1-token-id (+ (var-get track-1-token-id) u1))
    (ok true)))

(define-public (mint-track-2 (recipient principal)) 
    (begin
    (asserts! (>= track-2-supply (var-get track-2-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-2-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-2-contributor-2))
    (try! (nft-mint? you-make-it-alright (var-get track-2-token-id) recipient))
    (var-set track-2-token-id (+ (var-get track-2-token-id) u1))
    (ok true)))

(define-public (mint-track-3 (recipient principal)) 
    (begin
    (asserts! (>= track-3-supply (var-get track-3-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-3-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-3-contributor-2))
    (try! (nft-mint? mortals (var-get track-3-token-id) recipient))
    (var-set track-3-token-id (+ (var-get track-3-token-id) u1))
    (ok true)))

(define-public (mint-track-4 (recipient principal)) 
    (begin
    (asserts! (>= track-4-supply (var-get track-4-token-id)) ERR-SUPPLY-LIMIT-REACHED)

    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-4-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-4-contributor-2))
    (try! (nft-mint? buzz-head (var-get track-4-token-id) recipient))
    (var-set track-4-token-id (+ (var-get track-4-token-id) u1))
    (ok true)))

(define-public (mint-track-5 (recipient principal)) 
    (begin
    (asserts! (>= track-5-supply (var-get track-5-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-5-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-5-contributor-2))
    (try! (nft-mint? grey (var-get track-5-token-id) recipient))
    (var-set track-5-token-id (+ (var-get track-5-token-id) u1))
    (ok true)))

(define-public (mint-track-6 (recipient principal)) 
    (begin
    (asserts! (>= track-6-supply (var-get track-6-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-6-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-6-contributor-2))
    (try! (nft-mint? exile (var-get track-6-token-id) recipient))
    (var-set track-6-token-id (+ (var-get track-6-token-id) u1))
    (ok true)))

(define-public (mint-track-7 (recipient principal)) 
    (begin
    (asserts! (>= track-7-supply (var-get track-7-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-7-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-7-contributor-2))
    (try! (nft-mint? i-shouldnt-break (var-get track-7-token-id) recipient))
    (var-set track-7-token-id (+ (var-get track-7-token-id) u1))
    (ok true)))

(define-public (mint-track-8 (recipient principal)) 
    (begin
    (asserts! (>= track-8-supply (var-get track-8-token-id)) ERR-SUPPLY-LIMIT-REACHED)
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-8-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-8-contributor-2))
    (try! (nft-mint? bbq-to-braai (var-get track-8-token-id) recipient))
    (var-set track-8-token-id (+ (var-get track-8-token-id) u1))
    (ok true)))

;; read only functions to get last token id (SIP-09)

(define-read-only (get-album-id)
    (var-get album-token-id))

(define-read-only (get-track-1-id)
    (var-get track-1-token-id))

(define-read-only (get-track-2-id)
    (var-get track-2-token-id))

(define-read-only (get-track-3-id)
    (var-get track-3-token-id))

(define-read-only (get-track-4-id)
    (var-get track-4-token-id))

(define-read-only (get-track-5-id)
    (var-get track-5-token-id))

(define-read-only (get-track-6-id)
    (var-get track-6-token-id))

(define-read-only (get-track-7-id)
    (var-get track-7-token-id))

(define-read-only (get-track-8-id)
    (var-get track-8-token-id))


;; read only functions to get owner (SIP-09)

(define-read-only (get-owner-track-1 (token-id uint))
(nft-get-owner? radio-silence token-id))

(define-read-only (get-owner-track-2 (token-id uint))
(nft-get-owner? you-make-it-alright token-id))

(define-read-only (get-owner-track-3 (token-id uint))
(nft-get-owner? mortals token-id))

(define-read-only (get-owner-track-4 (token-id uint))
(nft-get-owner? buzz-head token-id))

(define-read-only (get-owner-track-5 (token-id uint))
(nft-get-owner? grey token-id))

(define-read-only (get-owner-track-6 (token-id uint))
(nft-get-owner? exile token-id))

(define-read-only (get-owner-track-7 (token-id uint))
(nft-get-owner? i-shouldnt-break token-id))

(define-read-only (get-owner-track-8 (token-id uint))
(nft-get-owner? bbq-to-braai token-id))


;; private functions
;;

(define-map token-count principal uint)
(define-map market uint {price: uint, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))


(define-private (is-sender-owner (token-id uint))
    (let 
        ((owner 
            (if (< token-id (var-get track-1-token-id))
                (nft-get-owner? radio-silence token-id)
                (if (< token-id (var-get track-2-token-id))
                    (nft-get-owner? you-make-it-alright token-id)
                    (if (< token-id (var-get track-3-token-id))
                        (nft-get-owner? mortals token-id)
                        (if (< token-id (var-get track-4-token-id))
                            (nft-get-owner? buzz-head token-id)
                            (if (< token-id (var-get track-5-token-id))
                                (nft-get-owner? grey token-id)
                                (if (< token-id (var-get track-6-token-id))
                                    (nft-get-owner? exile token-id)
                                    (if (< token-id (var-get track-7-token-id))
                                        (nft-get-owner? i-shouldnt-break token-id)
                                        (if (< token-id (var-get track-8-token-id))
                                            (nft-get-owner? bbq-to-braai token-id)
                                            none)))))))))
        )
        (and 
            (is-some owner)
            (is-eq (some tx-sender) owner))))


(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) )
    (let ((listing  {price: price, royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
    (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (token-id uint))
    (let 
        (
        ;; Use the is-sender-owner function to find the current owner
        (owner 
        (if (< token-id (var-get track-1-token-id))
            (unwrap! (nft-get-owner? radio-silence token-id) (err ERR-NOT-FOUND))
            (if (< token-id (var-get track-2-token-id))
                (unwrap! (nft-get-owner? you-make-it-alright token-id) (err ERR-NOT-FOUND))
                (if (< token-id (var-get track-3-token-id))
                    (unwrap! (nft-get-owner? mortals token-id) (err ERR-NOT-FOUND))
                    (if (< token-id (var-get track-4-token-id))
                        (unwrap! (nft-get-owner? buzz-head token-id) (err ERR-NOT-FOUND))
                        (if (< token-id (var-get track-5-token-id))
                            (unwrap! (nft-get-owner? grey token-id) (err ERR-NOT-FOUND))
                            (if (< token-id (var-get track-6-token-id))
                                (unwrap! (nft-get-owner? exile token-id) (err ERR-NOT-FOUND))
                                (if (< token-id (var-get track-7-token-id))
                                    (unwrap! (nft-get-owner? i-shouldnt-break token-id) (err ERR-NOT-FOUND))
                                    (unwrap! (nft-get-owner? bbq-to-braai token-id) (err ERR-NOT-FOUND))))))))))
        ;; Get the listing from the marketplace
        (listing (unwrap! (map-get? market token-id) (err ERR-LISTING)))
        ;; Extract price and royalty details
        (price (get price listing))
        (royalty (get royalty listing))
      )
      ;; Perform the token purchase
      (begin
        ;; Transfer the STX price to the current owner
        (try! (stx-transfer? price tx-sender owner))
        ;; Pay the royalty to the creator
        (try! (pay-royalty price royalty))
        ;; Transfer the NFT to the buyer
        (if (< token-id (var-get track-1-token-id))
            (try! (nft-transfer? radio-silence token-id owner tx-sender))
            (if (< token-id (var-get track-2-token-id))
                (try! (nft-transfer? you-make-it-alright token-id owner tx-sender))
                (if (< token-id (var-get track-3-token-id))
                    (try! (nft-transfer? mortals token-id owner tx-sender))
                    (if (< token-id (var-get track-4-token-id))
                        (try! (nft-transfer? buzz-head token-id owner tx-sender))
                        (if (< token-id (var-get track-5-token-id))
                            (try! (nft-transfer? grey token-id owner tx-sender))
                            (if (< token-id (var-get track-6-token-id))
                                (try! (nft-transfer? exile token-id owner tx-sender))
                                (if (< token-id (var-get track-7-token-id))
                                    (try! (nft-transfer? i-shouldnt-break token-id owner tx-sender))
                                    (try! (nft-transfer? bbq-to-braai token-id owner tx-sender))))))))))
        ;; Remove the listing from the marketplace
        (map-delete market token-id)
        ;; Log the transaction
        (print {action: "buy-in-ustx", token-id: token-id, buyer: tx-sender, seller: owner})
        ;; Return success
        (ok true)))
    
(define-data-var royalty-percent uint u0)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender provider) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender provider)))
    (try! (stx-transfer? royalty-amount tx-sender provider))
    (print false)
  )
  (ok true)))