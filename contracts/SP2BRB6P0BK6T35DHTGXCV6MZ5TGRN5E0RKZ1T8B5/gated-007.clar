;; title: NFT Album contract    
;; version: v 0.001 
;; summary: This NFT contract is designed to take sell either a full album or individual tracks on the gated.so platform.
;; description: Gated Music Album 

;; traits
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
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
(define-constant ERR-SUPPLY-LIMIT-REACHED u100)
(define-constant ERR-NOT-AUTHORIZED u104) 
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-LISTING u106)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-METADATA-FROZEN u505)

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

(define-constant track-count u8)
(define-constant album-price u80000000)
(define-constant track-price u10000000)

(define-constant artist-fee u2800000)   
(define-constant musician-fee u5900000)
(define-constant special-artist-fee u350000)
(define-constant provider-fee u475000) 
(define-constant gated-fee u475000) 


(define-constant DEPLOYER tx-sender)

(define-data-var base-url (string-ascii 80) "https://fuchsia-tropical-alligator-381.mypinata.cloud/ipfs/")
(define-data-var token-uri (string-ascii 246) "ipfs://fuchsia-tropical-alligator-381.mypinata.cloud/ipfs/Qbafkreihcc5rocph3zhqujucnzzj62fsn4kygcfjkuvan3yznklav54jpq4")

;; Separate CIDs for album and each track
(define-data-var album-cid (string-ascii 80) "bafkreihcc5rocph3zhqujucnzzj62fsn4kygcfjkuvan3yznklav54jpq4")
(define-data-var track-1-cid (string-ascii 80) "bafkreie6erwfuoejbmsqtbbuntgyimg3jbjkhpqsjoz5f4bqzd4snmaweq")
(define-data-var track-2-cid (string-ascii 80) "bafkreiaw6mdxveq4i3dowzlspvcv4zbkgzzanukyvqrwy7kdll7ppqdgii")
(define-data-var track-3-cid (string-ascii 80) "bafkreienjwhzbh6vrtyfx4pymqpzbl44pxverkoj5lqzlx2rim6c2tsx4e")
(define-data-var track-4-cid (string-ascii 80) "bafkreic27qj46rpvi2sleysarwzbadhbz3anv2gpepkgul6tw7sjg2bhmm")
(define-data-var track-5-cid (string-ascii 80) "bafkreicqm2icvbyyj2rhmsycgc34raljpupl2eigtgguxc6avj7cg5fpue")
(define-data-var track-6-cid (string-ascii 80) "bafkreihczd6nqww2rr4eflo56c573vd5ruvw6iax3l2ymtvajv7zcgefim")
(define-data-var track-7-cid (string-ascii 80) "bafkreia5ffu2t7x2itciaye7g3mdkmk3kcs7kg4nnh5drpgbihc73e5buq")
(define-data-var track-8-cid (string-ascii 80) "bafkreihfb5gpetcpgzut3wb4dp4qcp4bweunqmxwjens2a4cc2fqohfyt4")

;; Metadata URIs using individual CIDs
(define-data-var album-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get album-cid)))
(define-data-var track-1-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-1-cid)))
(define-data-var track-2-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-2-cid)))
(define-data-var track-3-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-3-cid)))
(define-data-var track-4-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-4-cid)))
(define-data-var track-5-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-5-cid)))
(define-data-var track-6-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-6-cid)))
(define-data-var track-7-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-7-cid)))
(define-data-var track-8-metadata-uri (string-ascii 256) (concat (var-get base-url) (var-get track-8-cid)))

(define-data-var metadata-frozen bool false)

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

    
    (asserts! (>= album-supply (var-get album-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? u4750000 contract-caller provider))
    (try! (stx-transfer? u3500000 contract-caller special-artist))
    (try! (stx-transfer? u2150000 contract-caller gated))


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
    (asserts! (>= track-1-supply (var-get track-1-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-1-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-1-contributor-2))
    (try! (nft-mint? radio-silence (var-get track-1-token-id) recipient))
    (var-set track-1-token-id (+ (var-get track-1-token-id) u1))
    (ok true)))

