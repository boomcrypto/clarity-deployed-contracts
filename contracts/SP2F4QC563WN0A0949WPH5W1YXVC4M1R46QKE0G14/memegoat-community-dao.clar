;; MEMEGOAT COMMUNITY DAO
(use-trait proposal-trait .proposal-trait.proposal-trait)
(use-trait extension-trait .extension-trait.extension-trait)

;; ERRs
(define-constant ERR-UNAUTHORISED (err u1000))
(define-constant ERR-ALREADY-EXECUTED (err u1001))
(define-constant ERR-INVALID-EXTENSION (err u1002))

;; STORAGE
(define-data-var executive principal tx-sender)
(define-map executed-proposals principal uint)
(define-map extensions principal bool)

;; READ-ONLY CALLS
(define-read-only (executed-at (proposal <proposal-trait>))
	(map-get? executed-proposals (contract-of proposal))
)

(define-read-only (is-extension (extension principal))
	(default-to false (map-get? extensions extension))
)

;;  DAO CALLS
(define-public (set-extension (extension principal) (enabled bool))
	(begin
		(try! (is-self-or-extension))
		(print {event: "extension", extension: extension, enabled: enabled})
		(ok (map-set extensions extension enabled))
	)
)

(define-public (set-extensions (extension-list (list 200 {extension: principal, enabled: bool})))
	(begin
		(try! (is-self-or-extension))
		(ok (map set-extensions-iter extension-list))
	)
)

(define-public (execute (proposal <proposal-trait>) (sender principal) (id uint))
	(begin
		(try! (is-self-or-extension))
		(asserts! (map-insert executed-proposals (contract-of proposal) block-height) ERR-ALREADY-EXECUTED)
		(print {event: "execute", proposal: proposal})
		(as-contract (contract-call? proposal execute sender id))
	)
)

(define-public (request-extension-callback (extension <extension-trait>) (payload (buff 2048)))
	(let ((sender tx-sender))
		(asserts! (is-extension contract-caller) ERR-INVALID-EXTENSION)
		(asserts! (is-eq contract-caller (contract-of extension)) ERR-INVALID-EXTENSION)
		(as-contract (contract-call? extension callback sender payload))
	)
)

(define-public (construct (proposal <proposal-trait>) (id uint))
	(let ((sender tx-sender))
		(asserts! (is-eq sender (var-get executive)) ERR-UNAUTHORISED)
		(var-set executive (as-contract tx-sender))
		(as-contract (execute proposal sender id))
	)
)

;; PRIVATE CALLS
(define-private (is-self-or-extension)
	(ok (asserts! (or (is-eq tx-sender (as-contract tx-sender)) (is-extension contract-caller)) ERR-UNAUTHORISED))
)

(define-private (set-extensions-iter (item {extension: principal, enabled: bool}))
	(begin
		(print {event: "extension", extension: (get extension item), enabled: (get enabled item)})
		(map-set extensions (get extension item) (get enabled item))
	)
)