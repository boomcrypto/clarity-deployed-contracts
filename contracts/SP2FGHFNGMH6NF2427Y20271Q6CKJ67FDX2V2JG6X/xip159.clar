;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-eth, chain-id: u17 } { approved: true, burnable: true, fee: u100000, min-fee: u55555, min-amount: u55555, max-amount: u55555555555 }))

(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SPF85YYKYPBT78T0F5PY48C8MWZB05ZZDTFEWN02)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SPF85YYKYPBT78T0F5PY48C8MWZB05ZZDTFEWN02 { chain-id: u17, pubkey: 0x0288f51677f8177df1cdd17f95fa624b598f165ce0a2b58f9914378d4cdf8f1c03})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP2B2CV2SSCANV1Z5EQ2G3Q0MGWBJYX8W9C3SPS79)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP2B2CV2SSCANV1Z5EQ2G3Q0MGWBJYX8W9C3SPS79 { chain-id: u17, pubkey: 0x02145eb764d75785e123364ea7b28a8811a301c73406b36206eaa8ad8111e015ac})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP1772FP0M6EQGJ9MVMYVAYJ8FTVD4XCPPEQ214B4)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP1772FP0M6EQGJ9MVMYVAYJ8FTVD4XCPPEQ214B4 { chain-id: u17, pubkey: 0x03e0cf47a412c604cecf74e2a97f7b978de2f54fccaff6e16596aa3d20dee8395f})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP2FHDARB9NMPFQDNYDTV7ZR8P3ET80H2VF56WYR6)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP2FHDARB9NMPFQDNYDTV7ZR8P3ET80H2VF56WYR6 { chain-id: u17, pubkey: 0x02319094f28108188eae79a695d01be852879dc1faa86c54a9447189c39636fb57})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP1WZ507H5D5YF3WWTGYP8CNKGRAWMA3CP4FE4SZD)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP1WZ507H5D5YF3WWTGYP8CNKGRAWMA3CP4FE4SZD { chain-id: u17, pubkey: 0x031adb5cbfe44748eaf70cc25a87fcf7df8e89e71ec8c6db6af512cb4b7e923e98})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SPX8R37J2T4T45GWRT021XKSQ03E2GEG5DZXGT7N)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SPX8R37J2T4T45GWRT021XKSQ03E2GEG5DZXGT7N { chain-id: u17, pubkey: 0x020ab3a0e0ce1e6f70e4a4949a1f4078b51ecfdd945739483e2207f3a710098e28})))

(ok true)))
