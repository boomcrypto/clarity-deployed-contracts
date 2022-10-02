(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP28HPCDPVQ40JVQ1C52MQ23RPKBYGFHCR3NSAHX9))
                (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2ETVY1D90HJQEQ7Z6X8N3C5DRG7XVQ5N3ZBKV6P))
                (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2XMYYK70WCW2V0VZE3ZW04MKN53KA1352GHVWQP))
                (ok true)
        )
        (ok true)
    )
)

(define-public (set-commission (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission amount)
        (ok true)
    )
)

(define-public (set-commission-address (address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission-address address)
        (ok true)
    )
)