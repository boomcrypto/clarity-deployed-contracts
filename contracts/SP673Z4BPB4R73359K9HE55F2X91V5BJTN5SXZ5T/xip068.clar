;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } u"vliab" false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-in { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-out { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-vliabtc, chain-id: u1001 } true))

(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-pair { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } u"vliab" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-in { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-fee { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 pause-peg-out { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-token-no-burn { token: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wvliabtc, chain-id: u1001 } true))

(try! (contract-call? .xlink-staking add-validator 'SPQ339B27G9C354ATAZF4BZVRRRAA2ZFTMSZR02G  { token: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc, pubkey: 0x032e9978a78e80d27ed6a85c64e9a87f27e80fd9751d0a41927858179d6d3cb338 }))
(ok true)))
