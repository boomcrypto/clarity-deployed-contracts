(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u2) u100) tx-sender 'SPZRAE52H2NC2MDBEV8W99RFVPK8Q9BW8H88XV9N))
        (try! (stx-transfer? (/ (* price u2) u100) tx-sender 'SP2FTZQX1V9FPPNH485Z49JE914YNQYGT4XVGNR4S))
        (try! (stx-transfer? (/ (* price u2) u100) tx-sender 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW))
        (try! (stx-transfer? (/ (* price u2) u100) tx-sender 'SP1P89TEC03E29V5MYJBSCC8KWR1A243ZG2R8DYB1))
        (try! (stx-transfer? (/ (* price u6) u1000) tx-sender 'SP2S6MCR2K3TYAC02RSYQ74RE9RJ3Q0EV3FYFGKGB))
        (try! (stx-transfer? (/ (* price u14) u1000) tx-sender 'SP2M92VAE2YJ1P5VZ1Q4AFKWZFEKDS8CDA1KVFJ21))
        (ok true)))