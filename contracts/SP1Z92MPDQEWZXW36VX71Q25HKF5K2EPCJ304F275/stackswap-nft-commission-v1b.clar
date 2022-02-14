(define-constant WALLET_1 'SP3QSWXQQJ5BKCVZBY1BH3BPGVX4MZPRKKG8CBDGR) ;; Service Fee
(define-constant WALLET_2 'SP3QSWXQQJ5BKCVZBY1BH3BPGVX4MZPRKKG8CBDGR) ;; Creator Fee
(define-constant WALLET_3 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-leonardoughdavinci-v1b) ;; TO NFT
(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u25) u1000) tx-sender WALLET_1))
    (try! (stx-transfer? (/ (* price u25) u1000) tx-sender WALLET_2))
    (try! (stx-transfer? (/ (* price u25) u1000) tx-sender WALLET_3))
    (ok true)))