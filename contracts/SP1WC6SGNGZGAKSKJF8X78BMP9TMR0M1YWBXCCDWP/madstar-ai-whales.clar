(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

(define-non-fungible-token hback-ai-whales-nft uint)

;; Storage
(define-map minted principal bool)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-SOLD-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-MINT-ALREADY-SET (err u506))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-ONE-MINT-PER-WALLET (err u508))
(define-constant ERR-BEFORE-MINT-TIME (err u509))
(define-constant ERR-AFTER-MINT-TIME (err u510))
(define-constant STX-MINT-LIMIT u2500)


;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 100) "ipfs://bafybeif2llfphqftoirm2m4cfhjnh5otrhqcj4txe5bn6xatmuentazyra/{id}")
(define-data-var contract-uri (string-ascii 100) "ipfs://bafybeiag6oytrsh54xn56etxaarmngbqztff6axvgkmf55uhqoqq23rdlm")
(define-data-var artist-address principal 'SP1KQF7QTM3A2H205T0VZMPPHH3SVVKT5BX7MPMK)


;; Get minted
(define-read-only (get-minted (account principal))
  (default-to false
    (map-get? minted account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (nft-transfer? hback-ai-whales-nft id sender recipient))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace hback-ai-whales-nft
  (ok (nft-get-owner? hback-ai-whales-nft id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some (var-get base-uri))))


(define-read-only (get-contract-uri)
  (ok (var-get contract-uri)))

;; Mint new NFT
;; can only be called from the Mint

(define-private (admin-mint (new-owner principal))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
      (unwrap-panic (nft-mint? hback-ai-whales-nft (var-get last-id) new-owner))
      (var-set last-id next-id)))

(define-public (burn (id uint) (owner principal))
    (let (
        (token-owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-AUTHORIZED)
    (nft-burn? hback-ai-whales-nft id owner))
    
)

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? hback-ai-whales-nft id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? hback-ai-whales-nft id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))

;; Set contract uri
(define-public (set-contract-uri (new-contract-uri (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set contract-uri new-contract-uri)
    (ok true))
)

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set artist-address address)
    (ok true)))

