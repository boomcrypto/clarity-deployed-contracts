;; SPDX-License-Identifier: BUSL-1.1

;; XIP-180: Update Token Reserves Across Multiple Chains
;; 
;; This proposal updates token reserves in the cross-bridge-registry-v2-01 contract
;; for USDC, USDT, tBTC, and WBTC across multiple blockchain networks:
;; 
;; - Ethereum (chain 1): USDT, tBTC, WBTC
;; - BSC (chain 2): USDT, WBTC  
;; - Avalanche (chain 12): USDC, USDT, WBTC
;; - Base (chain 16): USDC, USDT, WBTC
;; - Arbitrum (chain 17): USDC, USDT, WBTC
;; - Mezo (chain 18): USDC, USDT, tBTC
;; 
;; The proposal includes print statements to log each reserve update operation
;; and verify the updated values by calling get-token-reserve-or-default.

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u1000))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin			
(print "Setting USDT on Ethereum (chain 1) to 2902829796700")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1 } u2902829796700))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u1 }))

(print "Setting tBTC on Ethereum (chain 1) to 10460470")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u1 } u10460470))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u1 }))

(print "Setting WBTC on Ethereum (chain 1) to 553302")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u1 } u553302))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u1 }))

(print "Setting USDT on BSC (chain 2) to 198673560956055")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u2 } u198673560956055))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u2 }))

(print "Setting WBTC on BSC (chain 2) to 2371054948")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u2 } u2371054948))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u2 }))

(print "Setting USDC on Avalanche (chain 12) to 8010695852400")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u12 } u8010695852400))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u12 }))

(print "Setting USDT on Avalanche (chain 12) to 0")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u12 } u0))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u12 }))

(print "Setting WBTC on Avalanche (chain 12) to 657134021")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u12 } u657134021))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u12 }))

(print "Setting USDC on Base (chain 16) to 8112797413900")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u16 } u8112797413900))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u16 }))

(print "Setting USDT on Base (chain 16) to 0")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u16 } u0))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u16 }))

(print "Setting WBTC on Base (chain 16) to 4015872")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u16 } u4015872))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u16 }))

(print "Setting USDC on Arbitrum (chain 17) to 116242616600")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u17 } u116242616600))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u17 }))

(print "Setting USDT on Arbitrum (chain 17) to 0")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u17 } u0))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u17 }))

(print "Setting WBTC on Arbitrum (chain 17) to 90083200")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u17 } u90083200))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u17 }))

(print "Setting USDC on Mezo (chain 18) to 16585568233400")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u18 } u16585568233400))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-usdc, chain-id: u18 }))

(print "Setting USDT on Mezo (chain 18) to 538455488200")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u18 } u538455488200))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt, chain-id: u18 }))

(print "Setting tBTC on Mezo (chain 18) to 2321800359")
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u18 } u2321800359))
(print (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-token-reserve-or-default { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u18 }))

(ok true)))