(define-public (mint-track-2 (recipient principal)) 
    (begin
    (asserts! (>= track-2-supply (var-get track-2-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-2-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-2-contributor-2))
    (try! (nft-mint? you-make-it-alright (var-get track-2-token-id) recipient))
    (var-set track-2-token-id (+ (var-get track-2-token-id) u1))
    (ok true)))

(define-public (mint-track-3 (recipient principal)) 
    (begin
    (asserts! (>= track-3-supply (var-get track-3-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-3-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-3-contributor-2))
    (try! (nft-mint? mortals (var-get track-3-token-id) recipient))
    (var-set track-3-token-id (+ (var-get track-3-token-id) u1))
    (ok true)))

(define-public (mint-track-4 (recipient principal)) 
    (begin
    (asserts! (>= track-4-supply (var-get track-4-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-4-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-4-contributor-2))
    (try! (nft-mint? buzz-head (var-get track-4-token-id) recipient))
    (var-set track-4-token-id (+ (var-get track-4-token-id) u1))
    (ok true)))

(define-public (mint-track-5 (recipient principal)) 
    (begin
    (asserts! (>= track-5-supply (var-get track-5-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-5-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-5-contributor-2))
    (try! (nft-mint? grey (var-get track-5-token-id) recipient))
    (var-set track-5-token-id (+ (var-get track-5-token-id) u1))
    (ok true)))

(define-public (mint-track-6 (recipient principal)) 
    (begin
    (asserts! (>= track-6-supply (var-get track-6-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-6-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-6-contributor-2))
    (try! (nft-mint? exile (var-get track-6-token-id) recipient))
    (var-set track-6-token-id (+ (var-get track-6-token-id) u1))
    (ok true)))

(define-public (mint-track-7 (recipient principal)) 
    (begin
    (asserts! (>= track-7-supply (var-get track-7-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-7-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-7-contributor-2))
    (try! (nft-mint? i-shouldnt-break (var-get track-7-token-id) recipient))
    (var-set track-7-token-id (+ (var-get track-7-token-id) u1))
    (ok true)))

(define-public (mint-track-8 (recipient principal)) 
    (begin
    (asserts! (>= track-8-supply (var-get track-8-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))
    (try! (stx-transfer? special-artist-fee contract-caller provider))
    (try! (stx-transfer? provider-fee contract-caller provider))
    (try! (stx-transfer? gated-fee contract-caller gated))
    (try! (stx-transfer? artist-fee contract-caller track-8-contributor-1))
    (try! (stx-transfer? musician-fee contract-caller track-8-contributor-2))
    (try! (nft-mint? bbq-to-braai (var-get track-8-token-id) recipient))
    (var-set track-8-token-id (+ (var-get track-8-token-id) u1))
    (ok true)))

;; read only functions to get last token id (SIP-09)
(define-read-only (get-last-token-id)
    (let ((highest-id 
            (fold compare-ids 
                (list 
                    (var-get track-1-token-id)
                    (var-get track-2-token-id)
                    (var-get track-3-token-id)
                    (var-get track-4-token-id)
                    (var-get track-5-token-id)
                    (var-get track-6-token-id)
                    (var-get track-7-token-id)
                    (var-get track-8-token-id)
                ) 
                u0)))
        (ok (- highest-id u1))))


(define-private (compare-ids (a uint) (b uint))
    (if (> a b) a b))

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

(define-read-only (get-owner (token-id uint))
    (ok (if (< token-id (var-get track-1-token-id))
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
                                    (nft-get-owner? bbq-to-braai token-id))))))))))

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

;; Token URI getters for each track (implementing SIP-009)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get token-uri))))

(define-read-only (get-token-uri-track-1 (token-id uint))
    (ok (some (var-get track-1-metadata-uri))))

(define-read-only (get-token-uri-track-2 (token-id uint))
    (ok (some (var-get track-2-metadata-uri))))

(define-read-only (get-token-uri-track-3 (token-id uint))
    (ok (some (var-get track-3-metadata-uri))))

(define-read-only (get-token-uri-track-4 (token-id uint))
    (ok (some (var-get track-4-metadata-uri))))

(define-read-only (get-token-uri-track-5 (token-id uint))
    (ok (some (var-get track-5-metadata-uri))))

(define-read-only (get-token-uri-track-6 (token-id uint))
    (ok (some (var-get track-6-metadata-uri))))

(define-read-only (get-token-uri-track-7 (token-id uint))
    (ok (some (var-get track-7-metadata-uri))))

