;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant revenue-in-stx (* u12689 ONE_8))
(define-constant recovery-in-stx (* u0 ONE_8))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 add-to-claim-base (+ revenue-in-stx recovery-in-stx)))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1YNHYY29WVRTC3VMV46QGZ3ASF2G719FKX00V37))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2RXB2QCA9GDX3YTMQCD1J2X6NWM272FHP2D4N67))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2BXDPSBKEYAH79CWKTN5D8CABH3CF588PHKPJJH))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2WN5ZV57N1GDM7SNXVKPR6MX6MFW1KBMKF2QDQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP22TPP0K1Y1FT372Y531C9QV9YJV4EHJSHWC19PM))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1VMXNS6KP3P1HMXA3WHB871XHDCJ467NSC9GZP9))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP22H5948R02GR14A3KEE2E5XFWWXT9C4TTFPD6ED))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2VS41C9A89KXKS23J7B3SZ46H8SY1595KJHS6W3))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP28JP1FEVX7G3YFDJ59GKKQTZEVQQ49YDM0FDFK4))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2RCNGR2ENVC2REJFM42SC2MB47ETNZ6QDMAM0JK))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2X9A82W43T47K06SV9FK423BGMPWC8JZ82EBVYP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1TWMXZB83X6KJAYEHNYVPAGX60Q9C2NVXBQCJMY))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP78ZE0PGE1EHJCQVP9QJH5NVKMRVZTSG5GSXXY4))		
		(ok true)))
