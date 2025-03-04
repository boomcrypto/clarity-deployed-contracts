;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .btc-peg-in-v2-07a-swap, enabled: false }
;; { extension: .btc-peg-in-v2-07b-swap, enabled: false }
{ extension: .btc-peg-in-v2-07c-swap, enabled: true }
{ extension: .meta-peg-in-v2-06-swap, enabled: false }
;; { extension: .meta-peg-in-v2-06a-swap, enabled: false }
{ extension: .meta-peg-in-v2-06b-swap, enabled: true }
;; { extension: .cross-peg-in-endpoint-v2-04, enabled: false }
{ extension: .cross-peg-in-v2-04-swap, enabled: true })))

(try! (contract-call? .btc-peg-in-v2-07a-swap pause-peg-in true))
;; (try! (contract-call? .btc-peg-in-v2-07b-swap pause-peg-in true))
(try! (contract-call? .btc-peg-in-v2-07c-swap pause-peg-in false))
(try! (contract-call? .meta-peg-in-v2-06-swap pause true))
;; (try! (contract-call? .meta-peg-in-v2-06a-swap pause true))
(try! (contract-call? .meta-peg-in-v2-06b-swap pause false))
;; (try! (contract-call? .cross-peg-in-endpoint-v2-04 set-paused true))
(try! (contract-call? .cross-peg-in-v2-04-swap set-paused false))

(try! (contract-call? .meta-peg-in-v2-06b-swap set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06-swap false))
;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06a-swap false))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer .meta-peg-in-v2-06b-swap true))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06-swap false))

(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-maxi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-shnt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-piza set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-long set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-insc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-majo set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dexm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-aiptp set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-cvlt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lbow set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sbtc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-oxbt set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ords set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nyto set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-beng set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-sats set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-taro set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-10mm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pepe set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-vmpx set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-atlfg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordi set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-dbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-mxrc set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-igli set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ohms set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-jake set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-meme set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-nals set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-xing set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-bank set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-pass set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-wzrd set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-moon set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-drac set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-love set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-zbit set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-lger set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-reos set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))
(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-inu set-approved-contract 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-v2-06b-swap true))

(ok true)))
