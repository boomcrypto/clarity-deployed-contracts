;;Contract to collect and subscribe in batches for spoints system
(use-trait subscriber-trait .subscriber-trait.subscriber-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-data-var current-item uint u0)
(define-data-var current-collect uint u0)

(define-private (collect (subscriber <subscriber-trait>))
    (let (
        (amount (var-get current-collect))
        (to-collect (unwrap-panic (contract-call? subscriber get-collect tx-sender)))
        (item (var-get current-item))
        )
        (if (is-eq amount u0) 
            (ok true)
            (ok (if (< amount to-collect) 
                (begin (unwrap-panic (contract-call? subscriber collect item amount)) (var-set current-collect u0)) 
                (begin (unwrap-panic (contract-call? subscriber collect item to-collect)) (var-set current-collect (- amount to-collect)))
            )))))

(define-public (subscribe (subscriber <subscriber-trait>) (lookup-table <lookup-trait>) (item uint)) 
    (ok (unwrap-panic (contract-call? subscriber subscribe lookup-table item))))

(define-public (admin-unsubscribe (subscriber <subscriber-trait>) (lookup-table <lookup-trait>) (item uint)) 
    (ok (unwrap-panic (contract-call? subscriber admin-unsubscribe lookup-table item))))

(define-public (collect-multi (subscribers (list 50 <subscriber-trait>)) (amount uint) (item uint))
    (begin 
        (var-set current-item item)
        (var-set current-collect amount)
        (map collect subscribers)
        (ok (var-get current-collect))))

(define-public (subscribe-all (subscribers (list 1000 <subscriber-trait>)) (tables (list 1000 <lookup-trait>)) (items (list 1000 uint))) 
    (ok (map subscribe subscribers tables items)))