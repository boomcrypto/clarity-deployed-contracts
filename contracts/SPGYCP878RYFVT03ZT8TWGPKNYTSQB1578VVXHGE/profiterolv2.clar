;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-postconditions (err u20021))

;; Define data maps
(define-map authorized-users principal bool)
(define-map profits principal uint)

;; Define data var for total profit
(define-data-var total-profit uint u0)

;; Helper functions
(define-private (is-contract-owner)
  (is-eq tx-sender contract-owner))

(define-private (is-authorized)
  (or (is-contract-owner) (default-to false (map-get? authorized-users tx-sender))))

(define-private (update-profit (profit uint))
  (let ((current-profit (default-to u0 (map-get? profits tx-sender))))
    (map-set profits tx-sender (+ current-profit profit))
    (var-set total-profit (+ (var-get total-profit) profit))))

;; Access control functions
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (ok (map-set authorized-users user true))))

(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (ok (map-delete authorized-users user))))

;; Swap strategies
(define-public (strw1 (amt-in uint))
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

(define-public (strw2 (amt-in uint))
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

(define-public (strr1 (amt-in uint))
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

(define-public (strr2 (amt-in uint))
  (begin
    (asserts! (is-authorized) err-not-authorized)
    (let (
        (swap1 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap amt-in
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (swap2 (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap (get amt-out swap1)
                      'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                      'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)))
        (swap3 (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 do-swap (get amt-out swap2)
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token
                      'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-share-fee-to)))
        (profit (- (get amt-out swap3) amt-in))
        )
      (asserts! (> profit u0) err-postconditions)
      (update-profit profit)
      (ok profit))))

;; Read-only function to get profits (only callable by contract owner)
(define-read-only (get-profit (user principal))
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (ok (default-to u0 (map-get? profits user)))))

;; Read-only function to get total profits (only callable by contract owner)
(define-read-only (get-total-profit)
  (begin
    (asserts! (is-contract-owner) err-owner-only)
    (ok (var-get total-profit))))