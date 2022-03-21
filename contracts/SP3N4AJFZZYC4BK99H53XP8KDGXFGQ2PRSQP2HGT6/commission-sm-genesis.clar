(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-public (pay (ft-trait <ft-trait>) (id uint) (price uint))
    (begin
        (try! (contract-call? ft-trait transfer (/ (* price u6) u100) tx-sender 'SPZRAE52H2NC2MDBEV8W99RFVPK8Q9BW8H88XV9N none)) ;; artist
        (try! (contract-call? ft-trait transfer (/ (/ (* price u20) u5) u1000) tx-sender 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW none)) ;; jim
        (try! (contract-call? ft-trait transfer (/ (/ (* price u20) u5) u1000) tx-sender 'SP1CS4FVXC59S65C3X1J3XRNZGWTG212JT7CG73AG none)) ;; dash
        (try! (contract-call? ft-trait transfer (/ (/ (* price u20) u5) u1000) tx-sender 'SPZRAE52H2NC2MDBEV8W99RFVPK8Q9BW8H88XV9N none)) ;; cx
        (try! (contract-call? ft-trait transfer (/ (/ (* price u20) u5) u1000) tx-sender 'SP2M92VAE2YJ1P5VZ1Q4AFKWZFEKDS8CDA1KVFJ21 none)) ;; pp
        (try! (contract-call? ft-trait transfer (/ (/ (* price u20) u5) u1000) tx-sender 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6 none)) ;; mijoco
        (try! (contract-call? ft-trait transfer (/ (* price u2) u100) tx-sender 'SP1P89TEC03E29V5MYJBSCC8KWR1A243ZG2R8DYB1 none)) ;; marketplace
        (ok true)
    )
)
