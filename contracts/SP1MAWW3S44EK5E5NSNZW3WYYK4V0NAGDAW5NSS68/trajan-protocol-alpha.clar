;; Trajan Protocol Alpha
;; Contract that controls critical Trajan protocol functions (column registration, organization registration, etc.)
;; Written by Setzeus/StrataLabs

;; Trajan Protocol Alpha
;; This contract is the core Trajan implementation that tracks the registration of columns & organizations
;; This is currently in Alpha as an incomplete prototype with likely bugs


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Temporary Principal Helper
(define-data-var helper-principal principal tx-sender)

;; Watchers
(define-data-var watchers (list 10 principal) (list tx-sender))

;; Organization Counter
(define-data-var organization-counter uint u0)

;; Map of All Registered Columns
;; Profile image URL? Will provie multiples
(define-map columns principal {
    address: principal,
    BNS: (buff 20),                         
    BNS-Name: (buff 48),
    profile-image-url: (string-ascii 256),
    ;; To-do -> nft profile pic
    Statement: (optional (string-ascii 1024)),
    ;; Multiple social media links (make a list)
    Social: (optional (list 5 (string-ascii 256))),
    display-column: bool,
    column-achievements: (list 2500 uint),
})

;; Memory Math
;; Address -> 34 bytes
;; BNS -> 10 bytes
;; BNS-Name -> 24 bytes
;; Statement -> 1024 bytes
;; Social -> 256 bytes
;; display-column -> 1 byte
;; column-achievements -> 10000 bytes
;; Total Column Memory -> 11629 bytes

;; Map of All Registered Organizations
;; What should be the key? uint?
(define-map organization uint {
    name: (string-ascii 128),
    description: (string-ascii 1024),
    representatives: (list 10 principal),
    logo-url: (string-ascii 256),
    site-url: (string-ascii 128),
})

;; Organization Memory Math
;; Name -> 128 bytes
;; Description -> 1024 bytes
;; Representatives -> 320 bytes
;; Logo-URL -> 256 bytes
;; Site-URL -> 128 bytes
;; Total Organization Memory -> 1664 bytes

;; Lknow -> Storage costs are part of "execution costs" so the situation is the same
;; Are maps stored in the contract or on-chain separately?
;; If not will need traits for storing deploying storage column & m

;; Map of All Registered BNS Addresses
;; What is the max string length for a BNS address?
(define-map bns-registered-principal (buff 48) principal)

;; Map of All Organizations Addresses (?)
(define-map organization-addresses (string-ascii 128) uint)

;; Available Social Roots -> Twitter, GitHub, LinkedIn
(define-map whitelisted-social-roots uint (string-ascii 128))

;; Map of All Registered Social Handles
(define-map social-link-registered (string-ascii 256) bool)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-Only Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get Column By Principal
(define-read-only (get-column (column principal))
    (map-get? columns column)
)

;; Get Organization Represenatives
(define-read-only (get-organization-representatives (org (string-ascii 128))) 
    (let
        (
            (checked-org (unwrap! (map-get? organization-addresses org) (err "err-organization-not-found")))
            (current-org (unwrap! (map-get? organization checked-org) (err "err-organization-not-found")))
        )
        (ok (get representatives current-org))
    )
)

;; Get Organization By ID
(define-read-only (get-organization (org uint))
    (map-get? organization org)
)

;; Get Organization ID By Name
(define-read-only (get-organization-id (org (string-ascii 128)))
    (map-get? organization-addresses org)
)

