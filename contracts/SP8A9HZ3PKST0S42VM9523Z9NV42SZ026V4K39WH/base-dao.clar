;; Title: CityCoins base DAO contract
;; Summary: An ExecutorDAO implementation for CityCoins inspired by the one DAO to rule them all.

;; TRAITS

(use-trait proposal-trait .proposal-trait.proposal-trait)
(use-trait extension-trait .extension-trait.extension-trait)

;; CONSTANTS

(define-constant ERR_UNAUTHORIZED (err u900))
(define-constant ERR_ALREADY_EXECUTED (err u901))
(define-constant ERR_INVALID_EXTENSION (err u902))

;; DATA VARS

(define-data-var executive principal tx-sender)

;; DATA MAPS

(define-map ExecutedProposals principal uint)
(define-map Extensions principal bool)

;; PUBLIC FUNCTIONS

(define-public (set-extension (extension principal) (enabled bool))
  (begin
    (try! (is-self-or-extension))
    (print {event: "extension", enabled: enabled, extension: extension,})
    (ok (map-set Extensions extension enabled))
  )
)

(define-public (set-extensions (extensionList (list 200 {extension: principal, enabled: bool})))
  (begin
    (try! (is-self-or-extension))
    (ok (map set-extensions-iter extensionList))
  )
)

(define-public (execute (proposal <proposal-trait>) (sender principal))
  (begin
    (try! (is-self-or-extension))
    (asserts! (map-insert ExecutedProposals (contract-of proposal) block-height) ERR_ALREADY_EXECUTED)
    (print {event: "execute", proposal: proposal})
    (as-contract (contract-call? proposal execute sender))
  )
)

(define-public (construct (proposal <proposal-trait>))
  (let
    ((sender tx-sender))
    (asserts! (is-eq sender (var-get executive)) ERR_UNAUTHORIZED)
    (var-set executive (as-contract tx-sender))
    (as-contract (execute proposal sender))
  )
)

(define-public (request-extension-callback (extension <extension-trait>) (memo (buff 34)))
  (let
    ((sender tx-sender))
    (asserts! (is-extension contract-caller) ERR_INVALID_EXTENSION)
    (asserts! (is-eq contract-caller (contract-of extension)) ERR_INVALID_EXTENSION)
    (as-contract (contract-call? extension callback sender memo))
  )
)

;; READ ONLY FUNCTIONS

(define-read-only (is-extension (extension principal))
  (default-to false (map-get? Extensions extension))
)

(define-read-only (executed-at (proposal <proposal-trait>))
  (map-get? ExecutedProposals (contract-of proposal))
)

;; PRIVATE FUNCTIONS

;; authorization check
(define-private (is-self-or-extension)
  (ok (asserts! (or (is-eq tx-sender (as-contract tx-sender)) (is-extension contract-caller)) ERR_UNAUTHORIZED))
)

(define-private (set-extensions-iter (item {extension: principal, enabled: bool}))
  (begin
    (print {event: "extension", enabled: (get enabled item), extension: (get extension item)})
    (map-set Extensions (get extension item) (get enabled item))
  )
)
