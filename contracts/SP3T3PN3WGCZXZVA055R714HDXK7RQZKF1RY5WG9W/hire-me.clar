;; Applying for https://boards.greenhouse.io/trustmachines/jobs/4320128004
;; Smart Contract Developer at Trust Machines
;; Nikos Baxevanis

;; Usage:
;; >> (contract-call? .hire-me hire-me)
;; (ok "hired")

;; constants
;;
(define-constant message "hired")

;; data maps and vars
;;

;; public functions
;;
(define-public (hire-me) (ok message))

;; private functions
;;
