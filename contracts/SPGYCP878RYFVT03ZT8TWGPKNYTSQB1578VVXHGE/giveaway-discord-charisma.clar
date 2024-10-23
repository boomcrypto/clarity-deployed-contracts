;; Define a constant for the authorized caller
(define-constant AUTHORIZED_CALLER 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE)

;; Helper function to check if the caller is authorized
(define-private (is-authorized (caller principal))
  (is-eq caller AUTHORIZED_CALLER)
)

(define-public (winners (sender principal))
  (begin
    ;; Check if the caller is authorized
    (asserts! (is-authorized tx-sender) (err u403))
    
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP9XKFETDDVXCACG4501SDWGV3R8AEDRMKZNHP4Y none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SPJ8NVC2ZVQCKB68XW1QXM6P7YJF8EYGQ2TT5QT7 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP1RDVQHYK1DGF3WR2BM83BCCKPWDS2M8FX11WDWP none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP12TMQCYNGEXJY12HRJF25H8T3RTJE1KR3MT2MT9 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SPXYRKWDFKBZN3GTS3W9A1MQ0PFTFAHZGGV9V1MJ none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP35M5QNWFJE0137X4PFZS9EPM5KBZX50A9PM1PNV none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP1GR38P4KNCQRC1BD5HC97DP36W2MBZFZ4WC0NET none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP20VRJRCZ3FQG7RE4QSPFPQC24J92TKDXJVHWEAW none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SPHQ8AG3QSTWV2XEGGVQMKC3H3XTQS2RB9DTXC88 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP2CYW85YW03WX0XMSFGMJ3HZQ30X8NKFA6TXVNRX none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP147CKES3RJS6B6XCFP1A4KK8MB34ND6Y60GZW3K none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP2WF8FYQP39XQ421VYDJTKFNA1VWNWA0CRTAWPWX none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SP145Z1WBN4CEDF39KCYF9QCYQD27AW0AH5KH58H none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u15000000 tx-sender 'SPENXM9Q8CKQGJF9DBRF12WR0SQXFQMYJKRAZG3F none))
    (ok true)
  )
)

(define-public (semi-winners (sender principal))
  (begin
    ;; Check if the caller is authorized
    (asserts! (is-authorized tx-sender) (err u403))
    
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP3A6TH5CSRZ5121QEZ2N6DABYT56RV67ZG1ZTK4 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP1VEHWR3SVWZWN24YQTHS3CVSMWEHK39CBM6Z3F5 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP1NXRV120RCPN7N55JA8FNK5TF4WDPT3T1MATFPS none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP5W88Y324AKEPZZJB89YKCGFKZRS5H4W8XBZ1K4 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP2ZRF8JCSA852P2K4ZB7RS21M43NYFKPSQ7DG1N8 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP36KY8Q0X14W3Z67DSJ0DCFNFF09HSQWZCT6RDXM none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP3JXASHMQJ8S7HMX3HQR9W3S9PBXF2T3VWSVZNWJ none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP3M3Y5W82QV4S05CNMWXGKZER5YEVSRD7JXVWBBZ none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH none))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer u5000000 tx-sender 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75 none))
    (ok true)
  )
)