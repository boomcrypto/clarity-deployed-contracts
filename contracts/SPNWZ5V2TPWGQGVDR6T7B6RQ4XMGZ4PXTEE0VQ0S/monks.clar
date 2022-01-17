;; pox monks
;; nativenfts.btc

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token pox-monks uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)

(define-constant total-price u25000000)
(define-constant mint-limit u224)
(define-constant commission-address tx-sender)

;; Internal variables
(define-data-var last-id uint u0)
(define-data-var commission uint u500)
(define-data-var artist-address principal 'SP11HD7QYN65VPZVRS1MM710ZHMKSFZDHVP1XZHW6)

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))  
        (count (var-get last-id)))
      (asserts! (< count mint-limit) (err err-no-more-nfts))
    (let
      ((total-commission (/ (* total-price (var-get commission)) u10000))
       (total-artist (- total-price total-commission)))
      (if (is-eq tx-sender (var-get artist-address))
        (mint-helper new-owner next-id)
        (if (is-eq tx-sender commission-address)
          (begin
            (mint-helper new-owner next-id))
          (begin
            (try! (stx-transfer? total-commission tx-sender commission-address))
            (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
            (mint-helper new-owner next-id))))
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? pox-monks next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set artist-address address)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? pox-monks token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? pox-monks token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat "ipfs://ipfs/QmXn4ku8bEhZ7X2BoZX1nkdVUFNY7C27ULMkVjm8QkAX1k/" (unwrap-panic (lookup token-id))) ".json"))))

(define-constant LOOKUPS (list
    "0" "36" "193" "23" "189" "115" "99" "172" "4" "210" "220" "143" "162" "121" "25" "41" "187" "103" "123" "13" "223" "169" "62" "80" "139" "160" "108" "120" "149" "78" "7" "163" "142" "96" "146" "128" "105" "54" "155" "102" "91" "10" "66" "157" "152" "207" "87" "181" "141" "51" "133" "176" "114" "110" "168" "179" "24" "129" "69" "19" "186" "29" "217" "9" "158" "196" "204" "101" "57" "100" "211" "79" "1" "161" "86" "167" "6" "134" "68" "164" "46" "47" "177" "93" "22" "8" "67" "195" "218" "171" "27" "118" "90" "183" "56" "138" "219" "147" "94" "112" "85" "53" "58" "72" "84" "30" "151" "125" "2" "34" "70" "124" "213" "208" "159" "132" "50" "20" "201" "81" "166" "17" "82" "127" "117" "21" "165" "28" "39" "173" "11" "190" "126" "122" "153" "221" "194" "145" "106" "65" "18" "95" "180" "97" "3" "199" "206" "200" "154" "75" "40" "170" "73" "182" "191" "214" "37" "33" "185" "215" "148" "98" "144" "135" "44" "48" "35" "64" "107" "89" "15" "224" "49" "59" "92" "38" "174" "198" "26" "32" "74" "77" "222" "55" "60" "209" "212" "140" "109" "113" "188" "5" "178" "43" "175" "119" "205" "12" "111" "131" "216" "150" "156" "42" "116" "136" "137" "88" "31" "192" "197" "61" "71" "14" "76" "45" "63" "16" "52" "184" "83" "202" "104" "203" "130"
))

(define-private (lookup (uid uint))
    (ok (unwrap-panic (element-at LOOKUPS uid)))
)

