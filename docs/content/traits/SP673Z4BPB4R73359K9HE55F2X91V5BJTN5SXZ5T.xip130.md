---
title: "Trait xip130"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(let (
			(wrong-order { 
				from: 0xcd0cb6aa811e1c8cd9a55ecb9cc83f6a50bed311,
				to: 0x51200ab32b2b871c81a1a958c3b4ae54ce0e77fadcecdb4c44305f1f3dd7c258e564,
				amount-in-fixed: u999000000000,
				token-in: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt,
				routing-tokens: (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt),
				routing-factors: (list ),
				token-out: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt,
				min-amount-out-fixed: none,
				src-chain-id: u16,
				dest-chain-id: (some u0),
				salt: 0x059DC1B241071379FE357414A1796254B8164331057C6A9C709AB2622ADFC146 })		
			(order { 
				from: 0xcd0cb6aa811e1c8cd9a55ecb9cc83f6a50bed311,
				to: 0x51200ab32b2b871c81a1a958c3b4ae54ce0e77fadcecdb4c44305f1f3dd7c258e564,
				amount-in-fixed: u999000000000,
				token-in: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt,
				routing-tokens: (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt),
				routing-factors: (list ),
				token-out: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt,
				min-amount-out-fixed: none,
				src-chain-id: u16,
				dest-chain-id: (some u1001),
				salt: 0x059DC1B241071379FE357414A1796254B8164331057C6A9C709AB2622ADFC146 })
			(wrong-order-hash (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-peg-in-v2-04b-swap hash-cross-swap-order wrong-order)))
			(order-hash (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-peg-in-v2-04b-swap hash-cross-swap-order order)))				
      (token-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: (get token-in order), chain-id: (get src-chain-id order) })))
      (pair-tuple { token: (get token-out order), chain-id: (get dest-chain-id order) })
      (print-msg (merge order { object: "cross-bridge-endpoint", action: "transfer-to-cross-swap" }))
      (default-fee-tuple (try! (get-default-peg-out-fee pair-tuple))))
(if (get burnable token-details) 
	(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt mint-fixed (get amount-in-fixed order) tx-sender))
	(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 transfer-fixed 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt (get amount-in-fixed order) tx-sender)))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-token-reserve { token: (get token-in order), chain-id: (get src-chain-id order) } (get amount-in-fixed order)))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-order-sent order-hash true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-order-sent wrong-order-hash true))
(try! (update-peg-out-fee pair-tuple u0 u0))
(match (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-peg-in-v2-04b-swap validate-cross-swap-order order 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
	ok-value
	(begin          
		(try! (contract-call? .cross-router-v2-03 route (get amount-in-fixed order) (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (get routing-factors order) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt (get min-amount-out-fixed order) { address: (get to order), chain-id: (get dest-chain-id order) }))
		(try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple)))
    (print (merge print-msg { success: true }))
		true)
  err-value
  (begin
    (try! (refund (get amount-in-fixed order) (get from order) 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-usdt (get src-chain-id order)))                    
    (try! (update-peg-out-fee pair-tuple (get peg-out-fee default-fee-tuple) (get peg-out-gas-fee default-fee-tuple)))
    (print (merge print-msg { success: false, err: err-value }))
		false))					

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .meta-peg-in-v2-06d-agg, enabled: false }
{ extension: .meta-peg-in-v2-06e-agg, enabled: true })))

(try! (contract-call? .meta-peg-in-v2-06d-agg pause true))
(try! (contract-call? .meta-peg-in-v2-06e-agg pause false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06e-agg true))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06d-agg false))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg true))

(ok true)))

(define-private (get-default-peg-out-fee (pair-tuple { token: principal, chain-id: (optional uint) }))
	(match (get chain-id pair-tuple)
		some-value
		(if (is-eq some-value u0)
    		(ok { peg-out-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee), peg-out-gas-fee: (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee) })
    		(if (or (is-eq some-value u1001) (is-eq some-value u1002)) ;; brc20 or runes
      			(let (
        			(pair-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 get-pair-details-or-fail { token: (get token pair-tuple), chain-id: some-value }))))
					(ok { peg-out-fee: (get peg-out-fee pair-details), peg-out-gas-fee: (get peg-out-gas-fee pair-details) }))
      			(let (
        			(pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: (get token pair-tuple), chain-id: some-value }))))
					(ok { peg-out-fee: (get fee pair-details), peg-out-gas-fee: (get min-fee pair-details) }))))
		(ok { peg-out-fee: u0, peg-out-gas-fee: u0 })))

(define-private (update-peg-out-fee (pair-tuple { token: principal, chain-id: (optional uint) }) (the-peg-out-fee uint) (the-peg-out-gas-fee uint))
	(match (get chain-id pair-tuple)
		some-value
		(if (is-eq some-value u0)
			(begin
      			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee the-peg-out-fee))
      			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee the-peg-out-gas-fee))
      			(ok true))
    		(if (or (is-eq some-value u1001) (is-eq some-value u1002))
      			(begin
					(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: (get token pair-tuple), chain-id: some-value } the-peg-out-fee))
					(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: (get token pair-tuple), chain-id: some-value } the-peg-out-gas-fee))
        			(ok true))
				(let (
					(pair-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail { token: (get token pair-tuple), chain-id: some-value }))))
					(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: (get token pair-tuple), chain-id: some-value } { fee: the-peg-out-fee, min-fee: the-peg-out-gas-fee, approved: (get approved pair-details), burnable: (get burnable pair-details), max-amount: (get max-amount pair-details), min-amount: (get min-amount pair-details) }))		
					(ok true))))
		(ok true)))

(define-private (refund (amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
		  (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
		  (token-details (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-approved-pair-or-fail pair-details)))
		  (no-fee { approved: (get approved token-details), burnable: (get burnable token-details), min-amount: (get min-amount token-details), max-amount: (get max-amount token-details), fee: u0, min-fee: u0 }))
    (ok (and (> amount u0) (begin
		  (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair pair-details no-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-out-endpoint-v2-01 transfer-to-unwrap token-trait amount the-chain-id from))	
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair pair-details (merge no-fee { fee: (get fee token-details), min-fee: (get min-fee token-details) })))
      true)))))

```
