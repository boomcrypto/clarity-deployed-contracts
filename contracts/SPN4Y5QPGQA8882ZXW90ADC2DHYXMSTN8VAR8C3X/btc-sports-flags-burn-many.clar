(define-public (burn-many (ids (list 200 uint)))
    (begin 
        (ok (map burn ids))))

(define-public (burn (id uint))
    (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft burn id))