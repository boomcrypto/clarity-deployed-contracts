;; title: aibtc-dao
;; version: 1.0.0
;; summary: An ExecutorDAO implementation for aibtcdev

;; traits
;;

(impl-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-base-dao-trait.aibtc-base-dao)
(use-trait proposal-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.proposal)
(use-trait extension-trait 'SPW8QZNWKZGVHX012HCBJVJVPS94PXFG578P53TM.aibtc-dao-traits.extension)

;; constants
;;

(define-constant ERR_UNAUTHORIZED (err u1200))
(define-constant ERR_ALREADY_EXECUTED (err u1201))
(define-constant ERR_INVALID_EXTENSION (err u1202))
(define-constant ERR_NO_EMPTY_LISTS (err u1203))
(define-constant ERR_DAO_ALREADY_CONSTRUCTED (err u1204))

;; data vars
;;

;; used for initial construction, set to contract itself after
(define-data-var executive principal tx-sender)
(define-data-var constructed bool false)

;; data maps
;;

;; tracks block height of executed proposals
(define-map ExecutedProposals
  principal
  uint
)
;; tracks enabled status of extensions
(define-map Extensions
  principal
  bool
)

;; public functions
;;

;; initial construction of the DAO
(define-public (construct (proposal <proposal-trait>))
  (let ((sender tx-sender))
    (asserts! (not (var-get constructed)) ERR_DAO_ALREADY_CONSTRUCTED)
    (asserts! (is-eq sender (var-get executive)) ERR_UNAUTHORIZED)
    (var-set constructed true)
    (var-set executive (as-contract tx-sender))
    (print {
      notification: "fake-base-dao/construct",
      payload: {
        proposal: (contract-of proposal),
        sender: sender,
      },
    })
    (as-contract (execute proposal sender))
  )
)

;; execute Clarity code in a proposal
(define-public (execute
    (proposal <proposal-trait>)
    (sender principal)
  )
  (begin
    (try! (is-self-or-extension))
    (asserts!
      (map-insert ExecutedProposals (contract-of proposal) stacks-block-height)
      ERR_ALREADY_EXECUTED
    )
    (print {
      notification: "fake-base-dao/execute",
      payload: {
        proposal: proposal,
        sender: sender,
      },
    })
    (as-contract (contract-call? proposal execute sender))
  )
)

;; add an extension or update the status of an existing one
(define-public (set-extension
    (extension principal)
    (enabled bool)
  )
  (begin
    (try! (is-self-or-extension))
    (print {
      notification: "fake-base-dao/set-extension",
      payload: {
        enabled: enabled,
        extension: extension,
      },
    })
    (ok (map-set Extensions extension enabled))
  )
)

;; add multiple extensions or update the status of existing ones
(define-public (set-extensions (extensionList (list 200 {
  extension: principal,
  enabled: bool,
})))
  (begin
    (try! (is-self-or-extension))
    (asserts! (> (len extensionList) u0) ERR_NO_EMPTY_LISTS)
    (ok (map set-extensions-iter extensionList))
  )
)

;; request a callback from an extension
(define-public (request-extension-callback
    (extension <extension-trait>)
    (memo (buff 34))
  )
  (let ((sender tx-sender))
    (asserts! (is-extension contract-caller) ERR_INVALID_EXTENSION)
    (asserts! (is-eq contract-caller (contract-of extension))
      ERR_INVALID_EXTENSION
    )
    (print {
      notification: "fake-base-dao/request-extension-callback",
      payload: {
        extension: extension,
        memo: memo,
        sender: sender,
      },
    })
    (as-contract (contract-call? extension callback sender memo))
  )
)

;; read only functions
;;

(define-read-only (is-constructed)
  (var-get constructed)
)

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
  (ok (asserts!
    (or (is-eq tx-sender (as-contract tx-sender)) (is-extension contract-caller))
    ERR_UNAUTHORIZED
  ))
)

;; set-extensions helper function
(define-private (set-extensions-iter (item {
  extension: principal,
  enabled: bool,
}))
  (begin
    (print {
      notification: "fake-base-dao/set-extension",
      payload: {
        enabled: (get enabled item),
        extension: (get extension item),
      },
    })
    (map-set Extensions (get extension item) (get enabled item))
  )
)
