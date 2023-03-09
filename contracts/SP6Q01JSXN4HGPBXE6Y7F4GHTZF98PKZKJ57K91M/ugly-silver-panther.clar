(define-public (get-name (new-address principal)) 
  (let ((address-bns-name (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal new-address)) 
    (address-bnsx-name (contract-call? 'SP1JTCR202ECC6333N7ZXD7MK7E3ZTEEE1MJ73C60.bnsx-registry get-primary-name new-address)))
    (ok true)))