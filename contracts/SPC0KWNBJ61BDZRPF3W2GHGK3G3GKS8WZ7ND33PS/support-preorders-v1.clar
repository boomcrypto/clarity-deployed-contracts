;; claim fees and preorder the name again
(define-public (claim-preorder (old-hashed-salted-fqn (buff 20)) (hashed-salted-fqn (buff 20)) (owner principal) (new-owner principal))
  (begin
    (try! (contract-call? .ryder-handles-controller-v1 claim-fees old-hashed-salted-fqn owner))
    (contract-call? .ryder-handles-controller-v1 name-preorder hashed-salted-fqn)))

;; register the preordered name and transfer to the new owner
(define-public (register-transfer (namespace (buff 20))
                              (name (buff 48))                            
                              (salt (buff 20))
                              (approval-signature (buff 65))
                              (owner principal)
                              (new-owner principal)
                              (zonefile-hash (buff 20)))
  (begin
    (try! (contract-call? .ryder-handles-controller-v1 name-register namespace name salt approval-signature owner zonefile-hash))
    (to-bool-response (contract-call? 'SP000000000000000000002Q6VF78.bns name-transfer namespace name new-owner (some zonefile-hash)))))
                              

;; convert response to standard bool response with uint error
;; (response bool int) (response bool uint)
(define-private (to-bool-response (value (response bool int)))
    (match value
           success (ok success)
           error (err (to-uint error))))