;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;
(define-constant ADMIN 'SP1GMKTXAKNTS7MKF5QN5HYCKPM3EHDD0E5CCWZC)
(define-constant ADMIN-2 'SP3JGY7WRXWR7AKAPADC1Q7V5PQ1B9EFZHT3MSFMF)
(define-constant ERR-REFUND-NOT-ACTIVE (err u0))
(define-constant ERR-ARTIES-ID-NOT-ELIGIBLE (err u1))
(define-constant ERR-ARTIES-WALLET-NOT-ELIGIBLE (err u2))
(define-constant ERR-GET-OWNER-FAILED (err u3))
(define-constant ERR-STX-TRANSFER (err u4))
(define-constant ERR-NOT-AUTH (err u5))
(define-constant ERR-ALREADY-AIRDROPPED (err u6))
(define-constant ERR-UNWRAPPING-HELPER-IDS (err u7))
(define-constant ERR-UNWRAPPING-HELPER-WALLETS (err u8))
(define-constant ERR-LISTS-NOT-EQUAL (err u9))


;;;;;;;;;;;;;;;;;
;; Vars & Maps ;;
;;;;;;;;;;;;;;;;;
(define-data-var is-refund-active bool false)
(define-data-var can-airdrop bool true)
(define-data-var end-height uint u0)
(define-data-var map-helper-ids (list 100 uint) (list ))
(define-data-var map-helper-wallets (list 100 principal) (list ))
(define-map eligible-arties uint
  {
    eligible: bool,
    wallet: principal
  }
)

(define-constant list-helper (list
    u0	u1	u2	u3	u4	u5	u6	u7	u8	u9
    u10	u11	u12	u13	u14	u15	u16	u17	u18	u19
    u20	u21	u22	u23	u24	u25	u26	u27	u28	u29
    u30	u31	u32	u33	u34	u35	u36	u37	u38	u39
    u40	u41	u42	u43	u44	u45	u46	u47	u48	u49
    u50	u51	u52	u53	u54	u55	u56	u57	u58	u59
    u60	u61	u62	u63	u64	u65	u66	u67	u68	u69
    u70	u71	u72	u73	u74	u75	u76	u77	u78	u79
    u80	u81	u82	u83	u84	u85	u86	u87	u88	u89
    u90	u91	u92	u93	u94	u95	u96	u97	u98	u99
))

;;;;;;;;;;
;; Core ;;
;;;;;;;;;;
(define-public (refund (artieID uint))
  (let
    (
      (eligible-artie (default-to {eligible: false, wallet: 'SP000000000000000000002Q6VF78} (map-get? eligible-arties artieID)))
      (eligible-status (get eligible eligible-artie))
      (eligible-wallet (get wallet eligible-artie))
    )
    (asserts! (and (var-get is-refund-active) (< block-height (var-get end-height))) ERR-REFUND-NOT-ACTIVE)
    (asserts! eligible-status ERR-ARTIES-ID-NOT-ELIGIBLE)
    (asserts! (is-eq tx-sender eligible-wallet) ERR-ARTIES-WALLET-NOT-ELIGIBLE)

    ;; need to assert get-owner to check that this tx-sender is owner of Artie in question
    (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties get-owner artieID)))) ERR-GET-OWNER-FAILED)

    ;; transfer Artie from tx-sender to burn address
    (unwrap-panic (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.arties transfer artieID tx-sender 'SP000000000000000000002Q6VF78))
    (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) eligible-wallet)) ERR-STX-TRANSFER)
    (ok (map-set eligible-arties artieID {eligible: false, wallet: eligible-wallet}))
  )
)

(define-public (refund-two (artieID1 uint) (artieID2 uint))
    (begin
        (try! (refund artieID1))
        (ok (refund artieID2))
    )
)

(define-public (refund-five (artieID1 uint) (artieID2 uint) (artieID3 uint) (artieID4 uint) (artieID5 uint))
    (begin
        (try! (refund artieID1))
        (try! (refund artieID2))
        (try! (refund artieID3))
        (try! (refund artieID4))
        (ok (refund artieID5))
    )
)


(define-read-only (map-viewer (id uint)) 
    (map-get? eligible-arties id)
)

