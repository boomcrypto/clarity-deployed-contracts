(define-constant CONTRACT-DEPLOYER tx-sender)
(define-constant ERR-NO-ADMIN (err u400))
(define-constant ERR-NOT-AUTH (err u401))
(define-constant ERR-NO-NAME (err u402))

;; Define a map `admin-principals` to store administrator principals with signer pubkey hash.
(define-map admin-principals principal (buff 20))

;; Define the authorized caller for this contract
(define-data-var namespace-manager-contract principal tx-sender)

;; Initialize the map
(map-set admin-principals CONTRACT-DEPLOYER (get-pubkey-hash CONTRACT-DEPLOYER))

;; Define a map `locked-names` to store names that are with a suspended status and their zonefile.
(define-map locked-names (buff 48) (buff 8192))

(define-read-only (get-admin (admin principal))
    (ok 
        (unwrap! (map-get? admin-principals admin) ERR-NO-ADMIN)
    )
)

(define-read-only (get-locked-name (name (buff 48)))
    (ok 
        (unwrap! (map-get? locked-names name) ERR-NO-NAME)
    )
)

(define-public (lock-name (name (buff 48)) (zonefile (buff 8192)))
    (ok 
        (begin 
            (asserts! (is-eq contract-caller (var-get namespace-manager-contract)) ERR-NOT-AUTH) 
            (map-set locked-names name zonefile)
        )
    )
)

(define-public (unlock-name (name (buff 48)))
    (ok 
        (begin 
            (asserts! (is-eq contract-caller (var-get namespace-manager-contract)) ERR-NOT-AUTH) 
            (map-delete locked-names name)
        )
    )
)

(define-public (add-admin (new-admin principal) (pub-key-hash (buff 20))) 
    (ok 
        (begin 
            (asserts! (is-eq contract-caller (var-get namespace-manager-contract)) ERR-NOT-AUTH) 
            (map-set admin-principals new-admin pub-key-hash)
        )
    )
)

(define-public (remove-admin (admin principal)) 
    (ok 
        (begin 
            (asserts! (is-eq contract-caller (var-get namespace-manager-contract)) ERR-NOT-AUTH) 
            (map-delete admin-principals admin)
        )
    )
)

(define-public (change-namespace-manager-contract (new-contract principal))
    (ok 
        (begin 
            (asserts! (is-eq contract-caller (var-get namespace-manager-contract)) ERR-NOT-AUTH) 
            (var-set namespace-manager-contract new-contract)
        )
    )
)

(define-private (get-pubkey-hash (addr principal))
  (get hash-bytes (unwrap-panic (principal-destruct? addr)))
)