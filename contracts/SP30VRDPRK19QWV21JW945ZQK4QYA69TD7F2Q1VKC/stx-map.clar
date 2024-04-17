;; title: STX Map Token
;; website: https://stxmap.co
;; description: This is the Token for the STXMAP Community.

;; 69M Total Supply 
;; 21M airdropped to OG STXMAP holders. snapshot taken at block #144337
;; 21M minted on STX20 protocol will be available for a free bridge after mint out
;; 21M locked for future developments: exclusive utility token for the STXMAP Community
;; 6M  Community Treasury
;; 420888 will be burned the 4/20/24

;; Mainnet Fungible Token trait
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Define the FT, with no maximum supply
(define-fungible-token stx-map)

;; Define errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

;; Define constants for contract
(define-constant CONTRACT_OWNER tx-sender)
(define-data-var TOKEN_URI (optional (string-utf8 256)) (some u"https://gateway.pinata.cloud/ipfs/QmNu5NcoKMchF18eGcqAcWEfBSgDfo9veYvbUqme3tvbMt"))
(define-constant TOKEN_NAME "STX Map")
(define-constant TOKEN_SYMBOL "MAP")
(define-constant TOKEN_DECIMALS u6) ;; 6 units displayed past decimal, e.g. 1.000_000 = 1 token
(define-constant TOKEN_SUPPLY u69420888000000) ;; 69M Total Supply 

;; SIP-010 function: Get the token balance of a specified principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance stx-map who))
)

;; SIP-010 function: Returns the total supply of fungible token
(define-read-only (get-total-supply)
  (ok (ft-get-supply stx-map))
)

;; SIP-010 function: Returns the human-readable token name
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

;; SIP-010 function: Returns the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

;; SIP-010 function: Returns number of decimals to display
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

;; SIP-010 function: define token URI
(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
        (var-set TOKEN_URI (some value))
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

;; SIP-010 function: Returns the URI containing token metadata
(define-read-only (get-token-uri)
    (ok (var-get TOKEN_URI)
    )
)

;; SIP-010 function: Transfers tokens to a recipient
;; Sender must be the same as the caller to prevent principals from transferring tokens they do not own.
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? stx-map amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; SIP-010 function: Burn tokens
;; Sender must be the same as the caller to prevent principals from burning tokens they do not own.

(define-public (burn-tokens (burn-amount uint) (burn-from principal) )
  (begin
    (asserts! (is-eq tx-sender burn-from) ERR_NOT_TOKEN_OWNER)
    ;; Print the action for any off chain watchers
    (print { action: "burn-tokens", burn-amount: burn-amount, burn-from : burn-from  })
    (ft-burn? stx-map burn-amount burn-from))
)

;; send-many functions from nakamoto-token-v2 contract

(define-public (send-many (recipients (list 500 { to: principal, amount: uint, memo: (optional (buff 34)) })))
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

;; Mint Total Supply.

(begin
  (try! (ft-mint? stx-map TOKEN_SUPPLY CONTRACT_OWNER))
)