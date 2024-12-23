(impl-trait .proposal-trait.proposal-trait)
(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-public (execute (sender principal))
	(begin	
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-chain u0 { name: u"Merlin", buff-length: u20 }))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP1W4P30HKV41B3B2A85NJ3H1YX1AY44CTK59TRT1 { chain-id: u8, pubkey: 0x02cc55cd667b6f37ea5c4af5acf87ee224a3d8cc79fe0ef4fafac4ecd70d59f5ee}))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP0C74EKQAXDQ1GB8J21YPBSFFN23KBF0FJFF1BS { chain-id: u8, pubkey: 0x0285d6ee7bbc0ff1407c766f01aeb203061d97604f0086e27a4d5443f809e2e0db}))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP39ZFBWFDQWXQPD9PS07YK6QFF9YJH083QJCXQE6 { chain-id: u8, pubkey: 0x03653f23990ece9c30eca4c0d88e6456e013feba67a9a49a879702f6507d534305}))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SPA7A0JHQGCRC0GJMC50HD8FFNHF0K9XG56W71H9 { chain-id: u8, pubkey: 0x03f0f8be7d2e02ecfd96e73bb3522d22eab556db2c8e961cecbb18db4be1c931fc}))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP2ARG4SDW07MMCKCN0RVDMADAAECNH6AYBH3HG8H { chain-id: u8, pubkey: 0x02a44dfdb8a739131333a4e79584b89c2e55545b28497ba9893fb4437e1eb75eab}))
(try! (contract-call? .cross-bridge-registry-v2-01 add-validator 'SP3M9R721Y298FDD0EWYBRCMZVC5G2B5AD9BSYZ9C { chain-id: u8, pubkey: 0x03386dff0d413968d3e945c2417d818f604d1da8c22af26dce9f6886e3bda7b24e}))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt, chain-id: u2 } { approved: true, burnable: true, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-slunr, chain-id: u1 } { approved: false, burnable: true, fee: u0, min-fee: u0, min-amount: u0, max-amount: u5000000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-slunr, chain-id: u2 } { approved: false, burnable: true, fee: u0, min-fee: u0, min-amount: u0, max-amount: u5000000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u3 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u3 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u4 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u4 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u5 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u5 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u6 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u6 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u7 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u7 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u8 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u2000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, chain-id: u8 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-ssko, chain-id: u2 } { approved: true, burnable: true, fee: u0, min-fee: u0, min-amount: u0, max-amount: u1000000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u1 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u1 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u2 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u2 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u3 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u3 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u4 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u4 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u5 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u5 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u6 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u6 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u7 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u7 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u8 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, chain-id: u8 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u3 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u3 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u4 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u4 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u5 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u5 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u6 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u6 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u7 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u7 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u8 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlialex, chain-id: u8 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u3 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u3 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u4 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u4 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u5 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u5 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u6 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u6 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u7 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u7 } MAX_UINT))
(try! (contract-call? .cross-bridge-registry-v2-01 set-approved-pair { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u8 } { approved: true, burnable: false, fee: u0, min-fee: u0, min-amount: u0, max-amount: u100000000000000 }))
(try! (contract-call? .cross-bridge-registry-v2-01 set-token-reserve { token: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wvlqstx, chain-id: u8 } MAX_UINT))
(ok true)))