---
title: "Trait jbtdao-base-dao"
draft: true
---
```
;; title: aibtcdev-dao
;; version: 1.0.0
;; summary: An ExecutorDAO implementation for aibtcdev

;; traits
;;

(impl-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-v1.aibtcdev-base-dao)
(use-trait proposal-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.proposal)
(use-trait extension-trait 'SP29CK9990DQGE9RGTT1VEQTTYH8KY4E3JE5XP4EC.aibtcdev-dao-traits-v1.extension)

;; constants
;;

(define-constant ERR_UNAUTHORIZED (err u900))
(define-constant ERR_ALREADY_EXECUTED (err u901))
(define-constant ERR_INVALID_EXTENSION (err u902))
(define-constant ERR_NO_EMPTY_LISTS (err u903))

;; data vars
;;

;; used for initial construction, set to contract itself after
(define-data-var executive principal tx-sender)

;; data maps
;;

;; tracks block height of executed proposals
(define-map ExecutedProposals principal uint)
;; tracks enabled status of extensions
(define-map Extensions principal bool)

;; public functions
;;

;; initial construction of the DAO
(define-public (construct (proposal <proposal-trait>))
  (let
    ((sender tx-sender))
    (asserts! (is-eq sender (var-get executive)) ERR_UNAUTHORIZED)
    (var-set executive (as-contract tx-sender))
    (as-contract (execute proposal sender))
  )
)

;; execute Clarity code in a proposal
(define-public (execute (proposal <proposal-trait>) (sender principal))
  (begin
    (try! (is-self-or-extension))
    (asserts! (map-insert ExecutedProposals (contract-of proposal) block-height) ERR_ALREADY_EXECUTED)
    (print {
      notification: "execute",
      payload: {
        proposal: proposal,
        sender: sender,
      }
    })
    (as-contract (contract-call? proposal execute sender))
  )
)

;; add an extension or update the status of an existing one
(define-public (set-extension (extension principal) (enabled bool))
  (begin
    (try! (is-self-or-extension))
    (print {
      notification: "extension",
      payload: {
        enabled: enabled,
        extension: extension,
      }
    })
    (ok (map-set Extensions extension enabled))
  )
)

;; add multiple extensions or update the status of existing ones
(define-public (set-extensions (extensionList (list 200 {extension: principal, enabled: bool})))
  (begin
    (try! (is-self-or-extension))
    (asserts! (>= (len extensionList) u0) ERR_NO_EMPTY_LISTS)
    (ok (map set-extensions-iter extensionList))
  )
)

;; request a callback from an extension
(define-public (request-extension-callback (extension <extension-trait>) (memo (buff 34)))
  (let
    ((sender tx-sender))
    (asserts! (is-extension contract-caller) ERR_INVALID_EXTENSION)
    (asserts! (is-eq contract-caller (contract-of extension)) ERR_INVALID_EXTENSION)
    (print {
      notification: "request-extension-callback",
      payload: {
        extension: extension,
        memo: memo,
        sender: sender,
      }
    })
    (as-contract (contract-call? extension callback sender memo))
  )
)

;; read only functions
;;

(define-read-only (is-extension (extension principal))
  (default-to false (map-get? Extensions extension))
)

(define-read-only (executed-at (proposal <proposal-trait>))
  (map-get? ExecutedProposals (contract-of proposal))
)

;; private functions
;;

;; authorization check
(define-private (is-self-or-extension)
  (ok (asserts! (or (is-eq tx-sender (as-contract tx-sender)) (is-extension contract-caller)) ERR_UNAUTHORIZED))
)

;; set-extensions helper function
(define-private (set-extensions-iter (item {extension: principal, enabled: bool}))
  (begin
    (print {
      notification: "extension",
      payload: {
        enabled: (get enabled item),
        extension: (get extension item),
      }
    })
    (map-set Extensions (get extension item) (get enabled item))
  )
)

```