;; Get Trajan Watchers
;; @desc - Returns a list of all Trajan Watchers for Milestone functions
(define-read-only (get-trajan-watchers)
    (var-get watchers)
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Column Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
;;; Core Funcs ;;;
;;;;;;;;;;;;;;;;;;

;; Register Column
;; @desc - Registers a new column
;; @param - BNS-Handle:(string-ascii 128), Statement:(string-ascii 1024), Social: (string-ascii 256)
(define-public (register-column (bns (buff 20)) (bns-name (buff 48)) (statement (optional (string-ascii 1024))) (profile-image-url (string-ascii 256)) (social (optional (string-ascii 256))) (social-root-identifier (optional uint)))
    (let 
        (
            (bns-name-resolve (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve bns bns-name) (err "err-bns-name-not-found")))
            (bns-name-resolve-owner (get owner bns-name-resolve))
            (principal-name-resolve (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender))
            (principal-name-resolve-value (get name (unwrap! principal-name-resolve (err "err-unwrapping-principal-name-resolve"))))
            (principal-namespace-resolve (get namespace (unwrap! principal-name-resolve (err "err-unwrapping-principal-name-resolve"))))
        )

        ;; Assert BNS not already registered
        (asserts! (is-none (map-get? bns-registered-principal bns-name)) (err "err-bns-already-registered"))

        ;; Assert principal not already registered
        (asserts! (is-none (map-get? columns tx-sender)) (err "err-principal-already-registered"))

        ;; Assert that principal is tx-sender with both resolves - SP000000000000000000002Q6VF78.bns
        (asserts! (and (is-eq tx-sender bns-name-resolve-owner) (is-eq bns principal-namespace-resolve) (is-eq bns-name principal-name-resolve-value)) (err "err-principal-not-bns-owner"))

        ;; Check that social media handle is valid
        (if (and (is-some social) (is-some social-root-identifier))
            (begin 
                (asserts! (social-handle-check (default-to u2 social-root-identifier) (default-to "" social)) (err "err-social-handle-invalid"))
                (map-set social-link-registered (default-to "" social) true)
                (map-set columns tx-sender {
                    address: tx-sender,
                    BNS: bns,                         
                    BNS-Name: bns-name,
                    profile-image-url: profile-image-url,
                    Statement: statement,
                    Social: (some (list (unwrap! social  (err "err-test")))),
                    display-column: true,
                    column-achievements: (list ),
                })
            )
             ;; Map-set new column
            (map-set columns tx-sender {
                address: tx-sender,
                BNS: bns,                         
                BNS-Name: bns-name,
                profile-image-url: profile-image-url,
                Statement: statement,
                Social: none,
                display-column: true,
                column-achievements: (list ),
            })
        )

        ;; Map-set new BNS address
        (ok (map-set bns-registered-principal bns-name tx-sender))

    )
)

