;; trait from project one-click-token

(use-trait sip-010-token .sip-010-v1a.sip-010-trait)

(define-trait initializable-farm-trait
  (
    (initialize (
      (string-ascii 32) (string-utf8 256)
       <sip-010-token> <sip-010-token> uint
       <sip-010-token> <sip-010-token> <sip-010-token> <sip-010-token> 
       (list 4 uint) (list 4 uint) (list 4 uint) 
       uint uint uint uint uint uint 
    ) (response uint uint))
  )
)

