;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-paused (err u1001))
(define-constant err-peg-in-address-not-found (err u1002))
(define-constant err-invalid-amount (err u1003))
(define-constant err-invalid-tx (err u1004))
(define-constant err-already-sent (err u1005))
(define-constant err-bitcoin-tx-not-mined (err u1011))
(define-constant err-invalid-input (err u1012))
(define-constant err-token-mismatch (err u1015))
(define-constant err-slippage (err u1016))
(define-constant err-not-in-whitelist (err u1017))
(define-constant err-invalid-routing (err u1018))
(define-constant err-commit-tx-mismatch (err u1019))
(define-constant err-invalid-token (err u1020))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant TOKEN_TO_REFUND 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.runes-mineticket)
(define-constant TOKEN_AMOUNT u59702300000000)
(define-constant REFUND_PER_TOKEN u20)
(define-constant START_BURN_BLOCK burn-block-height)
(define-constant END_BURN_BLOCK (+ burn-block-height (* u31 u144)))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer tx-sender true))
(try! (finalize-peg-in-cross-swap-on-index 
 (tuple (amt u41537823290000000000) (bitcoin-tx 0x0200000000010293b8f152c908a41dd8d46937f6271cc87644602f57de767fd632aafd702965da0000000000ffffffffdefcc71c75fe4a0663f95fe68e56bc481267a1d349fc6566253b093ca387ef2101000000171600144fb97331fdbfc521082975bc5e6332407dd535feffffffff042202000000000000225120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c30a060000000000002251209b040b135d7d51d53dd5a07d8ee30f133fa6991f456db09e4ec2051d49d3e1f5220200000000000022512044569a49e988b03711b0be2af83287bd067cb251f5633e75adcb483b0b5323f8d79700000000000022512014100a41e1f6fa9fd6900667cef8db0adedac2a667f8849c2964606e5a10782c0140d16ae60c63f3c3f9c1c4034151d061b4cc2c1ab995eed7ca545afeb8b43c39b82b63e8a08548acb979496aec6c7883cedae4392cde01cc7db0916a09479b55aa024830450221008ee2d62255e11d2a15e8c6208ad1672340b1d635e0847429047b5ea6a55691d302202918cfca9504961c09c48c35167da4e857b03cd90acd68ea82104c36b5d0f9850121039dc88aa87b49fbc6ad785f3146443de929d2fb55bf52726d87675a1b029d1e9900000000) (decimals u18) (from 0x) (from-bal u0) (output u0) (tick u"AUSD$") (to 0x5120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3) (to-bal u0))
 (tuple (header 0x00e0142003e3597cb99a88bb501e8298220145b3a2fa89b7b31f01000000000000000000bdcb10d3443c53610be4cfa9d36822c0a4a0881b10c7f65be871fb6506e038f8cb8dda6781820217b5012f8b) (height u888460))
 (tuple (hashes (list 0x93b8f152c908a41dd8d46937f6271cc87644602f57de767fd632aafd702965da 0x4cbb5c8f666bc46048c7603977807b2aba22209ab259811315446c1dd399d2fc 0xcb01eea848e27a3e1bb2b9162c59b25b4f452b71114b8e2affc4b449220254b4 0x972d4c4289b2589090fa05db9c969c0ea1b75004030f76b44ad7a7d5caf38bdc 0x7727b0754972b583538a005356126f9000b67473ef28f20dd917e23b7854f02a 0x2ad37c69df1b7d5c8709fa8ad0ca25f00c5e09934fd1af57d5815f93744e09b1 0xb2a048bd3957aa4cc161eabb34a3afd3ceb0f99692f74561328a26403584eb39 0x85a6e2ea522805f4daefadd1b5d9bff86a2d815b208ced5fbe1c0be633043055 0xb845e2da793c36aa2461427f7467ffac9ad16616ca5b56177d2d9fcf2ab89a5a 0x7d82330327284a3011af4489a1a7e62fc1b7b3a74e48367ad6f279551877302b 0x0d87b3659185724f24cd17d4b45646cfdc66fce7e7725d85ec4d2d1da8116954 0xe0ae153c15abc1788b4ad74459bbc3525d9763959084c0fe60e01577d1afc410 0x720c4df2a129cae92e482e8aebf40af3f0ef6869b75d97dc653b153d8a04982a)) (tree-depth u13) (tx-index u151))
 (list (tuple (signature 0x8acec6d1de43f748938c6a0a4a5eb4e16453eb56bfc18f25a1da709d37e6fd754238ccb79f3c2b24cb22d796d5261aed125c6a697d826b88ef41d9e55a4297a501) (signer 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1) (tx-hash 0xc36bec8d4b4c9ea224907822055905436ccfe9ac2af6b900e17c6b27f93df2d2)))
 (tuple (order-idx u0) (tx 0x020000000001014b2c212a5deffcfb7a5dbdf3aadf2edf4def3a2f34d9340c67adb8f0fd951c580100000000ffffffff0126010000000000001600142de14d4e16040db4666dab9e7547fbca631870da03404390ae37df88a2ed36000537ebe12621bee23d06c92dca75780c41d1941dbece6bbb8f4861c32b15c240fc391512f4f15a64a886d3c9aebadcf6c48040eb6d7be04cbb0c0000000601630d000000043130303201660200000022512014100a41e1f6fa9fd6900667cef8db0adedac2a667f8849c2964606e5a10782c016d0d0000000d32303737363235333934343139016f0616e685b016b3b6cd9ebf35f38e5ae29392e2acd51d0972756e65732d646f6701700b000000040d0000000232310d0000000231350d0000000234350d00000002393901720200000022512014100a41e1f6fa9fd6900667cef8db0adedac2a667f8849c2964606e5a10782c752070faf88fa6105c7bbd6f0cabe2e03a778ada80f8291699a8803574cc935946e7ac21c150929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac000000000))
 (tuple (header 0x00e0142003e3597cb99a88bb501e8298220145b3a2fa89b7b31f01000000000000000000bdcb10d3443c53610be4cfa9d36822c0a4a0881b10c7f65be871fb6506e038f8cb8dda6781820217b5012f8b) (height u888460))
 (tuple (hashes (list 0x5513439ea13001f636259a41c8a29c734d5449b33515704b2ace1ce1d542dc5a 0x08b0b009a5f6a17ec6dfe308e5675c9a7ab4f556a4ac203f0100c4183b563b56 0x8a54924c9c99e17e2ae9b8132dd4016ae35a74bc2578bd680aa9b9f00ed65288 0x7e6af98819a91705c141a820cedc84a058543cd6df7bed264a61043bc0dccce4 0x7727b0754972b583538a005356126f9000b67473ef28f20dd917e23b7854f02a 0x2ad37c69df1b7d5c8709fa8ad0ca25f00c5e09934fd1af57d5815f93744e09b1 0xb2a048bd3957aa4cc161eabb34a3afd3ceb0f99692f74561328a26403584eb39 0x85a6e2ea522805f4daefadd1b5d9bff86a2d815b208ced5fbe1c0be633043055 0xb845e2da793c36aa2461427f7467ffac9ad16616ca5b56177d2d9fcf2ab89a5a 0x7d82330327284a3011af4489a1a7e62fc1b7b3a74e48367ad6f279551877302b 0x0d87b3659185724f24cd17d4b45646cfdc66fce7e7725d85ec4d2d1da8116954 0xe0ae153c15abc1788b4ad74459bbc3525d9763959084c0fe60e01577d1afc410 0x720c4df2a129cae92e482e8aebf40af3f0ef6869b75d97dc653b153d8a04982a)) (tree-depth u13) (tx-index u152))
 none
 (list 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wxusd 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog)
 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog))				

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .meta-peg-in-v2-06e-agg, enabled: false }
{ extension: .meta-peg-in-v2-06f-agg, enabled: true }
{ extension: .meta-peg-in-v2-06-refund, enabled: true })))