;;;;;;;;;;;;;;;;;;;;;
;; Admin Functions ;;
;;;;;;;;;;;;;;;;;;;;;

(define-public (admin-load-wallet (stx-amount uint))
  (begin
    (asserts! (or (is-eq tx-sender ADMIN) (is-eq tx-sender ADMIN-2)) ERR-NOT-AUTH)
    (ok (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender))))
  )
)

(define-public (admin-return-wallet (stx-amount uint))
  (begin
    (asserts! (or (is-eq tx-sender ADMIN) (is-eq tx-sender ADMIN-2)) ERR-NOT-AUTH)
    (as-contract (stx-transfer? stx-amount (as-contract tx-sender) ADMIN))
  )
)

(define-public (admin-start-refund)
  (begin
    (asserts! (or (is-eq tx-sender ADMIN) (is-eq tx-sender ADMIN-2)) ERR-NOT-AUTH)
    (var-set end-height (+ block-height u288))
    (ok (var-set is-refund-active true))
  )
)


(define-public (admin-one-time-airdrop) 
    (begin
        (asserts! (var-get can-airdrop) ERR-ALREADY-AIRDROPPED)
        (asserts! (or (is-eq tx-sender ADMIN) (is-eq tx-sender ADMIN-2)) ERR-NOT-AUTH)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP1M83JETM6QSMCASE9QZT091BMWSMVXCWB3B9TX8)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP2TG45EFWYJ56JE69ESKAWVFCQT42V26ZWSSEES8)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP2JJEZSCH9P3MMEHWASFVRH8MTEQ8G1PDGV1EVWC)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP1HB2E1C01ED4S90W18FWVJAN9YV9PSCBPASYR6S)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP295M8F7S9BR7J2PBE88AKFTVZ267A85VGT2PS2N)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP2713FNJHHMCMC5WH7FDKB03RQ1ZE2BW7S2K73C4)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP3JWJQ0107Q40NXXRJQ12P8NCH98TFK3D9YRNGVF)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP2JJEZSCH9P3MMEHWASFVRH8MTEQ8G1PDGV1EVWC)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP27HKJ9R0V7NSKZMNQHHDGDF5CNMR5QFABKX2452)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP19A7XF0X59CBP5RGGQP2421RJ5VYPGNDKPEMG6P)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP3QQNWFBT63BRDPWB7WJ960XRFZ6JJ5R3RCA3NZJ)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u98000000 (as-contract tx-sender) 'SP32BMP0GJ00A4KWHRDVK1NC211JKAAD7WF0JV5DB)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP1805P5CP8AXPJNVGX460QSGEST61QZ8A078AJMP)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SPCY4QYSTWB22V5YMT5MHHQNSGXTCNX374TK0DJV)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SP1XCS71D6KCKV757JK2XTFFKB4GDMC25Y6S9G3GM)) ERR-STX-TRANSFER)
        (unwrap! (as-contract (stx-transfer? u49000000 (as-contract tx-sender) 'SPSNJ51W9564R21FJ2SKVAMPT86YR3AJ9MQVXHTY)) ERR-STX-TRANSFER)
        (ok (var-set can-airdrop false))
    )
)

(define-public (admin-set-eligible (IDs (list 100 uint)) (wallets (list 100 principal))) 
    (begin 
        ;; assert is-admin or is-admin-2 
        (asserts! (or (is-eq tx-sender ADMIN) (is-eq tx-sender ADMIN-2)) ERR-NOT-AUTH)
        ;; assert length of lists are the same
        (asserts! (is-eq (len IDs) (len wallets)) ERR-LISTS-NOT-EQUAL)
        ;; temporary change helper id list to param list
        (var-set map-helper-ids IDs)
        ;; temporary change helper wallet list to param list
        (var-set map-helper-wallets wallets)
        (ok (map map-maker-helper list-helper))
    )
)

(define-private (map-maker-helper (counter uint)) 
    (ok (map-set eligible-arties (unwrap! (element-at (var-get map-helper-ids) counter) ERR-UNWRAPPING-HELPER-IDS) 
        {
            eligible: true,
            wallet: (unwrap! (element-at (var-get map-helper-wallets) counter) ERR-UNWRAPPING-HELPER-WALLETS)
        }
    ))
)