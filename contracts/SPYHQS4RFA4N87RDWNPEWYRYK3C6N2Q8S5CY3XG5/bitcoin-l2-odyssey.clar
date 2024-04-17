
;; title: StarNFT
;; version: 0.1.0
;; summary: Galxe StarNFT
;; description:

;; traits
;;
(impl-trait 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.nft-approvable-trait.nft-approvable-trait)
;; (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; token definitions
;;
(define-non-fungible-token starnfts uint)

;; constants
(define-constant token-name "GalxeStarNFT")
(define-constant token-symbol "GALXE")

;; errors
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-signature (err u102))
(define-constant err-cap-reached (err u103))
(define-constant err-invalid-signer-public-key (err u104))
(define-constant err-non-transferrable (err u105))
(define-constant err-invalid-address (err u106))
(define-constant err-not-approval (err u107))

;; full uri: https://graphigo.prd.galaxy.eco/metadata/{contract_hash}/{nft_id}.json
(define-constant base-uri "https://graphigo.prd.galaxy.eco/metadata/SPYHQS4RFA4N87RDWNPEWYRYK3C6N2Q8S5CY3XG5.bitcoin-l2-odyssey/")

;; data vars
;;
(define-data-var contract-owner principal tx-sender)
;; signer public key
(define-data-var signer-public-key (buff 33) 0x036c572987e98f6244716c02ffa82a4aa244e3c8d965d6cac7079d98dcc2d78c32)
(define-data-var last-token-id uint u0)
;; transferrable
(define-data-var transferrable bool true)


;; data maps
;;
;; nft approvals<token-id, approval>
(define-map nft-approvals uint principal)
;; minted verify ids<verify-id, minted>
(define-map minted-verify-ids uint bool)
;; campaign minted<cid, minted>
(define-map campaign-minted uint uint)
;; nft cids<token-id, cid>
(define-map nft-cids uint uint)

;; public functions
;;
(define-public (transfer (token-id uint) (owner principal) (recipient principal))
    (begin
        (asserts! (var-get transferrable) err-non-transferrable)
        (asserts! (and (is-owner token-id owner) (is-owner-or-approval token-id tx-sender)) err-not-token-owner)
        (clear-approval token-id)
        (nft-transfer? starnfts token-id owner recipient)
    )
)

;; sets an approval principal - allowed to call transfer on owner behalf.
(define-public (set-approval-for (token-id uint) (approval principal))
    (begin
        (asserts! (is-owner token-id tx-sender) err-not-token-owner)
        (map-set nft-approvals token-id approval)
        (print {evt: "set-approval-for", token-id: token-id, approval: approval})
        (ok true)
    )
)

(define-public (claim (cid uint) (verify-id uint) (cap uint) (owner principal) (signature (buff 65))) 
    (begin
        (asserts! (is-standard owner) err-invalid-address)
        ;; check cap
        (asserts! (under-cap cid cap) err-cap-reached)
        ;; check verify id
        (asserts! (not (is-minted verify-id)) err-invalid-signature)
        ;; verify signature
        ;; (asserts! (valid-signature cid verify-id cap owner signature) err-invalid-signature)
        (let 
            (
                (token-id (+ (var-get last-token-id) u1))
                (minted-count (+ (get-minted cid) u1))
            )
            ;; increase cap
            (map-set campaign-minted cid minted-count)
            ;; save verify id
            (map-set minted-verify-ids verify-id true)
            ;; save nft cid
            (map-set nft-cids token-id cid)
            ;; save last token id
            (var-set last-token-id token-id)
            ;; mint token
            (try! (nft-mint? starnfts token-id owner))
            (print {evt: "claim", token-id: token-id, cid: cid, verify-id: verify-id, cap: cap, owner: owner})
            (ok token-id)
        )
    )
)

(define-public (update-transfferable (new-transferrable bool)) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (var-set transferrable new-transferrable)
        (print {evt: "update-transfferable", new-transferrable: new-transferrable})
        (ok true)
    )
)

(define-public (update-owner (new-owner principal)) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (asserts! (is-standard new-owner) err-invalid-address)
        (var-set contract-owner new-owner)
        (print {evt: "update-owner", new-owner: new-owner})
        (ok true)
    )
)

(define-public (update-signer-public-key (new-public-key (buff 33))) 
    (begin 
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (asserts! (not (is-eq new-public-key 0x000000000000000000000000000000000000000000000000000000000000000000)) err-invalid-signer-public-key)
        (var-set signer-public-key new-public-key)
        (print {evt: "update-signer-public-key", new-public-key: new-public-key})
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

(define-read-only (name) 
    (ok token-name)
)

(define-read-only (symbol) 
    (ok token-symbol)
)

(define-read-only (get-transferrable) 
    (ok (var-get transferrable))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? starnfts token-id))
)

(define-read-only (get-approval (token-id uint))
    (ok (unwrap! (map-get? nft-approvals token-id) err-not-approval))
)

(define-read-only (get-signer-public-key)
    (ok (var-get signer-public-key))
)

(define-read-only (get-cid (token-id uint))
    (ok (map-get? nft-cids token-id))
)

(define-read-only (get-campaign-minted (cid uint))
    (ok (get-minted cid))
)

(define-read-only (is-verify-id-minted (verify-id uint)) 
    (ok (map-get? minted-verify-ids verify-id))
)

(define-read-only (get-contract-hash) 
    (ok (contract-hash))
)

;; private functions
;;

(define-private (contract-hash) 
    (unwrap-panic (to-consensus-buff? (as-contract tx-sender)))
)

(define-private (is-owner (token-id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? starnfts token-id) false))
)

(define-private (is-approval (token-id uint) (user principal))
  (is-eq user (unwrap! (map-get? nft-approvals token-id) false))
)

(define-private (is-owner-or-approval (token-id uint) (user principal))
    (if (is-owner token-id user) true
        (if (is-approval token-id user) true false)
    )
)

(define-private (clear-approval (token-id uint)) 
    (map-delete nft-approvals token-id)
)

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
    (sha256
        (concat 
            (concat 
                (concat 
                    (concat 
                        (concat 
                            (sha256 chain-id)
                            (contract-hash)
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
