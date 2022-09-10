;; Constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.1") ;; Version string
(define-constant MANPAGE "https://www.bitfari.org/man/burn-land-v01") ;; Smart Contract Manual

;; Errors
;; 
(define-constant ERR_NOT_AUTHORIZED (err u401)) ;;: Not authorized for the operation
 
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

;; BURNING AND DELETING
;; Burns token + mappings
;; @returns bool or err
(define-public (burn-all (token-id uint))
    (begin
      (try! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 burn token-id ))
      (unwrap-panic (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 delete-redpill token-id ))
     ;; (unwrap-panic (as-contract contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 delete-transfer-utility token-id ))
     ;; (unwrap-panic (as-contract delete-place 
         ;;  (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 get-osm token-id)
         ;; (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.web4 get-type token-id)))
     (ok true)))