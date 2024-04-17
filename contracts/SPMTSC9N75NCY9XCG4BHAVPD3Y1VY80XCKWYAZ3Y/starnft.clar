
;; title: StarNFT
;; version: 0.1.0
;; summary: Galxe StarNFT
;; description:

;; traits
;;
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
;;
(define-non-fungible-token starnfts uint) ;; TODO: change to tuple

;; constants

;; errors
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-signature (err u102))
(define-constant err-cap-reached (err u103))
(define-constant err-invalid-signer-public-key (err u104))
(define-constant err-non-transferrable (err u105))
(define-constant err-invalid-address (err u106))

;; full uri: https://graphigo.prd.galaxy.eco/metadata/{contract}/{nft_id}.json
(define-constant base-uri "https://graphigo.prd.galaxy.eco/metadata/")

;; data vars
;;
(define-data-var contract-owner principal tx-sender)
(define-data-var signer-public-key (buff 33) 0x03bac0f69769c56b561cf64e00a505c9c31ebc9c7cc5b17c0a8cb54ae84c27b5e4)
(define-data-var last-token-id uint u0)
;; transferrable
(define-data-var transferrable bool true)


;; data maps
;;
;; minted verify ids<verify-id, minted>
(define-map minted-verify-ids uint bool)
;; campaign minted<cid, minted>
(define-map campaign-minted uint uint)
;; nft cids<nft-id, cid>
(define-map nft-cids uint uint)

;; public functions
;;
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (var-get transferrable) err-non-transferrable)
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? starnfts token-id sender recipient)
    )
)

(define-public (claim (cid uint) (verify-id uint) (cap uint) (owner principal) (signature (buff 65))) 
    (begin
        ;; TODO: add sig expriation time
        ;; (asserts! (is-standard owner) err-invalid-address)
        ;; check cap
        (asserts! (under-cap cid cap) err-cap-reached)
        ;; check verify id
        (asserts! (not (is-minted verify-id)) err-invalid-signature)
        ;; verify signature
        (asserts! (valid-signature cid verify-id cap owner signature) err-invalid-signature)
        (let 
            (
                (token-id (+ (var-get last-token-id) u1))
                (minted-count (+ (get-minted cid) u1))
            )
            ;; increase cap
            (map-set campaign-minted cid minted-count)
            ;; save verify id
            (map-set minted-verify-ids verify-id true)
            ;; mint token
            (try! (nft-mint? starnfts token-id owner))
            (ok token-id)
        )
    )
)

(define-public (update-transfferable (new-transferrable bool)) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (var-set transferrable new-transferrable)
        (ok true)
    )
)

(define-public (update-owner (new-owner principal)) 
    (begin 
        (asserts! (is-standard new-owner) err-invalid-address)
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (var-set contract-owner new-owner)
        (ok true)
    )
)

(define-public (update-signer-public-key (new-public-key (buff 33))) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (asserts! (is-eq new-public-key 0x000000000000000000000000000000000000000000000000000000000000000000) err-invalid-signer-public-key)
        (var-set signer-public-key new-public-key)
        (ok true)
    )
)

;; read only functions
;;
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok
        (if (is-none (nft-get-owner? starnfts token-id))
            none
            (some (nft-uri token-id))
        )
    )
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? starnfts token-id))
)

(define-read-only (get-signer-public-key)
    (var-get signer-public-key)
)

(define-read-only (get-cid (nft-id uint))
    (map-get? nft-cids nft-id)
)

(define-read-only (get-campaign-minted (cid uint))
    (ok (get-minted cid))
)

(define-read-only (is-verify-id-minted (verify-id uint)) 
    (map-get? minted-verify-ids verify-id)
)

(define-read-only (get-contract-hash) 
    (to-consensus-buff? (as-contract tx-sender))
)

;; TODO: test function, delete me after test
(define-read-only (test-hash (cid uint) (verify-id uint) (cap uint) (owner principal)) 
    (hash-claim-msg cid verify-id cap owner)
)

(define-read-only (test-verify (cid uint) (verify-id uint) (cap uint) (owner principal) (signature (buff 65))) 
    (valid-signature cid verify-id cap owner signature)
)

;; private functions
;;

(define-private (get-minted (cid uint))
    ;; if none, return 0
    ;; else return value
    (default-to u0 (map-get? campaign-minted cid))
)

(define-private (is-minted (verify-id uint))
    ;; if exist, return true
    (is-some (map-get? minted-verify-ids verify-id))
)

(define-private (under-cap (cid uint) (cap uint)) 
    ;; if cap equals 0, no cap
    (if (is-eq cap u0)
        true
        (< (get-minted cid) cap)
    )
)

(define-private (valid-signature (cid uint) (verify-id uint) (cap uint) (owner principal) (signature (buff 65))) 
    (let 
        (
            (msg-hash (hash-claim-msg cid verify-id cap owner))
        )
        (secp256k1-verify msg-hash signature (var-get signer-public-key))
    )
)

(define-private (hash-claim-msg (cid uint) (verify-id uint) (cap uint) (owner principal)) 
    ;; sha256(concat(sha256(chain-id), sha256(cid), sha256(verify-id), sha256(cap)))
    ;; TODO: hash contract address
    (sha256
        (concat 
            (concat 
                (concat 
                    (concat 
                        (concat 
                            (sha256 chain-id)
                            (unwrap-panic (get-contract-hash))
                        )
                        (sha256 cid) 
                    )
                    (sha256 verify-id)
                )
                (sha256 cap)
            ) 
            (unwrap-panic (to-consensus-buff? owner))
        )
    )
)

(define-private (nft-uri (token-id uint)) 
    (concat 
        (concat 
            base-uri
            (int-to-ascii token-id)
        )
        ".json"    
    )
)
