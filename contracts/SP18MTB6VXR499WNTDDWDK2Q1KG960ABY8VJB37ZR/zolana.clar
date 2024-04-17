;; This is an absolute experiment of a token.
;; do not take anything here seriously, it is suppose to be a joke
;; please do not invest on this token, it is just for fun
;; there some unusual mechanics here that may block your wallet from using the token
;; there are also some functions to mint the token using different methods, use them at your own risk
;; sometimes the token may be offline
;; sometimes the token may be censored
;; sometimes the token may be back online

(impl-trait .traits.ft-trait)


(define-constant ERR_NOT_MINTER (err u200))
(define-constant ERR_AMOUNT_ZERO (err u201))
(define-constant ERR_ZOLANA_OFFLINE (err u202))
(define-constant ERR_NOT_TOKEN_OWNER (err u203))
(define-constant ERR_USER_NOT_AUTHORISED (err u204))

(define-constant receiver_address_mint 'SP18MTB6VXR499WNTDDWDK2Q1KG960ABY8VJB37ZR) ;;central wallet
(define-constant receiver_address_switch 'SP18MTB6VXR499WNTDDWDK2Q1KG960ABY8VJB37ZR) ;;degen wallet

(define-constant price_on u100000000) ;; 100 ROOs -> burn
(define-constant price_off u1000000000) ;; 100 ROOs -> burn
(define-constant price_censor u1000000000) ;; 1k ROOs -> airdrop
(define-constant price_remove_censor u1000000000) ;; 100 ROOs -> airdrop
;; censor -> for certain amount of time
(define-constant price_mint_1k_w u1000000000) ;; $0.00632 - 1k Welsh
(define-constant price_mint_1k_l u5000000000) ;; $0.00156 - 5k Leo
(define-constant price_mint_1k_n u50000000000000000) ;; $0.000000000906 5(8)k nothing


(define-data-var on_off_switch bool true)
(define-data-var TOKEN_URI (optional (string-utf8 256)) none)

(define-map authorised_users principal bool)


(define-fungible-token zolana  u5722900000000000 )

(define-read-only (get-name)
  (ok "Zolana")
)

(define-read-only (get-symbol)
  (ok "ZOL")
)

(define-read-only (get-decimals) 
  (ok u6)
)

(define-read-only (get-network-online) 
  (ok (var-get on_off_switch))
)

(define-read-only (get-balance (user principal))
  (begin
    (asserts! (is-eq (var-get on_off_switch) true) ERR_ZOLANA_OFFLINE)
    (ok (ft-get-balance zolana user))
  )
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply zolana))
)

(define-read-only (get-token-uri)
  (ok (var-get TOKEN_URI))
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if
    (is-eq tx-sender receiver_address_mint)
    ;; #[allow(unchecked_data)]
    (ok (var-set TOKEN_URI (some value)))
    (err ERR_NOT_MINTER)
  )
)


(define-public (transfer (amount uint) (sender principal) (receiver principal) (memo (optional (buff 34)))) 
    (begin
        (asserts! (is-eq (var-get on_off_switch) true) ERR_ZOLANA_OFFLINE)
        (asserts! (is-eq (default-to false (map-get? authorised_users sender)) true) ERR_USER_NOT_AUTHORISED)
        (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    ;; #[allow(unchecked_data)]
        (try! (ft-transfer? zolana amount sender receiver))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)


(define-public (mint (amount uint))
  (begin
    (asserts! (is-eq tx-sender receiver_address_mint) ERR_NOT_MINTER)
    (asserts! (> amount u0) ERR_AMOUNT_ZERO)
    (ft-mint? zolana amount receiver_address_mint)
  )
)

(define-public (burn (amount uint))
  (begin
    (asserts! (is-eq (var-get on_off_switch) true) ERR_ZOLANA_OFFLINE)
    (ft-burn? zolana amount tx-sender)
  )
)

;; Function to set Zolana on
(define-public (zolana_on)
  (begin
    (try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer price_on tx-sender receiver_address_switch none))
    (var-set on_off_switch true)
    (ok "zolana back up again")
  )
)
;; Function to set Zolana off
(define-public (zolana_off)
  (begin
    (try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer price_off tx-sender receiver_address_switch none))
    (var-set on_off_switch false)
    (ok "zolana down. ")
  )
)

;; function to mint using Welsh
(define-public (mint_welsh_1000)
  (begin
    (try! (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer price_mint_1k_w tx-sender receiver_address_mint none))
    (try! (ft-mint? zolana u1000000000 tx-sender ))
    (ok "minted using Welsh")
  )
)
;; function to mint using Leo
(define-public (mint_leo_1000)
  (begin
    (try! (contract-call? 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token transfer price_mint_1k_l tx-sender receiver_address_mint none))
    (try! (ft-mint? zolana u1000000000 tx-sender ))
    (ok "minted using Leo")
  )
)
;; function to mint using Nothing
(define-public (mint_nothing_1000)
  (begin
    (try! (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope transfer price_mint_1k_n tx-sender receiver_address_mint none))
    (try! (ft-mint? zolana u1000000000 tx-sender ))
    (ok "minted using Nothing")
  )
)

;; function to black list user
(define-public (censor_user (user principal))
  (begin
     (try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer price_censor tx-sender receiver_address_switch none))
    ;; #[allow(unchecked_data)]
    (map-set authorised_users user false)
    (ok "user blocked")
  )
)
;; function to add user to authorised list
(define-public (authorised_user (user principal))
  (begin
    ;; try attempts to unwrap the value of stx-transfer (either OK or ERR), if successful it will extract that value that return it, otherwise it will exit the function
     (try! (contract-call? 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo transfer price_censor tx-sender receiver_address_switch none))
    ;; #[allow(unchecked_data)]
    (map-set authorised_users user true)
    (ok "user authorised")
  )
)

(define-public (authorised_user_mint (user principal))
  (begin
    (asserts! (is-eq tx-sender receiver_address_mint) ERR_NOT_MINTER)
    ;; #[allow(unchecked_data)]
    (map-set authorised_users user true)
    (ok "user authorised")
  )
)