(admin-mint 'SP3STPCADGPT3B5HB2NFSATYCTCTZV012J564C5KX)
(admin-mint 'SP17NZ4FXJAKJYM3976YT216ZTJVMJ6XACRB089XH)
(admin-mint 'SP1MMDR6PM6X7FVS5C2BXBE7NQG9NMEMYYEHVY0YA)
(admin-mint 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC)
(admin-mint 'SP2ZWP1808CN0SW7J2JEEMBQRGMJDBCNCC1PTTKS4)
(admin-mint 'SP19KPWZDPBD13N07C7Q1BENQMEPRTNA6J6ACBJB3)
(admin-mint 'SP3S38CQAYN78V9BTWYT1CNP8MWDFP8EPH6K0JJ4V)
(admin-mint 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(admin-mint 'SP2MA0FYKVBX85EHSGC0PF6AEWH5VF062GRTS68R5)
(admin-mint 'SP223QGRP81XNHPJKCYNR3X3QWF3ZG799TZ9PYXFS)
(admin-mint 'SP2WFY0H48AS2VYPA7N69V2VJ8VKS8FSPQSPJDSDN)
(admin-mint 'SP1QB7R583ESMCVADS6AM6DFXHGBEBPV608GK7A02)
(admin-mint 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(admin-mint 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D)
(admin-mint 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR)
(admin-mint 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP)
(admin-mint 'SP2WFY0H48AS2VYPA7N69V2VJ8VKS8FSPQSPJDSDN)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM)
(admin-mint 'SP31PS877Y1B78QR7NQ1BCHS7EG0798WC52ZY6MD9)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR)
(admin-mint 'SP2ZGVSV6JDJ6SCGJETE3ZT0PNRSB90FM01P830D4)
(admin-mint 'SP2HK7F30KWK8JRPEJXKHGP5QMWGMZTZX5SM570QS)
(admin-mint 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E)
(admin-mint 'SP1XHX4584AM7KARG7MTVBW6CN8JQ8Q97DMFZJ8W)
(admin-mint 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(admin-mint 'SP129SXC2YE4VM9ZXWXF1WSRT8M5BGAEZ0PQK685D)
(admin-mint 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP)
(admin-mint 'SP33G7CYV2ACDVKEK3HV5Q2M1EPJ4T2111HBVMD1T)
(admin-mint 'SP2H15M15GTJJR4BWKP948JEYSS8G7H599E11GHA6)
(admin-mint 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ)
(admin-mint 'SP753S60EYM69SSS9Y6CPK0PPQ465F647NSK3AX1)
(admin-mint 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ)
(admin-mint 'SP1WBHQBHA13RFWKEV0H75Z7XEJVK5HXGDEYB6AMH)
(admin-mint 'SP2ZD78CEHCFPJ71SB8R0EK0ZMVAGB3NTHK947F06)
(admin-mint 'SP3X5Y7T0NCV50C7K9HYJTQAR6WRZQT0YXQ0BSW2M)
(admin-mint 'SP3QD9EVZB3E7E7Z3FWH7KBDH5RZWA4PYHSQ0FGTQ)
(admin-mint 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY)
(admin-mint 'SP30GG9WTXAQKSBQF331HHYRFNPAW1GD74EHDH9Q3)
(admin-mint 'SP350N4SX832092H6F07YKB1R5X5DM90BV6P97B8N)
(admin-mint 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G)
(admin-mint 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ)
(admin-mint 'SPVM12QZD5GG98SAZQAWJVB0AZRF8QK86WHPTKR2)
(admin-mint 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG)
(admin-mint 'SP3Q1VW36FD1HF4J0EFRF2E486QGYNYJASB9PKDKF)
(admin-mint 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106)
(admin-mint 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM)
(admin-mint 'SP213BHFYJ54M0R7C84MHN04JYJYE4V363XRHXKHD)
(admin-mint 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV)
(admin-mint 'SPM77RGCZF9QQZWNTRQG0C5QCV588KYKTQGVD4Y)
(admin-mint 'SPZH8SKGW4Y87PMV00AC0A5QCZSQ83GSHECB876E)
(admin-mint 'SP18KN2HDVMD2J7VDYPGGPFDWJFRKPQ7N1CN6VXXC)
(admin-mint 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6)
(admin-mint 'SP1K08A70Q94CX7ATGKSFCB5DZARK30868FEHT2RG)
(admin-mint 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0)
(admin-mint 'SP3B8W1S6YE0Y46VSSF1MFEVCATPN9HHQ9VPVSBD8)
(admin-mint 'SP37PM1Q3VY6KFKCNMB1WMK1W7D0CH1WZMKJVRRSD)
(admin-mint 'SP3M16X85R7ED2RR70ANNB3X0HXPHGSAXBEGGZKK0)
(admin-mint 'SP3STPCADGPT3B5HB2NFSATYCTCTZV012J564C5KX)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(admin-mint 'SP7VCY0S1WZF3XDGSMPQ67SDQQ4DCW1DWBR29G19)
(admin-mint 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6)
(admin-mint 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69)
(admin-mint 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8)
(admin-mint 'SP2F79WM0KA67R3KNBHJCP9A27EV9DAVSP4TGZV5Y)
(admin-mint 'SP2F79WM0KA67R3KNBHJCP9A27EV9DAVSP4TGZV5Y)
(admin-mint 'SPGTN4T2DP2PQHYNYA3H4P7J8S1J6E5DK202F2C8)
(admin-mint 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB)
(admin-mint 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3)
(admin-mint 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D)
(admin-mint 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SP2M5YGRBM1WD9PNFCS0SX2S15PAVEGN9B8VAAR0J)
(admin-mint 'SP3A6SRWC0295MPY00805CZBWSF1TAY8DWMR05XFM)
(admin-mint 'SP30H7S10NK42C2AYJXV6RDVE4AM93BJMEBXD3GHF)
(admin-mint 'SP2WFY0H48AS2VYPA7N69V2VJ8VKS8FSPQSPJDSDN)
(admin-mint 'SP33G7CYV2ACDVKEK3HV5Q2M1EPJ4T2111HBVMD1T)
(admin-mint 'SP129SXC2YE4VM9ZXWXF1WSRT8M5BGAEZ0PQK685D)
(admin-mint 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8)
(admin-mint 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP)
(admin-mint 'SP3S38CQAYN78V9BTWYT1CNP8MWDFP8EPH6K0JJ4V)
(admin-mint 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ)
(admin-mint 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD)
(admin-mint 'SPVM12QZD5GG98SAZQAWJVB0AZRF8QK86WHPTKR2)
(admin-mint 'SP213BHFYJ54M0R7C84MHN04JYJYE4V363XRHXKHD)
(admin-mint 'SP1G7B9MKFAX1E09HJSTRBSBBTJ9ZTDW9921X5JZV)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0)
(admin-mint 'SP30GG9WTXAQKSBQF331HHYRFNPAW1GD74EHDH9Q3)
(admin-mint 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM)
(admin-mint 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(admin-mint 'SP19KPWZDPBD13N07C7Q1BENQMEPRTNA6J6ACBJB3)
(admin-mint 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC)
(admin-mint 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6)
(admin-mint 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D)
(admin-mint 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV)
(admin-mint 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY)
(admin-mint 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(admin-mint 'SP30GG9WTXAQKSBQF331HHYRFNPAW1GD74EHDH9Q3)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
(admin-mint 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN)
(admin-mint 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE)
