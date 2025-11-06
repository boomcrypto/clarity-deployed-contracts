;; TruthChain - Decentralized Content Provenance System
;; Registers and verifies content hashes on the Stacks blockchain
;; This smart contract provides a tamper-proof registry for digital content
;; allowing users to prove authenticity and ownership of their content

;; Contract Owner - Set to the deployer of the contract
(define-constant CONTRACT-OWNER tx-sender)

;;;;;;;;;;;;; CONSTANTS ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constant Error codes
(define-constant ERR-HASH-EXISTS (err u100))
(define-constant ERR-INVALID-HASH (err u101))
(define-constant ERR-INVALID-CONTENT-TYPE (err u102))
(define-constant ERR-UNAUTHORIZED (err u103))
(define-constant ERR-HASH-NOT-FOUND (err u104))


;; Content types
(define-constant CONTENT-TYPE-BLOG-POST "blog_post")
(define-constant CONTENT-TYPE-PAGE "page")
(define-constant CONTENT-TYPE-MEDIA "media")
(define-constant CONTENT-TYPE-DOCUMENT "document")
;; Added Twitter content type
(define-constant CONTENT-TYPE-TWEET "tweet")

;;;;;;;;;;;; DATA MAPS ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Main content registry - maps hash to content metadata
(define-map content-registry
  { hash: (buff 32) }
  { author: principal,
    block-height: uint,
    time-stamp: uint,
    content-type: (string-ascii 32),
    registration-id: uint,
  }
)

;; Author's content index - allows querying by author
(define-map author-content
  { author: principal, registration-id: uint }
  { hash: (buff 32) }
)


;;;;;;;;;;;; DATA VARS ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Global counters
(define-data-var total-registrations uint u0)
(define-data-var contract-active bool true)


;;;;;;;;;; PRIVATE FUNCTIONS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Validates that the provided content type is one of the supported types
;; This prevents invalid content types from being registered
;; @param content-type: string-ascii 32 - The content type to validate
;; @returns: bool - true if valid content type, false otherwise
(define-private (is-valid-content-type (content-type (string-ascii 32)))
  (or 
    (is-eq content-type CONTENT-TYPE-BLOG-POST)
    (is-eq content-type CONTENT-TYPE-PAGE)
    (is-eq content-type CONTENT-TYPE-MEDIA)
    (is-eq content-type CONTENT-TYPE-DOCUMENT)
    (is-eq content-type CONTENT-TYPE-TWEET)
  )
)

;; Helper Function to validate hash (must be exactly 32 bytes)
;; This ensures we only accept properly formatted SHA-256 hashes
;; @param hash: buff 32 - The hash buffer to validate
;; @returns: bool - true if hash is exactly 32 bytes, false otherwise
(define-private (is-valid-hash (hash (buff 32)))
  (is-eq (len hash) u32)
)

;;;;;;;;;;; PUBLIC FUNCTIONS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Main registration function - Registers new content on the blockchain
;; Takes a SHA-256 hash and content type, creates immutable proof of registration
;; Returns registration details or error if validation fails
;; @param hash: buff 32 - SHA-256 hash of the content to register
;; @param content-type: string-ascii 32 - Type of content (blog_post, page, media, document, tweet)
;; @returns: (response {registration-id: uint, hash: buff 32, author: principal, block-height: uint, timestamp: uint} uint)
;;           Success: registration details, Error: error code (100-104)
(define-public (register-content (hash (buff 32)) (content-type (string-ascii 32)))
  (let
    (
      (current-registrations (var-get total-registrations))
      (new-registration-id (+ current-registrations u1))
      (current-block stacks-block-height)
    )
    ;; Validation checks - Ensure all requirements are met before registration
    (asserts! (var-get contract-active) ERR-UNAUTHORIZED)  ;; Contract must be active
    (asserts! (is-valid-hash hash) ERR-INVALID-HASH)       ;; Hash must be 32 bytes
    (asserts! (is-valid-content-type content-type) ERR-INVALID-CONTENT-TYPE)  ;; Valid content type
    (asserts! (is-none (map-get? content-registry { hash: hash })) ERR-HASH-EXISTS)  ;; Hash not already registered
    
    ;; Register the content in the main registry with all metadata
    (map-set content-registry
      { hash: hash }
      {
        author: tx-sender,                    ;; Address that registered the content
        block-height: current-block,          ;; Block when registered
        time-stamp: current-block,            ;; Timestamp of registration
        content-type: content-type,           ;; Type of content (blog, media, etc.)
        registration-id: new-registration-id  ;; Unique sequential ID
      }
    )
    
    ;; Add to author's index for easy lookup of user's content
    (map-set author-content
      { author: tx-sender, registration-id: new-registration-id }
      { hash: hash }
    )
    
    ;; Update the global counter for tracking total registrations
    (var-set total-registrations new-registration-id)
    
    ;; Return success with registration details
    (ok {
      registration-id: new-registration-id,
      hash: hash,
      author: tx-sender,
      block-height: current-block,
      timestamp: current-block
    })
  )
)

