;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_ACTION (err u402))
(define-constant contract-owner 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS)

;; Data Variables
(define-data-var contract-uri (optional (string-utf8 256)) (some u"https://charisma.rocks"))

;; Public functions

;; Implement get-interaction-uri from interaction-trait
(define-read-only (get-interaction-uri)
  (ok (var-get contract-uri))
)

;; Implement execute from interaction-trait (renamed from take-action to match Dungeon Crawler)
(define-public (execute (action (string-ascii 32)))
  (if (is-eq action "ADVENTURE")
      (begin
        (print "Charisma - Next-Generation DeFi")
        (ok true)
      )
      ERR_INVALID_ACTION
  )
)

;; Admin function to update the contract URI
(define-public (set-contract-uri (new-uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    (ok (var-set contract-uri new-uri))
  )
)