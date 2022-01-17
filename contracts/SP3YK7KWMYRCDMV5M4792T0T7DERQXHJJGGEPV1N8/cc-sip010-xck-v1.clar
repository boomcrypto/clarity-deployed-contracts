;; cc-sip010-xck-v1
;; CrossCheck Token (XCK)
;; we implement the sip-010
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;;constants
(define-constant ERR_INSUFFICIENT_FUNDS u101)
(define-constant ERR_PERMISSION_DENIED u109)

;; set constant for contract owner, used for updating token-uri
(define-constant LOCAL-CONTRACT-OWNER tx-sender)
;; check if contract caller is local contract owner

(define-private (is-local-authorized-owner)
  (is-eq contract-caller LOCAL-CONTRACT-OWNER)
)

;; create the fungible token and max availability expected
(define-fungible-token crosscheck u19000000000000)

;; define initial token URI
(define-data-var tokenUri (optional (string-utf8 256)) (some u"https://paradigma.global/metadata/crosscheck.json"))

;; set token URI to new value, only accessible by CONTRACT-OWNER
(define-public (set-token-uri (newUri (optional (string-utf8 256))))
    (begin
        (asserts! (is-local-authorized-owner) (err ERR_PERMISSION_DENIED))
        (ok (var-set tokenUri newUri))
    )
)

;; SIP-010 functions
;;
;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance crosscheck owner))
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6)  
)

(define-read-only (get-token-uri)
  (ok (var-get  tokenUri))
)

;; returns the token name
(define-read-only (get-name)
  (ok "CrossCheck")
)

(define-read-only (get-symbol)
  (ok "XCK")
)

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply crosscheck))
)

;; (transfer (uint principal principal) (response bool uint))
;; amount sender recipient
;; Transfers tokens to a recipient

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (>= (ft-get-balance crosscheck sender) amount)
     (begin
       (asserts! (is-eq tx-sender sender) (err ERR_PERMISSION_DENIED))
       (if (is-some memo)
           (print memo)
           none
       )
       (try! (ft-transfer? crosscheck amount sender recipient))
       (ok true)
      )
      (err ERR_INSUFFICIENT_FUNDS)
   )
)

;; additional to the SIP010 fox XCK

;; all the data relevant to the xck token
(define-read-only (get-data (owner principal))
  (ok {
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals)),
    uri: (unwrap-panic (get-token-uri)),
    supply: (unwrap-panic (get-total-supply)),
    balance: (unwrap-panic (get-balance owner))
  })
)

;; we implement additional functionalities for XCK
(impl-trait 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-token-trait-v1.paradigma-token-trait)

;; Token flow management
;; the extra mint and burn method used
;; can only be authtorized by the distributed data control
(define-public (mint (amount uint) (recipient principal))
    (begin
       ;; veryfing in distributed data control
      (asserts! (contract-call? 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-ddc-v1 is-remote-caller-authorized-to-execute contract-caller) (err ERR_PERMISSION_DENIED))
      (ft-mint? crosscheck amount recipient)
    )
)

(define-public (burn (amount uint) (recipient principal))
    (begin
      ;; veryfing in distributed data control
      (asserts! (contract-call? 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-ddc-v1 is-remote-caller-authorized-to-execute contract-caller) (err ERR_PERMISSION_DENIED))
      (ft-burn? crosscheck amount recipient)
    )
)