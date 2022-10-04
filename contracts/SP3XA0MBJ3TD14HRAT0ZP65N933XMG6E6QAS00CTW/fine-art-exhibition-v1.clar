;; exhibit

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token exhibits uint)

;; Constants
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-invalid-start (err u500))
(define-constant err-invalid-end (err u501))

;; Internal variables
(define-data-var last-exhibition-id uint u0)
(define-data-var current-exhibition-id uint u0)

(define-map exhibitions uint {start: uint, end: uint, description: (string-ascii 80)})
(define-map exhibit-details {exhibition-id: (optional uint), id: uint} {token-uri: (optional (string-ascii 256)), art-owner: (optional principal)})

(define-public (create-exhibition (start uint) (end uint) (description (string-ascii 80)))
  (let ((exhibition-id (+ u1 (var-get last-exhibition-id))))
    (asserts! (>= start block-height) err-invalid-start)
    (asserts! (> end start) err-invalid-end)
    (map-insert exhibitions exhibition-id {start: start, end: end, description: description})
    (ok exhibition-id)))

;; define exhibits for an exhibition. Without an exhibition-id the art nft is a permanent exhibit
(define-public (put-on-show (exhibition-id (optional uint)) (id uint) (art-nft-id uint) (art-nft-contract <nft-trait>))
  (let ((token-uri (unwrap! (contract-call? art-nft-contract get-token-uri art-nft-id) err-not-found))
        (art-owner (unwrap! (contract-call? art-nft-contract get-owner art-nft-id) err-not-found)))
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-set exhibit-details {exhibition-id: exhibition-id, id: id} {token-uri: token-uri, art-owner: art-owner})
    (ok true)))

(define-public (inaugurate (exhibition-id uint))
  (let ((exhibition (unwrap! (map-get? exhibitions exhibition-id) err-not-found)))
    (asserts! (>= block-height (get start exhibition)) err-invalid-start)
    (asserts! (< block-height (get end exhibition)) err-invalid-end)
    (var-set current-exhibition-id exhibition-id)
    (print {
      notification: "token-metadata-update",
      payload: {
        contract-id: (as-contract tx-sender),
        token-class: "nft"}})
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (nft-transfer? exhibits id sender recipient)))

(define-public (transfer-many (details (list 21 {id: uint, from: principal, to: principal})))
  (fold check-err (map trnsfr details) (ok true)))

(define-private (trnsfr (details {id: uint, from: principal, to: principal}))
  (let ((sender (get from details)))
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (nft-transfer? exhibits (get id details) sender (get to details))))

(define-private (check-err (next (response bool uint)) (result (response bool uint)))
  (match result
    value next
    error result))


;; Burn
(define-public (burn (id uint))
  (begin 
    (asserts! (is-owner id tx-sender) err-not-authorized)
    (nft-burn? exhibits id tx-sender)))

;; read-only functions
(define-read-only (get-last-token-id)
  (ok u21))

(define-read-only (get-token-uri (id uint))
  (match (get-art id)
    details (ok (get token-uri details))
    (ok none)))
  
(define-read-only (get-art (id uint))
  (let ((exhibition-id (var-get current-exhibition-id))
        (exhibition (unwrap! (map-get? exhibitions exhibition-id) none)))
    (asserts! (<= block-height (get end exhibition)) none)
    (match (map-get? exhibit-details {exhibition-id: (some exhibition-id), id: id})
      details (some details)
      (map-get? exhibit-details {exhibition-id: none, id: id}))))

(define-read-only (get-current-exhibition)
  (let ((exhibition-id (var-get current-exhibition-id))
        (exhibition (unwrap! (map-get? exhibitions exhibition-id) none)))
    (some (merge exhibition {exhibition-id: exhibition-id}))))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? exhibits token-id)))

(define-read-only (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? exhibits token-id) false)))

(define-read-only (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? exhibits id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; Minting
(define-private (mint-all)
  (begin
    (map mint-many-iter (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21))
    (ok true)))
    
(define-private (mint-many-iter (id uint))
  (nft-mint? exhibits id tx-sender))

(mint-all)