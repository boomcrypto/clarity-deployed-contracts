;; CONTRACT ERROR
(define-constant ERR-NOT-CONTRACT-OWNER u401)
(define-constant ERR-PRODUCT-ID-EXIST u700)
(define-constant ERR-NOT-PRODUCT-OWNER u701)
(define-constant ERR-NOT-FOUND-PRODUCT-ID u702)
(define-constant ERR-PRODUCT-IS-INACTIVE u703)
(define-constant ERR-CAN-NOT-BUY-YOUR-OWN-PRODUCT u704)
(define-constant ERR-CAN-NOT-BUY-YOUR-THIS-PRODUCT-TWICE u705)
(define-constant ERR-CAN-NOT-REVIEW-PRODUCT-YOU-DONT-BUY u706)
(define-constant ERR-ALREADY-REVIEW-THIS-PRODUCT u708)
(define-constant ERR-REVIEW-ID-EXIST u709)
(define-constant ERR-COUPON-CODE-EXIST u710)


(define-constant ERR-COUPON-ALL-USED u805)
(define-constant NO-COUPON (concat "NO" "COUPON"))


;; CONTRACT CONSTANT
(define-constant CONTRACT_OWNER tx-sender)
(define-constant fee-basis-points u100) ;; 1%

;; CONTRACT VARIABLE
(define-data-var statistics {product-sale: uint, total-sale: uint, total-commission: uint} {product-sale: u0,total-sale: u0, total-commission: u0})
(define-data-var platform-wallet principal tx-sender)

;; ----------------------------------------------------------------
;; Maps
;; ----------------------------------------------------------------

;; list of products. After users buy products, they have to login to download the product's content.
;; Seller will have to upload product content like files, video via a dashboard. 
;; The product data will be saved on Gaia with Stacks.js
(define-map products { id: (string-ascii 256) } {
  name: (string-ascii 256),
  img: (string-ascii 256),
  description: (string-utf8 10000),
  seller: principal,
  price: uint,
  is-active: bool   
})
;; list of coupons of a buyer applying for a product 
(define-map coupons 
    { product-id: (string-ascii 256), seller: principal, code: (string-ascii 256) } 
    { discount-amount: uint, allowed-uses: uint, is-percentage: bool}
)

;; list of product ids by seller. 
(define-map product-ids-by-seller principal (list 2500 (string-ascii 256)) )

;; Buyers 

(define-map buyers { buyer: principal, product-id: (string-ascii 256) } { origin-price: uint, profit-price: uint} )

;; List of buyers of a products. If it reaches limit, tell the seller to create a new product
;; product-id -> [buyer]
(define-map buyer-ids-by-product (string-ascii 256) (list 2500 principal) )


;; list of reviews 
(define-map reviews 
    { product-id: (string-ascii 256), reviewer: principal} 
    { content: (string-ascii 256), star: uint}
)
;; product-id -> [reviewer]
(define-map reviewer-ids-by-product (string-ascii 256) (list 2500 principal) )


;; list of product that a user has bought 
(define-map customers principal (list 2500 (string-ascii 256)) )

;; ----------------------------------------------------------------
;; Public functions
;; ----------------------------------------------------------------

