(define-data-var recipient principal tx-sender)

(define-public (transfer-many (ids (list 25 uint)) (user-recipient principal))
    (begin 
        (var-set recipient user-recipient)
        (ok (map transfer ids))))

(define-private (transfer (id uint))
    (contract-call? 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft transfer id tx-sender (var-get recipient)))