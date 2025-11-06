;; LazyCards Protocol v0.1 (Hackathon Edition)
;; A simple, minimal contract to notarize prediction hashes and handle fees.

;; --- Constants ---
(define-constant CONTRACT_ADMIN tx-sender) ;; The wallet that deploys the contract
(define-constant PUBLICATION_FEE u1000000)  ;; 1 STX (1,000,000 micro-STX)

;; --- Data Structures ---
;; Maps a unique card ID (uint) to the prediction's data hash (buff 32)
(define-map prediction-hashes uint (buff 32))

;; --- Public Functions ---

;; @desc Registers a hash for a given card ID, sealing it on-chain.
;; @param card-id: A unique identifier for the LazyCard from our database.
;; @param prediction-hash: The SHA256 hash of the prediction data.
;; @returns (response (bool true) uint)
(define-public (seal-prediction (card-id uint) (prediction-hash (buff 32)))
  (begin
    ;; 1. The user pays the publication fee. The fee is transferred
    ;;    directly to the admin wallet in the same transaction.
    (try! (stx-transfer? PUBLICATION_FEE tx-sender CONTRACT_ADMIN))
    
    ;; 2. The prediction's hash is set in the map, creating the
    ;;    permanent, on-chain record.
    (map-set prediction-hashes card-id prediction-hash)
    
    (ok true)
  )
)

;; --- Read-Only Functions ---

;; @desc Retrieves the registered hash for a given card ID to allow public verification.
;; @param card-id: The ID of the card to look up.
;; @returns (response (optional (buff 32)) none)
(define-read-only (get-prediction-hash (card-id uint))
  (ok (map-get? prediction-hashes card-id))
)
