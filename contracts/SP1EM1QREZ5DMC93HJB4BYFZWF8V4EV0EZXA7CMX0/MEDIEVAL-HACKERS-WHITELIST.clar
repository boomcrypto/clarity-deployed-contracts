(define-map white-list principal bool)
(define-read-only (is-whitelisted? (caller principal))  
  (ok (map-get? white-list caller)))
  
(define-public (add-to-whitelist (address principal)) 
  (ok (map-set white-list address true)))