(try! (contract-call? .meta-peg-in-v2-06-refund set-refund-per-token TOKEN_TO_REFUND TOKEN_AMOUNT REFUND_PER_TOKEN START_BURN_BLOCK END_BURN_BLOCK))
(try! (contract-call? .meta-peg-in-v2-06-refund pause false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06-refund true))

(try! (contract-call? .meta-peg-in-v2-06e-agg pause true))
(try! (contract-call? .meta-peg-in-v2-06f-agg pause false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06f-agg true))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06e-agg false))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06f-agg true))

(ok true)))

(define-private (finalize-peg-in-cross-swap-on-index
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) }))
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (fee-idx (optional uint)) (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>)) 
  (begin
    (try! (index-tx tx block proof signature-packs))
    (finalize-peg-in-cross-swap { tx: (get bitcoin-tx tx), output-idx: (get output tx), fee-idx: fee-idx } reveal-tx reveal-block reveal-proof routing-traits token-out-trait)))

(define-private (finalize-peg-in-cross-swap 
  (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) 
  (reveal-tx { tx: (buff 32768), order-idx: uint }) 
  (reveal-block { header: (buff 80), height: uint })
  (reveal-proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })    
  (routing-traits (list 5 <ft-trait>)) (token-out-trait <ft-trait>))
  (let (
      (is-reveal-tx-mined (try! (verify-mined (get tx reveal-tx) reveal-block reveal-proof)))
      (validation-data (try! (validate-tx-cross-swap-base commit-tx reveal-tx)))
			(token-trait (unwrap-panic (element-at? routing-traits u0)))
      (tx (get tx commit-tx))
      (order-details (get order-details validation-data))
			(token-details (get token-details validation-data))
      (fee (get fee validation-data))
      (amt-net (get amt-net validation-data))
      (pair-tuple { token: (get token-out order-details), chain-id: (get chain-id order-details) })
			(print-msg (merge (get tx-idxed validation-data) { type: "finalize-peg-in-cross-swap", order-details: order-details, fee: fee, amt-net: amt-net, tx-id: (try! (get-txid tx)), output-idx: (get output-idx commit-tx), offset-idx: u0 })))
    (asserts! (not (get peg-in-paused token-details)) err-paused)
    (match (get fee-idx commit-tx) some-value (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-peg-in-sent tx some-value true)) true)
    (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-in-sent { tx: tx, output: (get output-idx commit-tx), offset: u0 } true))
    (and (> fee u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed fee tx-sender)))
    (try! (check-trait token-trait (get token (get pair-details validation-data))))
    (and (> amt-net u0) (if (get no-burn token-details) 
      (let (
          (peg-out-balance (- (unwrap-panic (contract-call? token-trait get-balance-fixed .meta-peg-out-endpoint-v2-04)) amt-net))) 
        (try! (contract-call? .meta-peg-out-endpoint-v2-04 transfer-all-to tx-sender token-trait))
        (try! (contract-call? token-trait transfer-fixed peg-out-balance tx-sender .meta-peg-out-endpoint-v2-04 none)))
      (try! (contract-call? token-trait mint-fixed amt-net tx-sender))))
    (try! (refund fee amt-net (get from order-details) token-trait (get chain-id (get pair-details validation-data))))
		(print (merge print-msg { success: false }))
		(ok false)))

