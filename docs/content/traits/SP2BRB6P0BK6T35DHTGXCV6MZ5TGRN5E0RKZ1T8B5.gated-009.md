---
title: "Trait gated-009"
draft: true
---
```
;; title: NFT Album contract    
;; version: v 0.002
;; summary: This NFT contract is designed to sell either a full album or individual tracks. 
;; description: When Walls Break Various Artists

;; SIP09 traits
;;(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; (define-trait nft-trait
;;   (
;;     ;; Last token ID, limited to uint range
;;     (get-last-token-id () (response uint uint))

;;     ;; URI for metadata associated with the token
;;     (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

;;      ;; Owner of a given token identifier
;;     (get-owner (uint) (response (optional principal) uint))

;;     ;; Transfer from the sender to a new principal
;;     (transfer (uint principal principal) (response bool uint))
;;   )
;; )

;; BEGINNING OF SIP 009 REQUIRED FUNCTIONS ;;
;; Get last token ID 
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id)))

;; Get token-uri
(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get token-uri)))
)

;; Get owner
(define-private (get-owner (token-id uint))
    (if (and (>= token-id u0) (<= token-id u99))
        ;; Token belongs to Track 1
        (ok (nft-get-owner? radio-silence token-id))
    (if (and (>= token-id u100) (<= token-id u200))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? you-make-it-alright token-id))
    (if (and (>= token-id u200) (<= token-id u300))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? mortals token-id))
    (if (and (>= token-id u300) (<= token-id u400))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? buzzhead token-id))
    (if (and (>= token-id u400) (<= token-id u500))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? grey token-id))
    (if (and (>= token-id u500) (<= token-id u600))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? exile token-id))
    (if (and (>= token-id u600) (<= token-id u700))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? i-shouldnt-break token-id))
    (if (and (>= token-id u700) (<= token-id u800))
        ;; Token belongs to Track 2
        (ok (nft-get-owner? bbq-to-braai token-id))
    (err u404)))))))))
) ;; Token ID not found

;; Transfer function
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        ;; Determine the track based on token ID ranges
        (if (and (>= token-id u0) (<= token-id u99))
            (ok (try! (nft-transfer? radio-silence token-id sender recipient)))

          (if (and (>= token-id u100) (<= token-id u199))
            (ok (try! (nft-transfer? you-make-it-alright token-id sender recipient)))

         (if (and (>= token-id u200) (<= token-id u299))
            (ok (try! (nft-transfer? mortals token-id sender recipient)))
         
         (if (and (>= token-id u300) (<= token-id u399))
            (ok (try! (nft-transfer? buzzhead token-id sender recipient)))
        
         (if (and (>= token-id u400) (<= token-id u499))
            (ok (try! (nft-transfer? grey token-id sender recipient)))
        
         (if (and (>= token-id u500) (<= token-id u599))
            (ok (try! (nft-transfer? exile token-id sender recipient)))

         (if (and (>= token-id u600) (<= token-id u699))
            (ok (try! (nft-transfer? i-shouldnt-break token-id sender recipient)))
        
         (if (and (>= token-id u700) (<= token-id u799))
            (ok (try! (nft-transfer? bbq-to-braai token-id sender recipient)))
        
        (err u404)))))))));; Invalid token ID
    )
)

;; END OF SIP009 REQUIRED FUNCTIONS ;;

;; Sets the Deployer
(define-constant DEPLOYER tx-sender)

;; Token definitions
(define-non-fungible-token radio-silence uint)
(define-non-fungible-token you-make-it-alright uint)
(define-non-fungible-token mortals uint)
(define-non-fungible-token buzzhead uint)
(define-non-fungible-token grey uint)
(define-non-fungible-token exile uint)
(define-non-fungible-token i-shouldnt-break uint)
(define-non-fungible-token bbq-to-braai uint)

;; Error handling
(define-constant ERR-SUPPLY-LIMIT-REACHED u100)
(define-constant ERR-NOT-AUTHORIZED u104) 
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-LISTING u106)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-METADATA-FROZEN u505)
(define-constant ERR-WRONG-COMMISSION u107)

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


;; Collection/Track constants - 1-8
(define-constant RADIO-SILENCE u1)
(define-constant YOU-MAKE-IT-ALRIGHT u2)
(define-constant MORTALS u3)
(define-constant BUZZ-HEAD u4)
(define-constant GREY u5)
(define-constant EXILE u6)
(define-constant I-SHOULDNT-BREAK u7)
(define-constant BBQ-TO-BRAAI u8)

;; Supply setup for track count
(define-constant track-count u8)
(define-constant track-supply u100)

;; Pricing
(define-constant album-price u80000000)
(define-constant track-price u10000000)

;; Defines album contributor fees
(define-constant album-artist-fee u350000)
(define-constant artist-fee u2800000)   
(define-constant musician-fee u5900000)
(define-constant provider-fee u475000) 
(define-constant gated-fee u475000) 

;; Track contributors
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

(define-constant album-artist 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3)
(define-constant provider 'SP3V0KZBGK20CMEE74KY0J0H0MHYSGWVAREKWMCPQ)
(define-constant gated 'SP2BRB6P0BK6T35DHTGXCV6MZ5TGRN5E0RKZ1T8B5)


;; Defines Token URI (SIP 09 Trait)
(define-data-var token-uri (string-ascii 246) "ipfs://bafkreib2reku3nac3qvayofp3ycf242vwai62yu43q2xubbgqueg5tgioq")

;; Separate CIDs for album and each track
(define-data-var album-cid (string-ascii 246) "bafkreib2reku3nac3qvayofp3ycf242vwai62yu43q2xubbgqueg5tgioq")
(define-data-var track-1-cid (string-ascii 80) "bafkreie3kaye6fua2fajllforftkykiaiw3jkyzzwi7e4ermfm275uqxq4")
(define-data-var track-2-cid (string-ascii 80) "bafkreigjzmlzlattjs4dmznm4ffxou7uw3mxnsl4pom35zslz5exj7vsrq")
(define-data-var track-3-cid (string-ascii 80) "bafkreihbgz5ut6c4spd7msflsgknrhpbwuu43zsljzltp5alhofbotyvqa")
(define-data-var track-4-cid (string-ascii 80) "bafkreih4tkdlxuodv3yzsvenha6s6lvva2euxtzu5wrmbsv73hkhnd3gda")
(define-data-var track-5-cid (string-ascii 80) "bafkreihdldzj3orznm6vfa34wibujalzj6sutzv6dpiqnfj36nndyhb7pi")
(define-data-var track-6-cid (string-ascii 80) "bafkreibd7bohwstdv23qbvrdbe7yrpevroccagu5r27qiiffwbqszgb4o4")
(define-data-var track-7-cid (string-ascii 80) "bafkreid7nj3yyzpjmw7ngvajhabjnq7lkoxsydr27zgp5lqhg3phv6whia")
(define-data-var track-8-cid (string-ascii 80) "bafkreiarb57n3ef55ytuvbgkazzfgcaeexsefwalj2tku4z46xogfuwdxi")

(define-data-var last-token-id uint u0)
(define-data-var album-token-id uint u0)
(define-data-var last-token-track-1-id uint u0)
(define-data-var last-token-track-2-id uint u100)
(define-data-var last-token-track-3-id uint u200)
(define-data-var last-token-track-4-id uint u300)
(define-data-var last-token-track-5-id uint u400)
(define-data-var last-token-track-6-id uint u500)
(define-data-var last-token-track-7-id uint u600)
(define-data-var last-token-track-8-id uint u700)

(define-private (is-sender-owner (token-id uint))
    (begin 
        ;; Check token range and get appropriate owner
        (if (<= token-id u100)
            (let ((owner (unwrap! (nft-get-owner? radio-silence token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? radio-silence token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u200)
            (let ((owner (unwrap! (nft-get-owner? you-make-it-alright token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? you-make-it-alright token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u300)
            (let ((owner (unwrap! (nft-get-owner? mortals token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? mortals token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u400)
            (let ((owner (unwrap! (nft-get-owner? buzzhead token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? buzzhead token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u500)
            (let ((owner (unwrap! (nft-get-owner? grey token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? grey token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u600)
            (let ((owner (unwrap! (nft-get-owner? exile token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? exile token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u700)
            (let ((owner (unwrap! (nft-get-owner? i-shouldnt-break token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? i-shouldnt-break token-id)) false)
                    (is-eq tx-sender owner)))
        (if (<= token-id u800)
            (let ((owner (unwrap! (nft-get-owner? bbq-to-braai token-id) false)))
                (begin 
                    (asserts! (is-some (nft-get-owner? bbq-to-braai token-id)) false)
                    (is-eq tx-sender owner)))
        false)))))))))
)

;; public functions

;; Airdrop function for Track 1 - Migration version (no payments required)
(define-public (airdrop-track-1-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-1-id (var-get last-token-track-1-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-1-id recipient-count) u99) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-1 recipients (ok track-1-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-1-id (+ track-1-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 2 - Migration version (no payments required)
(define-public (airdrop-track-2-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-2-id (var-get last-token-track-2-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-2-id recipient-count) u199) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold  airdrop-track-2 recipients (ok track-2-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-2-id (+ track-2-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 3 - Migration version (no payments required)
(define-public (airdrop-track-3-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-3-id (var-get last-token-track-3-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-3-id recipient-count) u299) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold  airdrop-track-3 recipients (ok track-3-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-3-id (+ track-3-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 4 - Migration version (no payments required)
(define-public (airdrop-track-4-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-4-id (var-get last-token-track-4-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-4-id recipient-count) u399) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-4 recipients (ok track-4-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-4-id (+ track-4-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 5 - Migration version (no payments required)
(define-public (airdrop-track-5-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-5-id (var-get last-token-track-5-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-5-id recipient-count) u499) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-5 recipients (ok track-5-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-5-id (+ track-5-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 6 - Migration version (no payments required)
(define-public (airdrop-track-6-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-6-id (var-get last-token-track-6-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-6-id recipient-count) u599) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-6 recipients (ok track-6-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-6-id (+ track-6-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 7 - Migration version (no payments required)
(define-public (airdrop-track-7-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-7-id (var-get last-token-track-7-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-7-id recipient-count) u699) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-7 recipients (ok track-7-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-7-id (+ track-7-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)

;; Airdrop function for Track 8 - Migration version (no payments required)
(define-public (airdrop-track-8-migration (recipients (list 200 principal)))
    (begin
        ;; Only contract owner can perform migration airdrop
        (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
        
        ;; Get current IDs
        (let (
            (track-8-id (var-get last-token-track-8-id))
            (global-token-id (var-get last-token-id))
            (recipient-count (len recipients))
        )
            ;; Check if there's enough supply remaining
            (asserts! (<= (+ track-8-id recipient-count) u799) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Perform the airdrop without payments
            (try! (fold airdrop-track-8 recipients (ok track-8-id)))
            
            ;; Update both IDs after all mints are complete
            (var-set last-token-track-8-id (+ track-8-id recipient-count))
            (var-set last-token-id (+ global-token-id recipient-count))
            
            ;; Return success with the last global token ID used
            (ok (+ global-token-id (- recipient-count u1)))
        )
    )
)


;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-1 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? radio-silence success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-2 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? you-make-it-alright success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-3 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? mortals success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-4 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? buzzhead success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-5 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? grey success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-6 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? exile success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-7 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? i-shouldnt-break success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

;; Helper function to mint a single NFT during the airdrop
(define-private (airdrop-track-8 (recipient principal) (current-id (response uint uint)))
    (match current-id
        success (begin
            ;; Mint token
            (try! (nft-mint? bbq-to-braai success recipient))
            ;; Return next ID
            (ok (+ success u1))
        )
        error (err error)
    )
)

(define-public (mint-album (recipient principal))

    (begin
        (let (
            (global-token-id (var-get last-token-id))
            (track-1-id (var-get last-token-track-1-id))
            (track-2-id (var-get last-token-track-2-id))
            (track-3-id (var-get last-token-track-3-id))
            (track-4-id (var-get last-token-track-4-id))
            (track-5-id (var-get last-token-track-5-id))
            (track-6-id (var-get last-token-track-6-id))
            (track-7-id (var-get last-token-track-7-id))
            (track-8-id (var-get last-token-track-8-id))
        )
        ;; Check album supply limit
        (asserts! (>= album-supply (var-get album-token-id)) (err ERR-SUPPLY-LIMIT-REACHED))

        ;; Transfer album-wide payments
        (try! (stx-transfer? u4750000 contract-caller provider))
        (try! (stx-transfer? u3500000 contract-caller album-artist))
        (try! (stx-transfer? u2150000 contract-caller gated))

        ;; Mint all tracks in the album
        (try! (nft-mint? radio-silence (+ track-1-id u1) recipient))

        ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-1-id (+ track-1-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID


        (try! (nft-mint? you-make-it-alright (+ track-2-id u1) recipient))

        ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-2-id (+ track-2-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Incr

        (try! (nft-mint? mortals (+ track-3-id u1) recipient))

             ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-3-id (+ track-3-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Incr

        (try! (nft-mint? buzzhead (+ track-4-id u1) recipient))

         ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-4-id (+ track-4-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1)) 
            
                ;; Incr
        (try! (nft-mint? grey (+ track-5-id u1) recipient))

         ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-5-id (+ track-5-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Incr

        (try! (nft-mint? exile (+ track-6-id u1) recipient))

         ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-6-id (+ track-6-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Incr

        (try! (nft-mint? i-shouldnt-break (+ track-7-id u1) recipient))

         ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-7-id (+ track-7-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1)) 
            
                ;; Incr
        (try! (nft-mint? bbq-to-braai (+ track-8-id u1) recipient))

         ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-8-id (+ track-8-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Incr

        
        ;; Increment album token ID
        (var-set album-token-id (+ (var-get album-token-id) u1))

        (ok true)
    )
)
)

;; Mint function for Track 1 (Radio Silence: tokens 1-99)
(define-public (mint-track-1 (recipient principal))
    (begin
        ;; Get the current token ID for Track 1
        (let (
            (track-1-id (var-get last-token-track-1-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 1 supply limit is reached (tokens 1-99)
            (asserts! (<= track-1-id u99) (err ERR-SUPPLY-LIMIT-REACHED))
            
            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-1-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-1-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? radio-silence (+ track-1-id u1) recipient))
            
            ;; Update Track 1 token ID and Global Token ID
            (var-set last-token-track-1-id (+ track-1-id u1))  ;; Increment Track 1 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)
;; Mint function for Track 2 (You Make it Alright: tokens 100-200)
(define-public (mint-track-2 (recipient principal))
    (begin
        ;; Get the current token ID for Track 2
        (let (
            (track-2-id (var-get last-token-track-2-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 2 supply limit is reached (tokens 100-200)
            (asserts! (<= track-2-id u199) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-2-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-2-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? you-make-it-alright (+ track-2-id u1) recipient))

            ;; Update Track 2 token ID and Global Token ID
            (var-set last-token-track-2-id (+ track-2-id u1))  ;; Increment Track 2 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 3
(define-public (mint-track-3 (recipient principal))
    (begin
        ;; Get the current token ID for Track 3
        (let (
            (track-3-id (var-get last-token-track-3-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 2 supply limit is reached (tokens 100-200)
            (asserts! (<= track-3-id u299) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-3-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-3-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? mortals (+ track-3-id u1) recipient))

            ;; Update Track 2 token ID and Global Token ID
            (var-set last-token-track-3-id (+ track-3-id u1))  ;; Increment Track 2 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 4
(define-public (mint-track-4 (recipient principal))
    (begin
        ;; Get the current token ID for Track 4
        (let (
            (track-4-id (var-get last-token-track-4-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 4 supply limit is reached (tokens 100-200)
            (asserts! (<= track-4-id u399) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-4-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-4-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? buzzhead (+ track-4-id u1) recipient))

            ;; Update Track 2 token ID and Global Token ID
            (var-set last-token-track-4-id (+ track-4-id u1))  ;; Increment Track 2 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 5 
(define-public (mint-track-5 (recipient principal))
    (begin
        ;; Get the current token ID for Track 5
        (let (
            (track-5-id (var-get last-token-track-5-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 5 supply limit is reached (tokens 100-200)
            (asserts! (<= track-5-id u499) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-5-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-5-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? grey (+ track-5-id u1) recipient))

            ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-5-id (+ track-5-id u1))  ;; Increment Track 2 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 6 
(define-public (mint-track-6 (recipient principal))
    (begin
        ;; Get the current token ID for Track 6
        (let (
            (track-6-id (var-get last-token-track-6-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 6 supply limit is reached (tokens 100-200)
            (asserts! (<= track-6-id u599) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-6-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-6-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? exile (+ track-6-id u1) recipient))

            ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-6-id (+ track-6-id u1))  ;; Increment Track 6 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 7
(define-public (mint-track-7 (recipient principal))
    (begin
        ;; Get the current token ID for Track 7
        (let (
            (track-7-id (var-get last-token-track-7-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 7 supply limit is reached (tokens 100-200)
            (asserts! (<= track-7-id u699) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-7-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-7-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? i-shouldnt-break (+ track-7-id u1) recipient))

            ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-7-id (+ track-7-id u1))  ;; Increment Track 7 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; Mint function for Track 8 
(define-public (mint-track-8 (recipient principal))
    (begin
        ;; Get the current token ID for Track 8
        (let (
            (track-8-id (var-get last-token-track-8-id)) ;; Track-specific token ID
            (global-token-id (var-get last-token-id))    ;; Global incremental token ID
        )
            ;; Check if Track 8 supply limit is reached (tokens 100-200)
            (asserts! (<= track-8-id u799) (err ERR-SUPPLY-LIMIT-REACHED))

            ;; Process all required payments
            (try! (stx-transfer? album-artist-fee contract-caller album-artist))
            (try! (stx-transfer? artist-fee contract-caller track-8-contributor-1))
            (try! (stx-transfer? musician-fee contract-caller track-8-contributor-2))
            (try! (stx-transfer? provider-fee contract-caller provider))
            (try! (stx-transfer? gated-fee contract-caller gated))

            ;; Mint the token for the recipient
            (try! (nft-mint? bbq-to-braai (+ track-8-id u1) recipient))

            ;; Update Track r token ID and Global Token ID
            (var-set last-token-track-8-id (+ track-8-id u1))  ;; Increment Track 8 token ID
            (var-set last-token-id (+ global-token-id u1))     ;; Increment Global Token ID

            ;; Return the minted token ID (global token ID)
            (ok (+ global-token-id u1))
        )
    )
)

;; (use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)
(define-map token-count principal uint)
(define-map market uint {price: uint}
)

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint))
    (let ((listing  {price: price}))
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

;; Buy function for multiple tracks
(define-public (buy-in-ustx (id uint))
  (let (
    (owner-response (try! (get-owner id)))
    (owner (unwrap! owner-response (err ERR-NOT-FOUND)))
    (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
    (price (get price listing))
  )
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? price tx-sender owner))
    
    ;; Pay commission
    
    ;; Transfer NFT using the multi-track transfer function
    (try! (transfer id owner tx-sender))
    
    ;; Remove listing from marketplace
    (map-delete market id)
    
    ;; Print transaction details
    (print {event: "buy-in-ustx", token-id: id})
    (ok true)
  )
)

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
```
