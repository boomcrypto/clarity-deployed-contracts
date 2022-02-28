;; see SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.commission-stacksart
(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u40) u10000) tx-sender 'SP1EV6DEGJYN4NC4GS94MTXKF8PAQ5ZNA4QHJ2VZ6))
        (try! (stx-transfer? (/ (* price u216) u10000) tx-sender 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM))
        (try! (stx-transfer? (/ (* price u144) u10000) tx-sender 'SP2H2ZB08EW097TPDQPDPPJ6B73YAZS4V2KNSDC04))
        ;; replace marketplace (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP1WJY09D3DEE45B1PY8TAV838VCH9HNEJW0QPFND))
        (ok true)))