(define-read-only (get-token-uri-track-8 (token-id uint))
    (ok (some (var-get track-8-metadata-uri))))



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

            (define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-sender-owner token-id) (err u401))
        (if (< token-id (var-get track-1-token-id))
            (try! (nft-transfer? radio-silence token-id sender recipient))
            (if (< token-id (var-get track-2-token-id))
                (try! (nft-transfer? you-make-it-alright token-id sender recipient))
                (if (< token-id (var-get track-3-token-id))
                    (try! (nft-transfer? mortals token-id sender recipient))
                    (if (< token-id (var-get track-4-token-id))
                        (try! (nft-transfer? buzz-head token-id sender recipient))
                        (if (< token-id (var-get track-5-token-id))
                            (try! (nft-transfer? grey token-id sender recipient))
                            (if (< token-id (var-get track-6-token-id))
                                (try! (nft-transfer? exile token-id sender recipient))
                                (if (< token-id (var-get track-7-token-id))
                                    (try! (nft-transfer? i-shouldnt-break token-id sender recipient))
                                    (try! (nft-transfer? bbq-to-braai token-id sender recipient)))))))))
        (ok true)))


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

(define-public (update-metadata-cids 
    (new-album-cid (string-ascii 80))
    (new-track-cids (list 8 (string-ascii 80))))
    (begin
        ;; Check authorization
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Ensure metadata is not frozen
        (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))

        ;; Validate list length
        (asserts! (is-eq (len new-track-cids) u8) (err ERR-NOT-FOUND))

        ;; Update album CID and URI
        (var-set album-cid new-album-cid)
        (var-set album-metadata-uri (concat (var-get base-url) new-album-cid))

        ;; Update track CIDs and URIs
        (var-set track-1-cid (unwrap! (element-at new-track-cids u0) (err ERR-NOT-FOUND)))
        (var-set track-1-metadata-uri (concat (var-get base-url) (var-get track-1-cid)))
        
        (var-set track-2-cid (unwrap! (element-at new-track-cids u1) (err ERR-NOT-FOUND)))
        (var-set track-2-metadata-uri (concat (var-get base-url) (var-get track-2-cid)))
        
        (var-set track-3-cid (unwrap! (element-at new-track-cids u2) (err ERR-NOT-FOUND)))
        (var-set track-3-metadata-uri (concat (var-get base-url) (var-get track-3-cid)))
        
        (var-set track-4-cid (unwrap! (element-at new-track-cids u3) (err ERR-NOT-FOUND)))
        (var-set track-4-metadata-uri (concat (var-get base-url) (var-get track-4-cid)))
        
        (var-set track-5-cid (unwrap! (element-at new-track-cids u4) (err ERR-NOT-FOUND)))
        (var-set track-5-metadata-uri (concat (var-get base-url) (var-get track-5-cid)))
        
        (var-set track-6-cid (unwrap! (element-at new-track-cids u5) (err ERR-NOT-FOUND)))
        (var-set track-6-metadata-uri (concat (var-get base-url) (var-get track-6-cid)))
        
        (var-set track-7-cid (unwrap! (element-at new-track-cids u6) (err ERR-NOT-FOUND)))
        (var-set track-7-metadata-uri (concat (var-get base-url) (var-get track-7-cid)))
        
        (var-set track-8-cid (unwrap! (element-at new-track-cids u7) (err ERR-NOT-FOUND)))
        (var-set track-8-metadata-uri (concat (var-get base-url) (var-get track-8-cid)))

        (ok true)))

        (define-public (freeze-metadata)
    (begin
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        (var-set metadata-frozen true)
        (ok true)))

(define-public (transfer-track-1 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? radio-silence token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? radio-silence token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))

            (define-public (transfer-track-2 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? you-make-it-alright token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? you-make-it-alright token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))


(define-public (transfer-track-3 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? mortals token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? mortals token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))


            (define-public (transfer-track-4 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? buzz-head token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? buzz-head token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))

            (define-public (transfer-track-5 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? grey token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? grey token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))

            (define-public (transfer-track-6 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? exile token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? exile token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))

            (define-public (transfer-track-7 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? i-shouldnt-break token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? i-shouldnt-break token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))

            (define-public (transfer-track-8 (token-id uint) (sender principal) (recipient principal))
    (begin 
        ;; Verify token exists
        (asserts! (< token-id (var-get track-1-token-id)) (err ERR-NOT-FOUND))
        ;; Get current owner and verify sender is owner
        (match (nft-get-owner? bbq-to-braai token-id)
            owner (try! (if (is-eq sender owner) 
                    (ok (nft-transfer? bbq-to-braai token-id sender recipient))
                    (err ERR-NOT-AUTHORIZED)))
            (err ERR-NOT-FOUND))))