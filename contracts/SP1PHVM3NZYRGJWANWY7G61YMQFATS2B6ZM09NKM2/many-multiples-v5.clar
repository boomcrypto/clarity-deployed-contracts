(define-private (collection-bid (collection-id (string-ascii 256)) (amount uint))
    (begin
        (try! (contract-call? .multiples-v4 collection-bid collection-id amount))
        (ok true)
    )
)

(define-public (many-collection-bid (collection-id (string-ascii 256)) (amount uint) (units uint))
    (let (
        (collections (contract-call? .string-lists lookup collection-id (- units u1)))
        (amounts (contract-call? .lists lookup amount (- units u1)))
    )
        (print (map collection-bid collections amounts))
        (ok true)
    )
)

(define-private (multiple-bid (collection-id (string-ascii 256)) (amount uint) (ids (list 5000 uint)) (trait (string-ascii 256)))
    (begin
        (try! (contract-call? .multiples-v4 multiple-bid collection-id amount ids trait))
        (ok true)
    )
)

(define-public (many-multiple-bid (collection-id (string-ascii 256)) (amount uint) (ids (list 5000 uint)) (units uint) (trait (string-ascii 256)))
    (let (
        (collections (contract-call? .string-lists lookup collection-id (- units u1)))
        (lists (contract-call? .list-o-lists lookup ids (- units u1)))
        (amounts (contract-call? .lists lookup amount (- units u1)))
        (trait-list (contract-call? .string-lists lookup trait (- units u1)))
    )
        (print (map multiple-bid collections amounts lists trait-list))
        (ok true)
    )
)