;; Remove Column
;; @desc - Allows Owner to remove an existing column
;; @param - Column:principal
(define-public (remove-column) 
    (let
        (
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
            (current-column-principal (get address current-column))
        )

        ;; Assert that principal is current column principal
        (asserts! (is-eq tx-sender current-column-principal) (err "err-principal-not-column-owner"))

        ;; Map-delete column -> we won't reset BNS & social links since we don't want anyone else to re-use them
        ;; Store principal & BNS association in a map for future use (but don't store milestones)
        (ok (map-delete columns tx-sender))

    )
)



;;;;;;;;;;;;;;;;;;;;
;;; Update Funcs ;;;
;;;;;;;;;;;;;;;;;;;;

;; Update Social
;; @desc - Allows Owner to update an existing column Social
;; @param - Social:(string-ascii 256)
(define-public (update-social (social (string-ascii 256)) (social-index uint))
    (let 
        (
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
            (current-social (get Social current-column))
        )

        ;; Assert that protocol is still intact (aka tx-sender/column is still owner of BNS they registered with)
        (unwrap! (protocol-check-for-corrupted-column) (err "err-corrupt-column"))

        ;; Assert social-handle-check
        (asserts! (social-handle-check social-index social) (err "err-social-handle-invalid"))

        ;; Map-set registered social link
        (map-set social-link-registered social true)

        ;; Check if current social is-some, if so that means it's not the first item in the list therefore we need to append as-max-len?, if not it means this is the first item in the list and we need to create a new list
        (ok (if (is-some current-social)
            ;; Append to existing list
            (map-set columns tx-sender 
                (merge 
                    current-column
                    {Social: (as-max-len? (append (unwrap! current-social (err "err-test")) social) u5)}
                )
            )
            ;; Create new list
            (map-set columns tx-sender 
                (merge 
                    (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")) 
                    {Social: (some (list social))}
                )
            )
        ))

    )
)

;; Update Profile Image URL
;; @desc - Allows Owner to update an existing column Profile Image URL
;; @param - Profile-Image-URL:(string-ascii 256)
(define-public (update-profile-image-url (profile-image-url (string-ascii 256)))
    (let 
        (
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
        )

        ;; Assert that protocol is still intact (aka tx-sender/column is still owner of BNS they registered with)
        (unwrap! (protocol-check-for-corrupted-column) (err "err-corrupt-column"))

        (ok (map-set columns tx-sender 
            (merge 
                current-column
                {profile-image-url: profile-image-url}
            )
        ))
    )
)

;; Update Statement
;; @desc - Allows Owner to update an existing column Statement
;; @param - Statement:(string-ascii 1024)
(define-public (update-statement (statement (string-ascii 1024)))
    (let 
        (
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
        )

        ;; Assert that protocol is still intact (aka tx-sender/column is still owner of BNS they registered with)
        (unwrap! (protocol-check-for-corrupted-column) (err "err-corrupt-column"))

        (ok (map-set columns tx-sender 
            (merge 
                (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")) 
                {Statement: (some statement)}
            )
        ))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Organization Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add New Representative
;; @desc - Allows Organization Represenatives to add a new representative
;; @param - Representative:principal, Organization:uint
(define-public (add-representative (representative principal) (id uint))
    (let 
        (
            (current-organization (unwrap! (map-get? organization id) (err "err-organization-not-found")))
            (current-representatives (get representatives current-organization))
        )

        ;; Assert that tx-sender is a representative
        (asserts! (is-some (index-of current-representatives tx-sender)) (err "err-not-representative"))

        ;; Map-set organization by merging current-organization with an updated as-max-len? list of representatives
        (ok (map-set organization id 
            (merge 
                current-organization
                {representatives: (unwrap! (as-max-len? (append current-representatives representative) u5) (err "err-representative-limit-reached"))}
            )
        ))

    )
)

;; Remove Representative
;; @desc - Allows Organization Represenatives to remove an existing representative
;; @param - Representative:principal, Organization:uint
(define-public (remove-representative (representative principal) (id uint))
    (let 
        (
            (current-organization (unwrap! (map-get? organization id) (err "err-organization-not-found")))
            (current-representatives (get representatives current-organization))
        )

        ;; Assert that tx-sender is a representative
        (asserts! (is-some (index-of current-representatives tx-sender)) (err "err-not-representative"))

        ;; Var-set helper principal
        (var-set helper-principal representative)

        ;; Map-set organization by merging current-organization with an updated as-max-len? list of representatives
        (ok (map-set organization id 
            (merge 
                current-organization
                {representatives: (filter filter-principal current-representatives)}
            )
        ))

    )
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Watcher Functions ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Watcher New Organization
;; @desc - Allows Watcher to create a new organization
;; @param - Name:(string-ascii 256), Description:(string-ascii 1024), Website:(string-ascii 256), Logo:(string-ascii 256), Initial-Representative:principal
(define-public (watcher-new-organization (name (string-ascii 128)) (description (string-ascii 1024)) (website (string-ascii 128)) (logo (string-ascii 256)) (initial-representative principal))
    (let 
        (
            (current-organization-index (var-get organization-counter))
            (next-organization-index (+ current-organization-index u1))
        )

        ;; Assert that tx-sender is a watcher
        (asserts! (is-some (index-of (var-get watchers) tx-sender)) (err "err-not-watcher"))

        ;; Map-set organization
        (map-set organization current-organization-index 
            {
                name: name,
                description: description,
                representatives: (list initial-representative),
                logo-url: logo,
                site-url: website,
            }
        )

        ;; Map-set organization-addresses
        (map-set organization-addresses name current-organization-index)

        ;; Increment organization-counter
        (ok (var-set organization-counter (+ current-organization-index u1)))

    )
)


;; Watcher Remove Column
;; @desc - Allows Watcher to remove an existing column
;; @param - Column:principal
(define-public (watcher-remove-column (column principal)) 
    (let 
        (
            (current-column (unwrap! (map-get? columns column) (err "err-column-not-found")))
        )

        ;; Assert that tx-sender is a watcher
        (asserts! (is-some (index-of (var-get watchers) tx-sender)) (err "err-not-watcher"))

        ;; Map-delete column
        (ok (map-delete columns column))

    )
)

;; Add Watcher
(define-public (add-watcher (new-watcher principal)) 
    (let 
        (
            (new-column (unwrap! (map-get? columns new-watcher) (err "err-column-not-found")))
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
            (current-watchers (var-get watchers))
        )

        ;; Assert that tx-sender is a watcher
        (asserts! (is-some (index-of current-watchers tx-sender)) (err "err-not-watcher"))

        ;; Assert that new-watcher is not already a watcher
        (asserts! (not (is-some (index-of current-watchers new-watcher))) (err "err-watcher-already-exists"))

        ;; Var-set new watch by appending to list as-max-len?
        (ok (var-set watchers (unwrap! (as-max-len? (append current-watchers new-watcher) u5) (err "err-watcher-limit-reached"))))
    )
)

;; Remove Watcher
(define-public (remove-watcher (watcher principal)) 
    (let 
        (
            (removing-column (unwrap! (map-get? columns watcher) (err "err-column-not-found")))
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
            (current-watchers (var-get watchers))
        )

        ;; Assert that tx-sender is a watcher
        (asserts! (is-some (index-of current-watchers tx-sender)) (err "err-not-watcher"))

        ;; Asset that remove-column is a watcher
        (asserts! (is-some (index-of current-watchers watcher)) (err "err-not-watcher"))

        ;; Var-set helper principal
        (var-set helper-principal watcher)

        ;; Filter to remove out princpal from watcher list
        (ok (var-set watchers (filter filter-principal current-watchers)))

    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Social Media Handle String Validation
;; @desc - Private function that checks that social media handle is valid
;; @param - Identifier:uint, Handle:(string-ascii 256)
;; param should look like this: "https://"
;; identifier 0 = github
;; identifier 1 = twitter
(define-private (social-handle-check (identifier uint) (handle (string-ascii 256)))
    (let 
        (
            (social-root-map (map-get? whitelisted-social-roots identifier))
            (social-link-map (map-get? social-link-registered handle))
        )

        (asserts! (is-some social-root-map) false)

        (asserts! (is-none social-link-map) false)

        (if (is-eq identifier u0)
            (asserts! (and (is-eq (element-at handle u8) (some "g")) (is-eq (element-at handle u9) (some "i")) (is-eq (element-at handle u10) (some "t"))) false)
            (if (is-eq identifier u1)
                (asserts! (and (is-eq (element-at handle u8) (some "t")) (is-eq (element-at handle u9) (some "w")) (is-eq (element-at handle u10) (some "i"))) false)
                false
            )
        )
    )
)

(define-public (protocol-check-for-corrupted-column)
    (let 
        (
            (current-column (unwrap! (map-get? columns tx-sender) (err "err-column-not-found")))
            (current-column-bns (get BNS current-column))
            (current-column-bns-name (get BNS-Name current-column))
            (current-principal-name-resolve (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender))
            (principal-name-resolve-value (get name (unwrap! current-principal-name-resolve (err "err-principal-name-resolve-failed"))))
            (principal-namespace-resolve (get namespace (unwrap! current-principal-name-resolve (err "err-principal-namespace-resolve-failed"))))
            (bns-name-resolve (unwrap! (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve principal-namespace-resolve principal-name-resolve-value) (err "err-bns-name-resolve-failed")))
            (bns-name-resolve-owner (get owner bns-name-resolve))
        )

        ;; Check if principal is tx-sender with both resolves - SP000000000000000000002Q6VF78.bns
        (ok (if (and (is-eq tx-sender bns-name-resolve-owner) (is-eq current-column-bns principal-namespace-resolve) (is-eq current-column-bns-name principal-name-resolve-value))
            ;; Principal tied to tx-sender
            true
            ;; Principal not tied to tx-sender, remove column
            (begin 
                (map-delete columns tx-sender)
                false
            )
        ))

    )
)

;; Private helper function for filtering/removing a principal (principal-helper)
(define-private (filter-principal (item principal)) 
    (not (is-eq item (var-get helper-principal)))
)

;; Helper Function To Convert ASCII to Buffer
(define-read-only (asci2buff (in (string-ascii 100)))
    (fold ascii2buff_clojure in 0x)
)

(define-private (ascii2buff_clojure (chr (string-ascii 1)) (out (buff 100)))
    (match (index-of " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" chr) idx
        (match (element-at 0x202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E idx) x
            (unwrap-panic (as-max-len? (concat out x) u100))
            out
        )
        out
    )
)

;; Helper Function To Convert Buffer to ASCII
(define-read-only (buff2ascii (in (buff 100)))
    (fold buff2ascii_clojure in "")
)

(define-private (buff2ascii_clojure (buff (buff 1)) (out (string-ascii 100)))
    (match (index-of 0x202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E buff) idx
        (match (element-at " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" idx) x
            (unwrap-panic (as-max-len? (concat out x) u100))
            out
        )
        out
    )
)

(define-read-only (test (in (string-ascii 100)))
    (is-eq in (buff2ascii (asci2buff in)))
)

(map-set whitelisted-social-roots u0 "https://github.com/")
(map-set whitelisted-social-roots u1 "https://twitter.com/")