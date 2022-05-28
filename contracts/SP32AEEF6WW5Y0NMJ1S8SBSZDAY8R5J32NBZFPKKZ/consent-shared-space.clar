
(define-map message-directory {hash: (buff 32), parties: (list 2 principal)} {is-consented-to: bool, content: (buff 50)})


(define-public (register-message (content (buff 50)) (second-party principal))
  (let
    (
      (hash (sha256 content))
    )
    (asserts! (is-eq contract-caller tx-sender) (err 401))
    (asserts! (map-insert message-directory {hash: hash, parties: (list tx-sender second-party)} {is-consented-to: false, content: content}) (err 403))
    (ok hash)))


(define-public (consent (hash (buff 32)) (first-party principal))
  (let
    ((message (unwrap! (map-get? message-directory {hash: hash, parties: (list first-party tx-sender)}) (err 404))))
    (asserts! (is-eq contract-caller tx-sender) (err 401))
    (map-set message-directory {hash: hash, parties: (list first-party tx-sender)} (merge message {is-consented-to: true}))
    (print (get content message))
    (ok true)))
