;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u25 .token-wflat none))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01 approve-request u26 .token-wmiam none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1VZ4K0200CFA8CDD4FMWSYY8W24P7YAGG0G0J20))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3K318E1QKF7362DC456A85XT90FYBFSHJVM2DRX))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3WTE0GDQ0DR82BFEZGMKH4NKV1QEN8VCWEP7TEZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2ENFJCA4BGFQA7DBQ0HYZZ8A1ZB2BR7Y9NE1W9T))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPNBVWV8DE93JD4T0G4QP091TN39JS7SBMVVQZ0M))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP13A407VG25M3A6PXND6EYCZJYBF7PNJRXX76DVZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP21B5WPYGHJN2DMXVR39JE61EM3HWG9QHTX0WZAN))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3VTC5TNYC9ZJ5NZ9DG4HHZP5Z21ZM5JRSF6M5MD))
		(ok true)))

