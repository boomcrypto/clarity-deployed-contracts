;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 remove-validator 'SPHBJXK28AZPKSC2VA26K7DH377TY4HPX7MQSBPV))
(and (is-err (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 get-validator-or-fail 'SPSXQNJS82QMF5V1HXQH3HS49R12WJ0J6GN0B9D2)) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 add-validator 'SPSXQNJS82QMF5V1HXQH3HS49R12WJ0J6GN0B9D2 { chain-id: u18, pubkey: 0x03c305fa84581e49187c5637b6b555c5e49294ec934ea854f55ccf34e3b9efcdbb})))

(ok true)))
