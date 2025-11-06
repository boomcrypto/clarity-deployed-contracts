
;; title: bsd Token Contract

;; Explicit SIP-010 conformity
(impl-trait .sip-010-trait-ft-standard-vpv-11.sip-010-trait)

;; BSD Protocol 
(impl-trait .bsd-trait-vpv-11.bsd-trait)

;; Defines the bsd fungible token
(define-fungible-token bsd)

(define-constant contract-deployer tx-sender)

(define-constant TOKEN_NAME "BSD")
(define-constant TOKEN_SYMBOL "BSD")
(define-constant TOKEN_DECIMALS u8)

(define-constant ERR_NOT_AUTH (err u4))
(define-constant ERR_LIST_OVERFLOW (err u5))
(define-constant ERR_INVALID_CALLER (err u6))

(define-data-var token-uri (string-utf8 256) u"")

;; Protocol contract principals
(define-map authorized-protocol-callers principal bool)

;; List to track all privileged principals for enumeration
(define-data-var privileged-principals-list (list 100 principal) (list))

;; Owner
(define-data-var owner principal 'SP2MNRMNPCP1N5C6QQAKN0FDQK8G693F2VBZ2W1N7)
(define-data-var proposed-owner principal 'SP2MNRMNPCP1N5C6QQAKN0FDQK8G693F2VBZ2W1N7)

(define-read-only (is-authorized-protocol-caller (who principal))
	(ok (asserts! (default-to false (map-get? authorized-protocol-callers who)) ERR_NOT_AUTH))
)

(define-read-only (is-owner (who principal))
  (ok (asserts! (is-eq who (var-get owner)) ERR_NOT_AUTH))
)

;; Get all privileged protocol principals
(define-read-only (get-all-privileged-principals)
  (ok (var-get privileged-principals-list))
)

;; ---------------------------------------------------------
;; SIP-10 Functions - BEGIN
;; ---------------------------------------------------------

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_INVALID_CALLER)
    (try! (ft-transfer? bsd amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_INVALID_CALLER)
    (try! (ft-burn? bsd amount sender))
    (ok true)
  )
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance bsd account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply bsd))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; ---------------------------------------------------------
;; SIP-10 Functions - END
;; ---------------------------------------------------------

;; remove-principal-from-list
;; description: helper function for removing any principal from a list
(define-private (remove-principal-from-list (list-principal principal) (helper-tuple-response (response {found: bool, compare-principal: principal, new-list: (list 100 principal)} uint)))
    (match helper-tuple-response
        helper-tuple
            (let 
                (
                    (current-found (get found helper-tuple))
                    (current-compare-principal (get compare-principal helper-tuple))
                    (current-new-list (get new-list helper-tuple))
                )
                ;; check if principal was found
                (if current-found
                    ;; principal was found & skipped, continue appending existing list-principal to new-list
                    (ok (merge 
                        helper-tuple
                        {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u100) ERR_LIST_OVERFLOW)}
                    ))
                    ;; principal was not found, continue searching for compare-principal
                    (if (is-eq list-principal current-compare-principal)
                        ;; principal was found, skip appending to new-list & set found to true
                        (ok (merge 
                            helper-tuple
                            {found: true, new-list: current-new-list}
                        ))
                        ;; principal was not found, continue appending existing list-principal to new-list
                        (ok (merge 
                            helper-tuple
                            {new-list: (unwrap! (as-max-len? (append current-new-list list-principal) u100) ERR_LIST_OVERFLOW)}
                        ))
                    )
                )
            )
        err-response
            ERR_LIST_OVERFLOW
    )
)

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Admin  ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (is-owner tx-sender))
    (ok (var-set token-uri value))
  )
)

(define-public (propose-owner (new-owner principal))
	(begin 
		(try! (is-owner tx-sender))
		(ok (var-set proposed-owner new-owner))
	)
)

(define-public (claim-owner)
	(begin 
		(asserts! (is-eq tx-sender (var-get proposed-owner)) ERR_NOT_AUTH)
		(ok (var-set owner tx-sender))
	)
)

(define-public (add-privileged-protocol-principal (new-protocol-principal principal))
	(begin 
		(try! (is-owner tx-sender))
		(map-set authorized-protocol-callers new-protocol-principal true)
		(ok (var-set privileged-principals-list (unwrap! (as-max-len? (append (var-get privileged-principals-list) new-protocol-principal) u100) (err u1))))
	)
)

(define-public (remove-privileged-protocol-principal (protocol-principal principal))
	(begin 
		(try! (is-owner tx-sender))
		(map-delete authorized-protocol-callers protocol-principal)
		;; Remove from the list as well to keep it in sync
		(ok (var-set privileged-principals-list (get new-list (try! (fold remove-principal-from-list (var-get privileged-principals-list) (ok {found: false, compare-principal: protocol-principal, new-list: (list )}))))))
	)
)

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;; Protocol ;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

(define-public (protocol-burn (protocol-principal principal) (bsd-amount uint))
  (begin
    ;; check that caller is a protocol contract
    (try! (is-authorized-protocol-caller contract-caller))
    
    ;; check that burned amount is coming from a protocol contract
    (try! (is-authorized-protocol-caller protocol-principal))

    (ft-burn? bsd bsd-amount protocol-principal)
  )
)

(define-public (protocol-transfer (bsd-amount uint) (protocol-contract principal) (recipient principal))
  (begin
    ;; check that caller is a protocol contract
    (try! (is-authorized-protocol-caller contract-caller))

    ;; check that transferred amount is coming from a protocol contract
    (try! (is-authorized-protocol-caller protocol-contract))

    ;; finalize transfer
    (ft-transfer? bsd bsd-amount protocol-contract recipient)
  )
)

(define-public (protocol-mint (user principal) (bsd-amount uint))
  (begin
    (try! (is-authorized-protocol-caller contract-caller))
    (ft-mint? bsd bsd-amount user)
  )
)

;; Initialization 
(map-set authorized-protocol-callers .registry-vpv-11 true)
(map-set authorized-protocol-callers .vault-vpv-11 true)
(map-set authorized-protocol-callers .redeem-vpv-11 true)
(map-set authorized-protocol-callers .stability-vpv-11 true)
(map-set authorized-protocol-callers .timelock-vpv-11 true)

;; Initialize the privileged principals list
(var-set privileged-principals-list (list .registry-vpv-11 .vault-vpv-11 .redeem-vpv-11 .stability-vpv-11 .timelock-vpv-11))