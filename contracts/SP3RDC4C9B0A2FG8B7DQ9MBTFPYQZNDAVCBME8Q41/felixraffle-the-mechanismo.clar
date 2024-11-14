;; felix-raffle-the-mechanismo
;; v1
;; Learn more at https://felixapp.xyz/
;; ---
;;
(define-constant felix 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41)
(define-constant draw-block (+ block-height u9))
(define-constant entries (list "roynmgn" "notolisa88" "kudzayi47119508" "rhnstnnpocket" "binxbtc" "emanuhellooo" "cnwhales" "stxog" "keishasatoshi" "stacksguardian" "johansenbtc" "cumsbtc" "xbitcoinchinese" "bitcoinxstacks" "xdomainhunter" "fransiscakhe" "whatepakk" "kucoincat" "dreamchaserzw" "wenyuwevhu" "andrew62736518" "diamondjnr" "sirdreadlife" "krisxsn" "bamberfishcake" "nwigs" "demigodike" "luffyh2" "stacktisticbtc" "zackstripes" "hantieyhucee" "dulb26" "teteneko1" "dudebigger35125" "fortunateone" "kingeng0366343" "0xblesstheyhute" "aslkere97206981" "odinator913" "wenjin1688" "quetzalbtc" "aphillyatd420" "scribbloor" "malvinaani31859" "karlinapande" "iamdavidleo" "chuy12121979" "kolking55100" "trakasbtc" "xjimmymoonx"))

(define-data-var winner (optional (string-ascii 40)) none)

(define-constant err-not-at-draw-block (err u400))
(define-constant err-standard-principal-only (err u401))
(define-constant err-unable-to-get-random-seed (err u500))
(define-constant err-winner-already-picked (err u501))

(define-private (is-standard-principal-call)
    (is-none (get name (unwrap! (principal-destruct? contract-caller) false))))

(define-read-only (get-entries)
    entries)

(define-read-only (get-winner)
    (var-get winner))


(define-public (pick-winner)
    (begin 
        (asserts! (is-standard-principal-call) err-standard-principal-only)
        (asserts! (is-none (var-get winner)) err-winner-already-picked)
        (asserts! (> block-height draw-block) err-not-at-draw-block)
        (let
            ((random-number (unwrap! (contract-call? 'SP3RDC4C9B0A2FG8B7DQ9MBTFPYQZNDAVCBME8Q41.felix-meta-v3 get-rnd draw-block) err-unable-to-get-random-seed))
            (winner-index (mod random-number (len entries)))
            (chosen-winner (element-at? entries winner-index)))
        (var-set winner chosen-winner)
        (ok chosen-winner))))
