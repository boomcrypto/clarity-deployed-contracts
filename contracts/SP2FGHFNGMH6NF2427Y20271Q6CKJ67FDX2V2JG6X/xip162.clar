;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-chain u0 { name: u"Solana", buff-length: u64 }))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP3QYT8ESZVY9GT5NXAYE2GNTW697W2E30EB418Q3)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP3QYT8ESZVY9GT5NXAYE2GNTW697W2E30EB418Q3 { chain-id: u19, pubkey: 0x039492171d86da914f0be3a2331e978a881f470721cbf397eb17f428e0343f7b61})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP3F614S2G6JJA2RYWFXYTM2XBBHESCQDC0RQ75W9)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP3F614S2G6JJA2RYWFXYTM2XBBHESCQDC0RQ75W9 { chain-id: u19, pubkey: 0x026549a1ecafb395397f08b1729ef6372d76420112132c05bc20376100d097c666})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP25XZZ1027REYZTXBN1394SNKAX719F9AQSV11MB)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP25XZZ1027REYZTXBN1394SNKAX719F9AQSV11MB { chain-id: u19, pubkey: 0x026f404cbd60b900da0a8a620cf62d9dd63c0a5b19be8ecd5aff1a05f1c136b562})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP3SR66228S5T8JT7PEDVJV00JZYDS9WDQ63P094D)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP3SR66228S5T8JT7PEDVJV00JZYDS9WDQ63P094D { chain-id: u19, pubkey: 0x03462f0d96378b014582bcefcd4b28062305add2f6c080e43a2e3242190dd615e3})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SPQ71834HKQE5HJF770CDKV630DSXD8GVTYRV1VV)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SPQ71834HKQE5HJF770CDKV630DSXD8GVTYRV1VV { chain-id: u19, pubkey: 0x033d0ced00fede30f934886dc78039c55345d3a3cab52da37fc6df71ea9cdd1f58})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP2TMQF8SFFR2RFH142DZSZG58H76DAB2FPFTPDMM)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP2TMQF8SFFR2RFH142DZSZG58H76DAB2FPFTPDMM { chain-id: u19, pubkey: 0x0317a23328090a9f927258a30329834b1acbb0c265ac0af1f45fbf465230f7caaa})))

(ok true)))
