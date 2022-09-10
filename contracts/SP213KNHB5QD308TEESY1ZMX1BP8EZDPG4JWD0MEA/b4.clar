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