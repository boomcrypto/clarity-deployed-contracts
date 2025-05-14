;; title:  boostx-supported-tokens
;; version:  1.7.5
;; summary:  BoostX Supported Fungible Tokens Smart Contract for BoostX Browser Extension
;; authors:  cryptodude.btc and cryptosmith.btc

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-map supported-tokens principal bool)

(define-constant ERR-UNAUTHORIZED (err u1000))
(define-constant ERR-INVALID-WALLET (err u1001))
(define-constant ERR-NOTFOUND (err u1004))

(define-data-var extDeployer principal 'SP337NP61BD34ES77QK4XZP6R9AXV235GV6W1YMNT)

;; returns set extDeployer owner wallet principal
(define-read-only (get-ext-deployer-wallet) (var-get extDeployer))

;; protected function to update extDeployer owner wallet principal
(define-public (set-ext-deployer-wallet (newExtDeployer principal))
	(begin
		(asserts! (is-eq contract-caller (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
		(asserts! (not (is-eq newExtDeployer (get-ext-deployer-wallet))) ERR-INVALID-WALLET);; Ensure it's not the same as the current wallet
		(ok (var-set extDeployer newExtDeployer))
	)
)

(define-read-only (get-token-status (token <sip-010-trait>)) 
    (begin 
        (ok (map-get? supported-tokens (contract-of token)))
    )
)

(define-public (add-token (token <sip-010-trait>) (state bool)) 
    (begin 
        (asserts! (is-eq tx-sender (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
        (ok (map-insert supported-tokens (contract-of token) state))
    )
)

(define-public (update-token-state (token <sip-010-trait>) (state bool))
    (begin 
        (asserts! (is-eq tx-sender (get-ext-deployer-wallet)) ERR-UNAUTHORIZED)
        (ok (map-set supported-tokens (contract-of token) state))
    )
)

;; Initial Supported Tokens
(map-insert supported-tokens 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token true)
(map-insert supported-tokens 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1 true)
(map-insert supported-tokens 'SP3BRXZ9Y7P5YP28PSR8YJT39RT51ZZBSECTCADGR.skullcoin-stxcity true)
(map-insert supported-tokens 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope true)
(map-insert supported-tokens 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token true)
(map-insert supported-tokens 'SP2C1WREHGM75C7TGFAEJPFKTFTEGZKF6DFT6E2GE.kangaroo true)
(map-insert supported-tokens 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-DOG true)
(map-insert supported-tokens 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex true)
(map-insert supported-tokens 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.velar-token true)
(map-insert supported-tokens 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token true)
(map-insert supported-tokens 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token true)
(map-insert supported-tokens 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token true)
(map-insert supported-tokens 'SP3HNEXSXJK2RYNG5P6YSEE53FREX645JPJJ5FBFA.meme-stxcity true)
(map-insert supported-tokens 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega true)
(map-insert supported-tokens 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token true)
(map-insert supported-tokens 'SP14J806BWEPQAXVA0G6RYZN7GNA126B7JFRRYTEM.world-peace-stacks-stxcity true)
(map-insert supported-tokens 'SP3W69VDG9VTZNG7NTW1QNCC1W45SNY98W1JSZBJH.flat-earth-stxcity true)
(map-insert supported-tokens 'SP4M2C88EE8RQZPYTC4PZ88CE16YGP825EYF6KBQ.stacks-rock true)
(map-insert supported-tokens 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59.stone-bonding-curve true)
(map-insert supported-tokens 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G.built-on-bitcoin-stxcity true)
(map-insert supported-tokens 'SP2EEV5QBZA454MSMW9W3WJNRXVJF36VPV17FFKYH.DROID true)
(map-insert supported-tokens 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9.dry-sock-stxcity true)
(map-insert supported-tokens 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV.moist-sock-bonding-curve true)
(map-insert supported-tokens 'SP1JBV7TE0490KNVM1VAM19KHZG0CPC9426YCY3ZF.drones-stxcity true)
(map-insert supported-tokens 'SP1MASMF30DRR4KDR5TG4RZEEVHBKS1ZX4TJZ8P06.mrbeans-stxcity true)
(map-insert supported-tokens 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R.smoke true)
(map-insert supported-tokens 'SP1PW804599BZ46B4A0FYH86ED26XPJA7SFYNK1XS.play true)
(map-insert supported-tokens 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2.honey-badger-stxcity true)
(map-insert supported-tokens 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy true)
(map-insert supported-tokens 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz true)
(map-insert supported-tokens 'SP2BQ0676YV3F7QBJXS1PT7XA975ZG03XEXS9C8TN.stacksai-stxcity true)
(map-insert supported-tokens 'SP3M31QFF6S96215K4Y2Z9K5SGHJN384NV6YM6VM8.satoshai true)
(map-insert supported-tokens 'SP1JFFSYTSH7VBM54K29ZFS9H4SVB67EA8VT2MYJ9.gus-token true)
(map-insert supported-tokens 'SP253J64EGMH59TV32CQXXTVKH5TQVGN108TA5TND.fair-bonding-curve true)
(map-insert supported-tokens 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3 true)
(map-insert supported-tokens 'SP265WBWD4NH7TVPYQTVD23X3607NNK4484DTXQZ3.longcoin true)
(map-insert supported-tokens 'SPZXE76HAF3621C4RQGHJ26ENXGEZV2JWAV2Y10Z.jindo true)
(map-insert supported-tokens 'SP371690BDHK9WRH3KXXRWNK62YR8N1P5JSYGQKRM.clive-stxcity true)
(map-insert supported-tokens 'SPQYMRAKZPQPJAADX5JBEFT0FHE3RZZK9F8TYBQ3.dawgpool-stxcity true)
(map-insert supported-tokens 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS.shark-coin-stxcity true)
(map-insert supported-tokens 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.fakfun-faktory true)