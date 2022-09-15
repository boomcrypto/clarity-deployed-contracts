;;  coverpage.btc distribution 
;;; Schedule COVER-D-00

;;  coverpage.btc distributes the budget for ads placed on Bitfari's cover page to users
;;  ad budget is distributed according to verified app usage
 
;; 
;;  Disbursements sent in FARI as appreciation for users's attention.
;;  This network has no block winner, just proportional distributions 
;;
;;  This file was automatically generated. Part of Bitfari.
;; ------------------------------------------------------------------------------------------------------------------


;; Section 1. Constants
;;
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.1") ;; version string
(define-constant DISTRIBUTION u0) ;; distribution sequential
(define-constant MANPAGE "https://www.bitfari.org/man/cover-v01") ;; smart contract manual

;; Section 2. Execute Distribution
;; 

;; Transfer FARI, STX, USDA or xBTC according to schedule
;; Distribute ad budgets proportionally to users according to actions and viewership

;; TODO: Integrate with vault for weekly payments via earnings page 
;; TODO: Update SC to pay distributions on any web page or web app 

 (try! (contract-call? 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn
                        transfer u1000 tx-sender 'SP3PJMX71MZXWSKB175VG79AKAZE7BA5S3WFHQC8R none))

;; End of coverpage.btc distribution 
;; Schedule COVER-D-00