(define-map block-miners {block-number: uint} {miner: principal})

(define-constant ERR-BLOCK-SEQUENCE-INVALID u1000)

(define-data-var current-block-ht uint u0)

(define-private (register-block (block-number uint)) 
  (let ((next-block (+ (var-get current-block-ht) u1)))
    (asserts! (and (is-eq block-number next-block) (<= next-block block-height)) 
      (err ERR-BLOCK-SEQUENCE-INVALID))
    (let 
      ((miner (default-to (as-contract tx-sender) (get-block-info? miner-address next-block))))
      (map-set block-miners {block-number: next-block} {miner: miner})
      (var-set current-block-ht next-block)
      (ok (print "Added block successfully")))))

(define-public (register-blocks (block-numbers (list 750 uint))) 
  (begin
    (map register-block block-numbers)
    (ok true)))

