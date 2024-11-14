;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-approved-chain u1001 u"BRC20"))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 set-approved-chain u1002 u"Runes"))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-peg-in-address 0x5120f77236aa6941bdc14944fb63b74084647f8986664ff01d28a0f09c10fac853c3 true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03 approve-fulfill-address 0x51200e95fe8f2290f723202e79278ed313f4a5f1b4cebc6ab5330d3af376aaa31fd9 true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-03, enabled: true }
{ extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-03, enabled: true }
{ extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-03, enabled: true }
{ extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-02, enabled: false }
)))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-03 pause false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-03 pause false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-02 pause true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-03 true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-03 true))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.oracle-v2-01 approve-relayer 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-02 false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-03 set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-out-endpoint-v2-03 set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-peg-in-endpoint-v2-03 set-peg-in-fee u0))
(ok true)))
