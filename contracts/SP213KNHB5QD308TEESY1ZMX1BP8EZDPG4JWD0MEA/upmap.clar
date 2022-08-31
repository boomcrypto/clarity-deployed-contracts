;; Digital Land NFT Update Tool
;; This file is part of Bitfari

;; This SC updates a digital land NFT token and updates its mappings.
;; The tool can fix nfts that are not showign images or have outdated json pointers. 

;; This SC will serve as a basis for DL NFT migrations or updates to other versions
;; or ecosystems. This smart contract can ONLY be executed by the owner of the NFT.

;; Supports OSM relations, ways, nodes, etc. All hooks and channels supported.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.1") ;; Version string
(define-constant MANPAGE "https://www.bitfari.org/man/mapping-update-v01") ;; Smart Contract Manual

;; Errors
;; 
(define-constant ERR_NOT_AUTHORIZED (err u401)) ;;: Not authorized for the operation
(define-constant ERR_INVALID_ID (err u414)) ;;::::: invalid nft id 

;; Read-only functions
;;

;; Returns version of the 
;; digital land nft contract
;; @returns string-ascii
(define-read-only (get-version) 
    VERSION)

;; Returns the smart contract 
;; manpage - a manual
;; @returns url/string-ascii
(define-read-only (get-man) 
    MANPAGE)

;; ;; Token Hooks and API Updates
;; ;; @returns bool 
(define-public (update-hooks (token-id uint) (osm-id uint) 
 (type (string-ascii 10)) (landlord principal)
 (json (string-ascii 256)) (geodata (string-ascii 256))
 (polygon (string-ascii 256)) (cover-photo (string-ascii 256))
 (dash-photo (string-ascii 256)) (management principal)
 (btc-treasury (string-ascii 64)) (direct (string-ascii 256))
 (apps (string-ascii 256)) (fari (string-ascii 256)) (gov (string-ascii 256))
 (mil (string-ascii 256)) (pol (string-ascii 256)) (official (string-ascii 256))
 (channels  (string-ascii 256)) (content (string-ascii 256))
 (itinerary (string-ascii 256)) (search (string-ascii 256)) (web2 (string-ascii 256))
 (social (string-ascii 256)) (statistics (string-ascii 256)))

  (begin  
  (asserts! (< token-id u2500) ERR_INVALID_ID) ;; only applicable to early tokens
  ;; in testnet the contract is called w65
  ;; in mainnet the contract is called web4
  (try! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 burn token-id ))
  (unwrap-panic (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 club-mint osm-id type landlord json geodata polygon cover-photo dash-photo management btc-treasury direct apps fari gov mil pol official channels content itinerary search web2 social statistics ))             
  (ok true)))