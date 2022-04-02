(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP28HPCDPVQ40JVQ1C52MQ23RPKBYGFHCR3NSAHX9)) ;;Save the whales
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2ETVY1D90HJQEQ7Z6X8N3C5DRG7XVQ5N3ZBKV6P)) ;;DAO
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2XMYYK70WCW2V0VZE3ZW04MKN53KA1352GHVWQP)) ;;Team
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)) ;;Marketplace
        (ok true)))