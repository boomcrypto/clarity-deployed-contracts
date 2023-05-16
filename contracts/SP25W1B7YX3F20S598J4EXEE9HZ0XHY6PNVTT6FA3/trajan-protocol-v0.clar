;; Trajan Protocol Alpha
;; Contract that controls critical Trajan protocol functions (profile registration, organization registration, etc.)
;; Written by Setzeus/StrataLabs and hz

;; Trajan Protocol Alpha
;; This contract is the core Trajan implementation that tracks the registration of profiles
;; This is currently in Alpha as an incomplete prototype with likely bugs


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant CONTRACT_DEPLOYER tx-sender)
(define-constant ADDRESS_VERSION (if (is-eq chain-id u1) 0x16 0x1a))


;; Temporary Principal Helper
(define-data-var helper-principal principal tx-sender)


;; Map of All Registered profiles
(define-map address-to-name principal {name: (buff 48), namespace: (buff 20)})
(define-map name-to-address {name: (buff 48), namespace: (buff 20)} principal)
(define-map blocked-users principal bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-Only Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (resolve-principal (address principal)) 
    (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal address))

(define-read-only (does-pair-exist (address principal) (bns-name {name: (buff 48), namespace: (buff 20)}))
    (or 
        (is-some (map-get? address-to-name address))
        (is-some (map-get? name-to-address bns-name))
    )
)

(define-read-only (is-principal-blocked (address principal))
    (default-to false (map-get? blocked-users address)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; profile Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;;; Core Funcs ;;;
;;;;;;;;;;;;;;;;;;

;; Lock BNS Name
;; @desc - Allows a principal to lock their BNS name to their profile
(define-public (lock-bns-name (address principal))
    (begin 
        (asserts! (is-eq contract-caller tx-sender address) (err "err-principal-not-profile-owner"))
        ;; Assert principal not already registered
        (lock-bns-inner address)
    )
)


;; helper function to lock bns names for first endorsement
(define-public (first-endorsement-lock (sender principal) (recipient principal))
    (let 
        (
            (caller (unwrap! (principal-destruct? contract-caller) (err "err-unwrapping-caller")))
            (caller-name (unwrap! (get name caller) (err "err-unwrapping-caller-name")))
            (caller-address (unwrap! (principal-construct? ADDRESS_VERSION (get hash-bytes caller)) (err "err-unwrapping-caller-address")))
            (sender-exists (is-some (map-get? address-to-name sender)))
            (recipient-exists (is-some (map-get? address-to-name recipient)))
        )
    (asserts! 
        (and 
            (is-eq caller-address CONTRACT_DEPLOYER)
            ;; maybe we'd upgrade the endorsements contract at some point
            ;; but it must be a contract for transparency
            (> (len caller-name) u1))
        (err "err-invalid-caller"))
    (try! (if (not sender-exists) 
        (lock-bns-inner sender)
        (ok true)))
    (try! (if (not recipient-exists) 
        (lock-bns-inner recipient)
        (ok true)))
    (ok true)))


(define-private (lock-bns-inner (address principal)) 
    (let 
        (
            (principal-name-resolve (resolve-principal address))
            (bns-name (unwrap! principal-name-resolve (err "err-unwrapping-principal-name-resolve")))
        )
        ;; Assert principal not already registered
        (asserts! (not (does-pair-exist address bns-name)) (err "err-principal-already-registered"))
        (map-insert address-to-name address bns-name)
        (ok (map-insert name-to-address bns-name address))
    ))



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (check-and-block-changed-name (address principal))
    (let 
        (
            (registered-name (unwrap! (map-get? address-to-name address) (err "err-profile-not-found")))
            (current-principal-name-resolve (resolve-principal address))
            (bns-resolve-name (unwrap! current-principal-name-resolve (err "err-unwrapping-principal-name-resolve")))
            (name-changed (not (is-eq registered-name bns-resolve-name)))
            (is-blocked (is-principal-blocked address))
        )
        (asserts! (not is-blocked) (err "err-principal-blocked"))
        (if name-changed 
            (begin
                (map-insert blocked-users address true)
                (err "err-principal-name-changed"))
            (ok true))
    )
)
