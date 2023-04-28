;; .derupt-feed Contract
(define-constant APP_DEV tx-sender)

;; Error constants
(define-constant unauthorized-user (err 100))
(define-constant notfound (err 101))

;; Core contract reference
(define-data-var derupt-core-contract principal (as-contract tx-sender))

;; Cost map
(define-map cost principal { chime-cost: (optional uint), mine-cost: (optional uint), like-cost: (optional uint), dislike-cost: (optional uint) })

;; Setter for costs
(define-public (set-cost (chime-cost (optional uint)) (mine-cost (optional uint)) (like-cost (optional uint)) (dislike-cost (optional uint))) 
  (begin 
    (asserts! (is-eq APP_DEV tx-sender) unauthorized-user)
      (match chime-cost value (map-set cost tx-sender 
        { 
            chime-cost:   (some value), 
            mine-cost:   (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound),
            like-cost:   (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound),
            dislike-cost:  (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound) 
        }) false)
      (match mine-cost value (map-set cost tx-sender 
        { 
            chime-cost:   (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound),
            mine-cost:  (some value), 
            like-cost:   (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound),
            dislike-cost:   (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound),
        }) false)
      (match like-cost value (map-set cost tx-sender 
        { 
            chime-cost:   (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound),
            mine-cost:   (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound),  
            like-cost:   (some value), 
            dislike-cost:   (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound) 
        }) false)
      (match dislike-cost value (map-set cost tx-sender 
        {
            chime-cost:   (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound), 
            mine-cost:   (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound), 
            like-cost:   (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound), 
            dislike-cost:   (some value) 
        }) false)
      (ok true)
  )
)

;; Get All Costs
(define-read-only (view-cost) 
  (ok (map-get? cost APP_DEV))
)

;; Get Costs Individually
(define-read-only (get-chime-amount)
  (ok (unwrap! (unwrap! (get chime-cost (map-get? cost APP_DEV)) notfound) notfound))
)

(define-read-only (get-mine-amount)
  (ok (unwrap! (unwrap! (get mine-cost (map-get? cost APP_DEV)) notfound) notfound))
)

(define-read-only (get-like-amount)
  (ok (unwrap! (unwrap! (get like-cost (map-get? cost APP_DEV)) notfound) notfound))
)

(define-read-only (get-dislike-amount)
  (ok (unwrap! (unwrap! (get dislike-cost (map-get? cost APP_DEV)) notfound) notfound))
)

;; Validates core-contract
(define-read-only (validate-core-contract (input-core-contract principal)) 
  (if (is-eq input-core-contract (var-get derupt-core-contract)) 
    (ok true)
    (ok false)
  )
)

;; Setter for derupt core contract address (only callable by APP_DEV)
(define-public (set-derupt-core-contract (new-core-contract principal))
  (begin
    (asserts! (is-eq tx-sender APP_DEV) unauthorized-user)    
    (ok (var-set derupt-core-contract new-core-contract))
  )
)

;; Get .derupt-core contract address
(define-read-only (get-derupt-core-contract) 
    (ok (var-get derupt-core-contract))
)

;; Log Send Messages
(define-public (log-send-message 
    (content (string-utf8 256)) (attachment-uri (optional (string-utf8 256))) 
    (thumbnail-uri (optional (string-utf8 256))) (reply-to (optional (string-utf8 256))) 
    (cityName (string-ascii 10)) (alt-origin (optional (string-utf8 256)))
    (extras 
        (optional 
            (tuple 
                (arg0 (optional (string-utf8 256)))
                (arg1 (optional (string-utf8 256))) 
                (arg2 (optional (string-utf8 256))) 
                (arg3 (optional (string-utf8 256)))   
                (arg4 (optional (string-utf8 256))) 
                (arg5 (optional (string-utf8 256))) 
                (arg6 (optional (string-utf8 256)))
                (arg7 (optional (string-utf8 256))) 
                (arg8 (optional (string-utf8 256))) 
                (arg9 (optional (string-utf8 256)))
            )
        )
    )
)
  (begin
    (asserts! (is-eq contract-caller (var-get derupt-core-contract)) unauthorized-user)
    (print { event: "send-message", content: content, publisher: tx-sender, attachment-uri: attachment-uri, thumbnail-uri: thumbnail-uri, reply-to: reply-to, cityName: cityName, alt-origin: alt-origin, extras: extras })
    (ok true)
  )
)

;; Default Costs
(map-insert cost APP_DEV { chime-cost:  (some u10000), mine-cost:  (some u100000), like-cost:  (some u100000000), dislike-cost:  (some u100000000) })