;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant REGISTRATION_CUTOFF u1741053600)
(define-constant VOTING_CUTOFF u1741658400)
(define-constant STAKE_CUTOFF u1741658400)
(define-constant STAKE_END u1743991200)
(define-constant REWARD_AMOUNT (* u1000000 ONE_8))

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
	{ extension: .farming-campaign-v2-03, enabled: true } )))			
(try! (contract-call? .farming-campaign-v2-03 create-campaign REGISTRATION_CUTOFF VOTING_CUTOFF STAKE_CUTOFF STAKE_END REWARD_AMOUNT MAX_UINT))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP242HXH61BQGCEK1ZBG3WC00CPH41FKEJMSMD05A))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPJYA6Y1TDDNK826P1JEGQX2C7WQWDW5FR5R18YH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP13SYBWD6DEHTF9WAFBA1JX53D5SXHN9DZQEHSBT))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPCYD0RNYJ9A4P2X8XK91A5ST34WKHC2JTN5636Z))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2EWAKAGGPBD5P5S5A8TPJRG8SBWGJWP3MWCTAAE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPJS1SKAZ9TNVV9BB5H5GCXCQ8DMRCGY3SG9F8TA))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2BNZSEHBF8FE14E8Q50YBNEREXWK7P3AWAKETF1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2Y112A9MN0FCNWGQMY0KEKE4N8GQZKA7AAWDEP1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2AB5T8CGEW1358JKC7RGBWHSNPQDBHHETFS4HDS))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2VHVTPAVEAWFFXHWXDN3GHYW2BQJ58JYNFPGDQK))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP371DN10NEWXV1358VV36C9ZE9F59JT2VDRT3CAV))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP26HK9M84TQRTRGMMCJSA8ZR21J1TZNQ98G7HMQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3YW2M00E6PSAW4M1EMJ2WY4BDZR5J1RN81YMQQB))

		(ok true)))

