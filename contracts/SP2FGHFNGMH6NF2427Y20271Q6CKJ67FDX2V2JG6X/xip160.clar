;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

;; TODO add Mezo validators
(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
  { extension: .token-tbtc, enabled: true })))	
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-router-v2-03 add-wrapped .token-tbtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-chain u0 { name: u"Mezo", buff-length: u20 }))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SPHBJXK28AZPKSC2VA26K7DH377TY4HPX7MQSBPV)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SPHBJXK28AZPKSC2VA26K7DH377TY4HPX7MQSBPV { chain-id: u18, pubkey: 0x025810c5c8abb5e9ca738a30c11df48f3d365e011c0986c565d836db7b0c54c765})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP5A59AKVRJ4AV72DJ83DPXE3BSS0E8PQFYNAVEQ)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP5A59AKVRJ4AV72DJ83DPXE3BSS0E8PQFYNAVEQ { chain-id: u18, pubkey: 0x03e72722d722038253f17c191253f7fe64d296078850087c37fd6342ac81a1568e})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP2GHQK7QATGKAVKYF33BGB27FYBEWE6493R87S1F)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP2GHQK7QATGKAVKYF33BGB27FYBEWE6493R87S1F { chain-id: u18, pubkey: 0x027223ddbfc408477dd58fca6f653b1b01b62a5ab38e7e6d733ea48447c2fcd7b4})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP1W8K1DBJF15J9J7JQWDAVFRDN6XPWJAR0T64WS8)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP1W8K1DBJF15J9J7JQWDAVFRDN6XPWJAR0T64WS8 { chain-id: u18, pubkey: 0x0399555ad8ec0125329f598bf56fe9f46c5e42e268c5de521aecc184a80e80fe9d})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP1G1YHVE9THSMJNR6JGJHYQXG8NR7ZXBDQKK3TZP)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP1G1YHVE9THSMJNR6JGJHYQXG8NR7ZXBDQKK3TZP { chain-id: u18, pubkey: 0x036934ac3be17af3766876dfb9ae9c246a4673b166c700735b80bf71b6cd3412f0})))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SP1FR23NEBC54N7KY8SEWKG08DE2K63YC6YKEXKR2)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SP1FR23NEBC54N7KY8SEWKG08DE2K63YC6YKEXKR2 { chain-id: u18, pubkey: 0x029cd70f2ec45b73bed1423e84f90e3089a7603bbd11bd87839be24fc58868f3bd})))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1 } { approved: true, burnable: true, fee: u100000, min-fee: u7230657989877, min-amount: u7230657989877, max-amount: u7230657989877079000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u2 } { approved: true, burnable: true, fee: u100000, min-fee: u7230657989877, min-amount: u7230657989877, max-amount: u7230657989877079000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u12 } { approved: true, burnable: true, fee: u100000, min-fee: u7230657989877, min-amount: u7230657989877, max-amount: u7230657989877079000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u1 } { approved: true, burnable: true, fee: u100000, min-fee: u1000, min-amount: u1000, max-amount: u1000000000 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-tbtc, chain-id: u18 } { approved: true, burnable: true, fee: u100000, min-fee: u1000, min-amount: u1000, max-amount: u1000000000 }))

(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 approve-pair { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } u"runes::897823:2026" true))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-in { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 pause-peg-out { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } false))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-in-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-peg-out-gas-fee { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } u0))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.meta-bridge-registry-v2-04 set-token-no-burn { token: 'SP2FGHFNGMH6NF2427Y20271Q6CKJ67FDX2V2JG6X.token-pepe, chain-id: u1002 } true))

(ok true)))