(define-private (validate-tx-cross-swap-base (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }) (reveal-tx { tx: (buff 32768), order-idx: uint }))
  (let (
			(validation-data (try! (validate-drop-common commit-tx)))
			(reveal-tx-data (try! (contract-call? .meta-peg-in-v2-06d-swap decode-order-cross-swap-from-reveal-tx-or-fail (get tx reveal-tx) (get order-idx reveal-tx)))))
    (asserts! (is-eq (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.clarity-bitcoin-v1-07 get-segwit-txid (get tx commit-tx)) (get commit-txid reveal-tx-data)) err-commit-tx-mismatch)
    (ok (merge validation-data { order-details: (get order-details reveal-tx-data) }))))

(define-private (validate-drop-common (commit-tx { tx: (buff 32768), output-idx: uint, fee-idx: (optional uint) }))
	(let (
      (tx-idxed (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get tx commit-tx) (get output-idx commit-tx) u0)))      
      (pair-details (try! (contract-call? .meta-peg-in-v2-06d-swap get-tick-to-pair-or-fail (get tick tx-idxed))))
      (token-details (try! (contract-call? .meta-peg-in-v2-06d-swap get-pair-details-or-fail pair-details)))
      (amt-in-fixed (decimals-to-fixed (get amt tx-idxed) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-tick-decimals-or-default (get tick tx-idxed)))))    
    (asserts! (get approved token-details) err-unauthorised)
    (asserts! (not (contract-call? .meta-peg-in-v2-06d-swap get-peg-in-sent-or-default (get tx commit-tx) (get output-idx commit-tx) u0)) err-already-sent)
    (asserts! (contract-call? .meta-peg-in-v2-06d-swap is-peg-in-address-approved (get to tx-idxed)) err-peg-in-address-not-found)     	
    (ok { fee: u0, tx-idxed: tx-idxed, pair-details: pair-details, token-details: token-details, amt-net: amt-in-fixed } )))

