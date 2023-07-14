;; Contract for registering a new BNS name.
;; 
;; This contract follows the "single-tx" registration flow,
;; instead of using separate name-preorder and name-register
;; transactions. Under the hood, both contract methods are called.

;; Register a new name
;; 
;; This function is designed to be as cost-efficient as possible. Because of this,
;; it requires all params (like price, hashed name) to be pre-computed.
;; 
;; To compute the `hashed-fqn` parameter, use:
;; `hash160(${name}.${namespace}${salt})`
(define-public (name-register 
    (name (buff 48)) 
    (namespace (buff 20)) 
    (amount uint)
    (hashed-fqn (buff 20))
    (salt (buff 20))
  )
  (begin
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-preorder hashed-fqn amount))
    (try! (contract-call? 'SP000000000000000000002Q6VF78.bns name-register namespace name salt 0x))
    (print {
      topic: "name-registered",
      name: name,
      namespace: namespace,
      amount: amount,
    })
    (ok true)
  )
)
