;; mint fungible tokens via Dapparatus 
;; with a fixed max supply and pass all to sender 
(define-constant sender 'SP1TA84JTP4YRFWBK7PYKBA33H3YB60XP654RAR7M) 
(define-fungible-token Zen u21000000) 
(begin (ft-mint? Zen u21000000 sender))