(define-private (refund (btc-amount uint) (token-amount uint) (from (buff 128)) (token-trait <ft-trait>) (the-chain-id uint))
  (let (
      (pair-details { token: (contract-of token-trait), chain-id: the-chain-id })
	    (token-details (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 get-pair-details-or-fail pair-details)))
      (default-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-fee))
      (default-min-fee (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 get-peg-out-min-fee)))
    (and (> btc-amount u0) (begin
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u0))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 request-peg-out-0 from btc-amount))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-fee default-fee))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01 set-peg-out-min-fee default-min-fee))
      true))
    (and (> token-amount u0) (begin
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details u0))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details u0))
      (try! (contract-call? .meta-peg-out-endpoint-v2-04 request-peg-out token-amount from token-trait the-chain-id))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-fee pair-details (get peg-out-fee token-details)))
      (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-peg-out-gas-fee pair-details (get peg-out-gas-fee token-details)))
      true))
    (ok true))) 

(define-private (index-tx
  (tx { bitcoin-tx: (buff 32768), output: uint, tick: (string-utf8 256), amt: uint, from: (buff 128), to: (buff 128), from-bal: uint, to-bal: uint, decimals: uint })
  (block { header: (buff 80), height: uint })
  (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint })
  (signature-packs (list 10 { signer: principal, tx-hash: (buff 32), signature: (buff 65) })))
  (begin 
    (and 
      (not (is-ok (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 get-bitcoin-tx-indexed-or-fail (get bitcoin-tx tx) (get output tx) u0)))
      (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 index-tx-many (list { tx: (merge tx { offset: u0 }), block: block, proof: proof, signature-packs: signature-packs }))))
    (print { type: "indexed-tx", tx-id: (try! (get-txid (get bitcoin-tx tx))), block: block, proof: proof, signature-packs: signature-packs })
    (ok true)))

(define-private (decimals-to-fixed (amount uint) (decimals uint))
  (/ (* amount ONE_8) (pow u10 decimals)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (check-trait (token-trait <ft-trait>) (token principal))
  (ok (asserts! (is-eq (contract-of token-trait) token) err-token-mismatch)))

(define-private (decode-from-reveal-tx-or-fail (tx (buff 32768)) (order-idx uint))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 decode-from-reveal-tx-or-fail tx order-idx))

(define-private (extract-tx-ins-outs (tx (buff 32768)))
  (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 extract-tx-ins-outs tx))

(define-private (get-txid (tx (buff 32768)))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 get-txid tx))

(define-private (verify-mined (tx (buff 32768)) (block { header: (buff 80), height: uint }) (proof { tx-index: uint, hashes: (list 14 (buff 32)), tree-depth: uint }))
	(contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bridge-common-v2-02 verify-mined tx block proof))