;; Create a new product 
(define-public (create-product (id (string-ascii 256) ) (name (string-ascii 256)) (description (string-utf8 10000)) (img (string-ascii 256)) (price uint) (is-active bool) )
        (let ( 
            (current-product-ids (get-product-ids-by-seller tx-sender)) 
            (new-ids (unwrap-panic (as-max-len? (append current-product-ids id) u2500) ))
            
        )
            (asserts! (is-none (map-get? products {id: id} )) (err ERR-PRODUCT-ID-EXIST)) 
            ;; #[allow(unchecked_data)]
            (map-set products {id: id} { name: name, description: description, price: price, seller: tx-sender, is-active: is-active, img: img })           
            ;; #[allow(unchecked_data)]
            (map-set product-ids-by-seller tx-sender new-ids)
            (ok true)
        ) 
)
;; Update a product 
(define-public (update-product (id (string-ascii 256)) (name (string-ascii 256)) (description (string-utf8 10000)) (img (string-ascii 256)) (price uint) (is-active bool) )
        (let ( 
            (product-seller-id (unwrap! (get-seller-address id ) (err ERR-NOT-FOUND-PRODUCT-ID))) 
        )
            ;; only product'owner can update the product
            (asserts! (is-eq product-seller-id tx-sender) (err ERR-NOT-PRODUCT-OWNER) )
            ;; #[allow(unchecked_data)]
            (map-set products {id: id} { name: name,  description: description, price: price, seller: tx-sender, is-active: is-active, img: img })           
            (ok true)
        ) 
)
;; Buy a product
(define-public (buy-product (product-id (string-ascii 256)))
        (let 
            (
                ;; make sure product is exist
                (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
                (product-price (get price product ))
            )
            ;; #[allow(unchecked_data)]
            (execute-buy-product product-id NO-COUPON product-price)
        )
)
(define-public (buy-product-with-coupon (product-id (string-ascii 256)) (code (string-ascii 256)))
        (let 
            (
              ;; make sure product is exist
              (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
              (product-price  (get price product ))      
              (seller (get seller product ))

              (coupon (get-coupon-details code product-id seller))
              (discount-amount (get discount-amount coupon))
              (allowed-uses (get allowed-uses coupon))
              (is-percentage (get is-percentage coupon))
              
              (new-product-price (if is-percentage
                    (- product-price (/ (* product-price discount-amount) u10000 ))
                    (- product-price discount-amount )
                )
              )
            )
            (asserts! (> allowed-uses u0) (err ERR-COUPON-ALL-USED))
            ;; minus the allowed-uses 
            ;; #[allow(unchecked_data)]
            (map-set coupons { product-id: product-id, seller: seller, code: code } 
                             { discount-amount: discount-amount, allowed-uses: (- allowed-uses u1), is-percentage: is-percentage })
            ;; #[allow(unchecked_data)]
            (execute-buy-product product-id code new-product-price)
        )
        
)

;; create coupon 
;; #[allow(unchecked_data)]
(define-public (create-coupon (product-id (string-ascii 256)) (code (string-ascii 256))
                            (allowed-uses uint) (discount-amount uint) (is-percentage bool)
 )
 (let ( 
            ;; make sure product is exist
            (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
            (product-name (get name product))
            (product-price (get price product ))
            (product-status (get is-active product ))
            (seller (get seller product ))

            (contract-address (as-contract tx-sender))
            (user-address tx-sender)
        )
            ;; make sure you're the owner of the product
            (asserts! (is-eq seller tx-sender) (err ERR-NOT-PRODUCT-OWNER))
            ;; make sure coupon's code for this product is not exist 
            (asserts! (is-none (map-get? coupons {seller: tx-sender, product-id: product-id, code: code} )) (err ERR-COUPON-CODE-EXIST)) 
            ;; set values for collections
            (map-set coupons {seller: tx-sender, product-id: product-id, code: code} { 
                        allowed-uses: allowed-uses, discount-amount: discount-amount, is-percentage: is-percentage
            })
            (ok true)
        ) 
)
;; update a coupon
;; #[allow(unchecked_data)]
(define-public (update-coupon (product-id (string-ascii 256)) (code (string-ascii 256))
                            (allowed-uses uint) (discount-amount uint) (is-percentage bool)
 )
 (let ( 
            ;; make sure product is exist
            (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
            (product-name (get name product))
            (product-price (get price product ))
            (product-status (get is-active product ))
            (seller (get seller product ))

            (contract-address (as-contract tx-sender))
            (user-address tx-sender)
        )
            ;; make sure you're the owner of the product
            (asserts! (is-eq seller tx-sender) (err ERR-NOT-PRODUCT-OWNER))

            ;; set values for collections
            (map-set coupons {seller: tx-sender, product-id: product-id, code: code} { 
                        allowed-uses: allowed-uses, discount-amount: discount-amount, is-percentage: is-percentage
            })
            
            (ok true)
        
        ) 
)

;; Add a review
;; #[allow(unchecked_data)]
(define-public (add-review (product-id (string-ascii 256)) (content (string-ascii 256)) (star uint))
        (let ( 
            ;; make sure product is exist
            (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
            (seller (get seller product))
            (product-status (get is-active product ))
            (product-name (get name product ))
            ;; make sure you already bought this product
            (buyer (unwrap! (get-buyer-receipt tx-sender product-id  ) (err ERR-CAN-NOT-REVIEW-PRODUCT-YOU-DONT-BUY) ) )    
            
            (current-reviewer-ids (get-reviewer-ids-by-product product-id)) 
            (new-ids (unwrap-panic (as-max-len? (append current-reviewer-ids tx-sender) u2500) ))
            
            (review (check-review-exist product-id tx-sender) )
            
        )
            ;; make sure you can only review 1 time for this product
            (asserts! (is-none review) (err ERR-ALREADY-REVIEW-THIS-PRODUCT))
            ;; ;; make sure review's id is not exist
            ;; (asserts! (is-none (map-get? reviews {product-id: id, reviewer: tx-sender} )) (err ERR-REVIEW-ID-EXIST)) 
            ;; make sure product's status is active
            (asserts! (is-eq product-status true) (err ERR-PRODUCT-IS-INACTIVE))
            (map-set reviews {product-id: product-id, reviewer: tx-sender} { content: content, star: star })           
            (map-set reviewer-ids-by-product product-id new-ids)
            (ok true)
        ) 
)
;; only for deployer
(define-public (withdraw-fund (receipt principal) (amount uint)) 
    (begin 
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR-NOT-CONTRACT-OWNER))
        ;; #[allow(unchecked_data)]
        (as-contract (stx-transfer? amount (as-contract tx-sender) receipt ))
    )
)

;; ----------------------------------------------------------------
;; Read only functions
;; ----------------------------------------------------------------

;; Get the seller of a product
(define-read-only (get-seller-address (product-id (string-ascii 256)) )
    (get seller (map-get? products { id: product-id }))
)
;; Get the seller of a product
(define-read-only (get-buyer-receipt (buyer principal) (product-id (string-ascii 256)) )
    (map-get? buyers { product-id: product-id, buyer: buyer })
)

;; Get all product ids from a buyer
(define-read-only  (get-products-by-buyer (buyer principal) )
    (default-to
            (list )
            (map-get? customers buyer) 
    ) 
)

;; Get buyer ids by a product 
(define-read-only (get-buyer-ids-by-product (product-id (string-ascii 256)))
    (default-to
    (list )
    (map-get? buyer-ids-by-product product-id) 
    )
)
;; Get product ids by seller 
(define-read-only (get-product-ids-by-seller (seller principal))
    (default-to
    (list )
    (map-get? product-ids-by-seller seller) 
    )
)

;; Get review ids by a product 
(define-read-only (get-reviewer-ids-by-product (product-id (string-ascii 256)))
    (default-to
    (list )
    (map-get? reviewer-ids-by-product product-id) 
    )
)

;; Check if this address review a product or not
(define-read-only (check-review-exist (product-id (string-ascii 256)) (reviewer principal) )
    (map-get? reviews { product-id: product-id, reviewer: reviewer})
)

;; Get Product's details by product-id 
(define-read-only (get-product-by-id (product-id (string-ascii 256)))
  (map-get? products { id: product-id })
)


;; Get coupon's details 
(define-read-only (get-coupon-details (code (string-ascii 256)) (product-id (string-ascii 256)) (seller principal) )
  (default-to
    { discount-amount: u0, allowed-uses: u0, is-percentage: true }
    (map-get? coupons { product-id: product-id, seller: seller, code: code } )
  )
)

(define-read-only (get-fee-basis-points) 
    (ok fee-basis-points)
)
(define-read-only (get-statistics) 
    (ok (var-get statistics))
)


;; ----------------------------------------------------------------
;; Private functions
;; ----------------------------------------------------------------

;; This function is used for both buy-product and buy-product-with-coupon function. We re-use some asserts and then transfer STX from buyer to seller.
(define-private (execute-buy-product (product-id (string-ascii 256)) (code (string-ascii 256)) (product-price uint) )    
    (let ( 
            ;; make sure product is exist
            (product (unwrap! (get-product-by-id product-id) (err ERR-NOT-FOUND-PRODUCT-ID) ))
            (product-name (get name product))
            (product-status (get is-active product ))
            
            (seller (get seller product ))
            (current-buyer-ids (get-buyer-ids-by-product product-id)) 

            (new-buyer-ids (unwrap-panic (as-max-len? (append current-buyer-ids tx-sender) u2500) ))
            
            
            (current-customer-ids (get-products-by-buyer tx-sender)) 
            (new-customer-ids (unwrap-panic (as-max-len? (append current-customer-ids product-id) u2500) ))

            (fee (/ (* product-price fee-basis-points) u10000 ))
            (price-after-fee (- product-price fee) )
            (contract-address (as-contract tx-sender))
            (user-address tx-sender)

            (current-statistics (var-get statistics))
            (current-sale (get total-sale current-statistics))
            (current-commission (get total-commission current-statistics))
            (current-product-sale-amount (get product-sale current-statistics))
        )
            ;; make sure product's status is active
            (asserts! (is-eq product-status true) (err ERR-PRODUCT-IS-INACTIVE))
            ;; you can't buy your own product :D 
            (asserts! (not (is-eq seller tx-sender)) (err ERR-CAN-NOT-BUY-YOUR-OWN-PRODUCT))
            ;; you can't buy this product twice 
            (asserts! (is-none (get-buyer-receipt tx-sender product-id  )) (err ERR-CAN-NOT-BUY-YOUR-THIS-PRODUCT-TWICE))

            (try! (stx-transfer? product-price user-address contract-address))
            ;; contract-owner send stx to seller after deducting the fee
            (try! (as-contract (stx-transfer? price-after-fee contract-address seller )))           
            ;; set values for collections
            (map-set buyers {buyer: user-address,  product-id: product-id} { origin-price: product-price, profit-price:  price-after-fee})      
            (map-set buyer-ids-by-product product-id new-buyer-ids)     
            (map-set customers tx-sender new-customer-ids)
            (var-set statistics {product-sale: (+ current-product-sale-amount u1), total-sale: (+ current-sale product-price), total-commission: (+ current-commission fee)})
            
            (ok true)
    )
)