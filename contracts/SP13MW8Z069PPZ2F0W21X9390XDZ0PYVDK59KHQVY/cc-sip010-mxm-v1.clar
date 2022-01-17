;; cc-sip010-mxm-v1
;; Mixmi Token (MXM)
;; we implement the sip-010
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;;constants
(define-constant ERR_INSUFFICIENT_FUNDS u101)
(define-constant ERR_PERMISSION_DENIED u109)

;; set constant for contract owner, used for updating token-uri
(define-constant LOCAL-CONTRACT-OWNER tx-sender)

;; check if contract caller is contract owner
(define-private (is-authorized-owner)
  (is-eq contract-caller LOCAL-CONTRACT-OWNER)
)

;; create the fungible token and max availability expected
(define-fungible-token mixmi u19000000000000)

;; define initial token URI
(define-data-var tokenUri (optional (string-utf8 256)) (some u"https://mixmi.app/metadata/mixmi.json"))

;; set token URI to new value, only accessible by CONTRACT-OWNER
(define-public (set-token-uri (newUri (optional (string-utf8 256))))
    (begin
        (asserts! (is-eq tx-sender LOCAL-CONTRACT-OWNER) (err ERR_PERMISSION_DENIED))
        (ok (var-set tokenUri newUri))
    )
)

;; SIP-010 functions

;;
;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance mixmi owner))
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6)  ;; because we can, and interesting for testing wallets and other clients
)

(define-read-only (get-token-uri)
  (ok (var-get  tokenUri))
)

;; returns the token name
(define-read-only (get-name)
  (ok "Mixmi")
)

(define-read-only (get-symbol)
  (ok "MXM")
)

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply mixmi))
)

;; (transfer (uint principal principal) (response bool uint))
;; amount sender recipient
;; Transfers tokens to a recipient

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (>= (ft-get-balance mixmi sender) amount)
     (begin
       (asserts! (is-eq tx-sender sender) (err ERR_PERMISSION_DENIED))
       (if (is-some memo)
           (print memo)
           none
       )
       (try! (ft-transfer? mixmi amount sender recipient))
       (ok true)
      )
      (err ERR_INSUFFICIENT_FUNDS)
   )
)

;; additional to the SIP010 fox MXM

;; all the data relevant to the MXM token
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

;; we implement additional functionalities for MXM
(impl-trait 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-token-trait-v1.paradigma-token-trait)

;; the extra mint and burn method used
;; can only be authtorized by the distributed data control
(define-public (mint (amount uint) (recipient principal))
    (begin
      ;; veryfing in distributed data control
      (asserts! (contract-call? 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-ddc-v1 is-remote-caller-authorized-to-execute contract-caller) (err ERR_PERMISSION_DENIED))
      (ft-mint? mixmi amount recipient)
    )
)

(define-public (burn (amount uint) (recipient principal))
    (begin
      ;; veryfing in distributed data control
      (asserts! (contract-call? 'SP3YK7KWMYRCDMV5M4792T0T7DERQXHJJGGEPV1N8.paradigma-ddc-v1 is-remote-caller-authorized-to-execute contract-caller) (err ERR_PERMISSION_DENIED))
      (ft-burn? mixmi amount recipient)
    )
)
