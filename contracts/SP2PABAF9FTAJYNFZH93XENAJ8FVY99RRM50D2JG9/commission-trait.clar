;; @contract Trait definition for commission
;; @version 1
(define-trait commission-trait
    (
        ;; @desc pay commission for a service
        ;; @param id; identifies the relevant object from the caller
        ;; @param price; price for service    
        (pay (uint uint) (response bool uint))
    )
)