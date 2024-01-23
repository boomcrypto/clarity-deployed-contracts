(use-trait ft-trait 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.ft-trait.ft-trait)

(define-public
  (batchmint-and-set-owner
   (address <ft-trait>)
   (recipient principal)
   (owner principal)
   (users (list 1000 (tuple (user principal) (amt uint)) )))

  (let ((supply (unwrap-panic (contract-call? address get-max-supply)))
       (spent  (fold sum users u0))
       (left   (- supply spent)))

    (fold do-batchmint users address)
    (unwrap-panic (contract-call? address mint left recipient))
    (contract-call? address set-owner owner)))

(define-public
  (batchmint
   (address <ft-trait>)
   (users (list 1000 (tuple (user principal) (amt uint)) )))

  (ok (fold do-batchmint users address) ))

(define-private
  (sum
   (entry (tuple (user principal) (amt uint)))
   (total uint))
   (+ total (get amt entry)))

(define-private
  (do-batchmint
   (entry (tuple (user principal) (amt uint)))
   (address <ft-trait>))

  (begin
    (unwrap-panic (contract-call? address mint (get amt entry) (get user entry)))
    address) )
