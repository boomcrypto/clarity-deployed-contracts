
;; sws-token-01
;; we implement the sip-010
;; In mainnet use https://explorer.stacks.co/txid/SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF.sip-10-ft-standard

;; for testnet
(impl-trait 'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF.sip-010-v0a.ft-trait)
;;(impl-trait .sip-010.ft-trait)


;; constants
;;
(define-fungible-token narangd-token)

;; (define-constant contract-owner 'SP23DAB333A5CPFXNK13E5YMX1DZJ07112QNZEBCF)
(define-constant contract-owner 'SP3WZJAY2A398KKBT73M92PAGP5ZD2GE3JKC6KSSP)
(define-constant not-owner-err (err u63))

(define-read-only (get-balance-of (owner principal))
  (ok (ft-get-balance narangd-token owner))
)

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply narangd-token))
)

;; returns the token name
(define-read-only (get-name)
  (ok "Narangd Token")
)

(define-read-only (get-symbol)
  (ok "NAR")
)

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u3)  ;; because we can, and interesting for testing wallets and other clients
)

(define-read-only (get-token-uri)
  (ok (some u"empty"))
)

;; data maps and vars
;;

;; private functions
;;
(define-public (owner-mint (account principal) (amount uint))
  (if (<= amount u0)
    (err u0)
    (begin
      (asserts! (is-eq tx-sender contract-owner) not-owner-err)
      (ft-mint? narangd-token amount account)
    )
  )
)

;; public functions
;;

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if (>= (ft-get-balance narangd-token sender) amount)
     (begin
       (print "narangd.transfer")
       (print amount)
       (print tx-sender)
       (print recipient)
       (asserts! (is-eq tx-sender sender) (err u255)) ;; too strict?
       (print (ft-transfer? narangd-token amount sender recipient))
       )
     (err u0)
   )
)

(ft-mint? narangd-token u100000000000000 'SP3WZJAY2A398KKBT73M92PAGP5ZD2GE3JKC6KSSP)
(ft-mint? narangd-token u100000000000000 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
(ft-mint? narangd-token u100000000000000 'SP3C9VW89DFE6HY6054Q5BN0XZWDFTWV8FPTGT8JK)
