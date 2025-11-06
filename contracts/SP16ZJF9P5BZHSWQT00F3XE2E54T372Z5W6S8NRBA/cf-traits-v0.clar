(define-trait wrapper-trait
  (
    ;; Transfer from the caller to a new principal
    (router-wrapper ((string-ascii 128) (buff 4096)) (response bool uint))
  )
)

;; (define-map policies {client-id: (buff 32), policy: uint} {
;;     active: bool,
;;     type: (string-ascii 32),
;;     signers: (list 35 (buff 33)),
;;     threshold: uint,
;;     transaction: (optional { wrapper: principal, function: (string-ascii 32)}), 
;;     transfer: (optional { max-amount: uint, token: principal, recipients: (optional (list 50 principal))}),
;; })