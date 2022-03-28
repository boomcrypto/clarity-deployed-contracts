(define-constant CONTRACT-OWNER tx-sender)
(define-map ice-machine-address bool principal)

(define-public (pull-pop (id uint) (owner principal))
  (begin
    (asserts! (called-from-ice-machine) ERR-NOT-AUTHORIZED)
    (try! (as-contract (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops transfer id tx-sender owner)))
    (ok true)))

(define-public (push-pop (id uint))
  (begin
    (asserts! (called-from-ice-machine) ERR-NOT-AUTHORIZED)
    (try! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops transfer id tx-sender (as-contract tx-sender)))
    (ok true)))

    
;; Manage the unlock
(define-private (called-from-ice-machine)
  (is-eq contract-caller (unwrap! (map-get? ice-machine-address true) false)))

;; can only be called once
(define-public (set-ice-machine-address)
  (begin
    (asserts! (map-insert ice-machine-address true tx-sender) ERR-MACHINE-ALREADY-SET)
    (ok (print tx-sender))))

(define-constant ERR-MACHINE-ALREADY-SET (err u504))
(define-constant ERR-NOT-AUTHORIZED (err u401))