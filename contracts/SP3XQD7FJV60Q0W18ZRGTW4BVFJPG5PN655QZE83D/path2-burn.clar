;; Define data variables for swap amounts
(define-data-var swap1-amount uint u1000000)
(define-data-var swap2-amount uint u6000000)
(define-data-var swap3-amount uint u9500000)
(define-data-var swap4-amount uint u4000000)
(define-data-var swap5-amount uint u5000000)

;; Contract owner check
(define-constant contract-owner tx-sender)

;; Getter functions for swap amounts
(define-read-only (get-swap1-amount)
  (var-get swap1-amount))

(define-read-only (get-swap2-amount)
  (var-get swap2-amount))

(define-read-only (get-swap3-amount)
  (var-get swap3-amount))

(define-read-only (get-swap4-amount)
  (var-get swap4-amount))

(define-read-only (get-swap5-amount)
  (var-get swap5-amount))

;; Setter functions for swap amounts (only contract owner can call)
(define-public (set-swap1-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set swap1-amount new-amount))))

(define-public (set-swap2-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set swap2-amount new-amount))))

(define-public (set-swap3-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set swap3-amount new-amount))))

(define-public (set-swap4-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set swap4-amount new-amount))))

(define-public (set-swap5-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set swap5-amount new-amount))))

;; Main swap function using the configurable amounts
(define-public (swap-3)
(begin
  (let ((swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                         do-swap (var-get swap1-amount) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u7 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-roo (var-get swap1-amount) (get amt-out swap1))))
  (let ((swap2 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                         do-swap (var-get swap2-amount) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token  
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u3
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-welsh (var-get swap2-amount) (get amt-out swap2))))
  (let ((swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                         do-swap (var-get swap3-amount) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u5
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh (var-get swap3-amount) (get amt-out swap3))))
  (let ((swap4 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                         do-swap (var-get swap4-amount) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u9
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.up-dog 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-updog (var-get swap4-amount) (get amt-out swap4))))
  (let ((swap5 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 
                         do-swap (var-get swap5-amount) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token 
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core mint u4
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                         'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-cha (var-get swap5-amount) (get amt-out swap5))))
  (ok true)))