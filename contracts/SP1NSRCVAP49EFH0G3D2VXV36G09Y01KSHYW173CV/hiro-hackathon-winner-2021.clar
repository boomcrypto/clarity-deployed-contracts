;; use the SIP009 interface
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define a new NFT
(define-non-fungible-token hiro-hackathon-winner-2021 uint)

;; list of NFT winners
(define-constant initial-members (list
'SP1X6M947Z7E58CNE0H8YJVJTVKS9VW0PHD4Q0A5F
'SPGCWKN03B99HBCMJT9ZE035RQJ419P7H3WC70AJ
'SPTYAX4NG2BPNDJMS35QZ0YKFS3MGDFM4JC04ZKB))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal)) 
  (if (and (is-owner token-id sender) (or (is-eq sender tx-sender ) (is-eq sender contract-caller))) 
    (match (nft-transfer? hiro-hackathon-winner-2021 token-id sender recipient)
      success (ok success)
      error (err u500))
    (err u401)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? hiro-hackathon-winner-2021 token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (len initial-members)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://www.hiro.so/blog/hiro-internal-hackathon-recap")))

;; NFT Metadata
(define-read-only (get-nft-meta)
  (ok {name: "First Ever Hiro Hackathon Winner", uri: "https://ipfs.io/ipfs/QmXTeyFsiCGsB6st5FTbvc78RkXG8hKo5SxtCN8cv8ity3/hiro-first-hackathon.webm", mime-type: "video/webm",
        hash: "e4ce55dd89113b846c4d43f7018f66e57e7b12d6af960e2a143f91457d27e1f0"}))

;; Internal - distribute NFTs
(map mint initial-members)

;; Internal - Mint an NFT
(define-private (mint (owner principal))
    (match (nft-mint? hiro-hackathon-winner-2021 (unwrap! (index-of initial-members owner) (err {code: u404})) owner)
      success
        (ok success)
      error (err {code: error})))

;; Internal - is the user an owner
(define-private (is-owner (token-id uint) (user principal))
  (is-eq user
    ;; if no owner, return false
    (unwrap! (nft-get-owner? hiro-hackathon-winner-2021 token-id) false)))