;; Verify content by hash (read-only)
;; Returns full registration data if hash exists, error if not found
;; This is the primary function for content verification
;; @param hash: buff 32 - The content hash to verify
;; @returns: (response {author: principal, block-height: uint, time-stamp: uint, content-type: string-ascii 32, registration-id: uint} uint)
;;           Success: full registration data, Error: ERR-HASH-NOT-FOUND (104)
(define-read-only (verify-content (hash (buff 32)))
  (match (map-get? content-registry { hash: hash })
    registration-data (ok registration-data)
    ERR-HASH-NOT-FOUND
  )
)

;; Check if hash exists (simple boolean check)
;; Returns true if hash is registered, false otherwise
;; Lighter weight than verify-content when you only need existence check
;; @param hash: buff 32 - The content hash to check
;; @returns: bool - true if hash is registered, false if not found
(define-read-only (hash-exists (hash (buff 32)))
  (is-some (map-get? content-registry { hash: hash }))
)

;; Get content by author and registration ID
;; Allows lookup of specific content by author and their registration sequence
;; Useful for browsing an author's content chronologically
;; @param author: principal - The author's wallet address
;; @param registration-id: uint - The sequential registration ID for that author
;; @returns: (response {author: principal, block-height: uint, time-stamp: uint, content-type: string-ascii 32, registration-id: uint} uint)
;;           Success: full registration data, Error: ERR-HASH-NOT-FOUND (104)
(define-read-only (get-author-content (author principal) (registration-id uint))
  (match (map-get? author-content { author: author, registration-id: registration-id })
    hash-data 
      (match (map-get? content-registry { hash: (get hash hash-data) })
        content-data (ok content-data)
        ERR-HASH-NOT-FOUND
      )
    ERR-HASH-NOT-FOUND
  )
)

;; Get total number of registrations
;; Returns the current count of all registered content hashes
;; Useful for frontend pagination and statistics
;; @returns: (response uint uint) - Success: total registration count, Error: none (always succeeds)
(define-read-only (get-total-registrations)
  (ok (var-get total-registrations))
)

;; Get contract stats
;; Returns comprehensive contract information including status and ownership
;; Useful for frontend dashboards and monitoring
;; @returns: (response {total-registrations: uint, contract-active: bool, contract-owner: principal} uint)
;;           Success: contract statistics, Error: none (always succeeds)
(define-read-only (get-contract-stats)
  (ok {
    total-registrations: (var-get total-registrations),
    contract-active: (var-get contract-active),
    contract-owner: CONTRACT-OWNER
  })
)

;; Batch verify multiple hashes (up to 10 at once)
;; Efficiently check existence of multiple hashes in a single call
;; Returns list of hash/exists pairs to reduce frontend API calls
;; @param hashes: (list 10 (buff 32)) - List of up to 10 hashes to verify
;; @returns: (response (list 10 {hash: (buff 32), exists: bool}) uint)
;;           Success: list of verification results, Error: none (always succeeds)
(define-read-only (batch-verify (hashes (list 10 (buff 32))))
  (ok (map verify-content-simple hashes))
)

;; Helper for batch verify - Creates simplified verification result
;; Returns just hash and existence status for efficiency
;; @param hash: buff 32 - The hash to check
;; @returns: {hash: (buff 32), exists: bool} - Hash and its existence status
(define-private (verify-content-simple (hash (buff 32)))
  {
    hash: hash,
    exists: (hash-exists hash)
  }
)

;; Admin functions (only contract owner)
;; Toggle contract active status - Emergency pause/unpause functionality
;; Allows contract owner to disable new registrations if needed
;; @returns: (response bool uint) - Success: new contract status, Error: ERR-UNAUTHORIZED (103)
(define-public (toggle-contract-status)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set contract-active (not (var-get contract-active)))
    (ok (var-get contract-active))
  )
)

;; Emergency function to verify specific registration by ID
;; Validates that a registration ID exists within the valid range
;; Useful for checking sequential registration integrity
;; @param registration-id: uint - The registration ID to validate
;; @returns: (response uint uint) - Success: the registration ID, Error: ERR-HASH-NOT-FOUND (104)
(define-read-only (get-registration-by-id (registration-id uint))
  (if (and (> registration-id u0) (<= registration-id (var-get total-registrations)))
    (ok registration-id)  ;; Return the ID if valid
    ERR-HASH-NOT-FOUND    ;; Error if ID is out of range
  )
)

;; Get content type constants (for frontend reference)
;; Returns all supported content types for frontend validation
;; Ensures frontend and contract stay in sync with supported types
;; @returns: (response {blog-post: string-ascii, page: string-ascii, media: string-ascii, document: string-ascii, tweet: string-ascii} uint)
;;           Success: all content type constants, Error: none (always succeeds)
(define-read-only (get-content-types)
  (ok {
    blog-post: CONTENT-TYPE-BLOG-POST,
    page: CONTENT-TYPE-PAGE,
    media: CONTENT-TYPE-MEDIA,
    document: CONTENT-TYPE-DOCUMENT,
    tweet: CONTENT-TYPE-TWEET
  })
)