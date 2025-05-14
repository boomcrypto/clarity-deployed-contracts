---
title: "Trait agp424"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; TODO
(define-constant WHITELISTED (list u115 u116 u117 u118 u119 u120 u121 u122 u123 u124))

(define-public (execute (sender principal))
	(let (
			(current-details (try! (contract-call? .farming-campaign-v2-02 get-campaign-or-fail u2)))
			(updated-details (merge current-details { snapshot-block: u406000 })))
(try! (contract-call? .farming-campaign-v2-02 update-campaign u2 updated-details))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP16XF2S6JYFNKXFHY99X9XRVJ0AR4NJYFR9ZY759))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2DD26WNTJF179AWCQT80ZMCK5EFB25A0QJP4SVX))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1YM65DNXYHEKMCWDN9WJ60NV00Y91ZNC74J84VA))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP395MHAH03TGDMPMEBSYY9DKDRA0D565PE1X7CS1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPCQB00KS4PTPTD14H79DMFEGSBKW3VFVRK3F5HS))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1Y54AP1PKTDDVJHCT90R8BF893A4A3F596C1M9S))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1JH1GMA8STE2MM3EB9RREV07T1821BSPPYRG2NK))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP34AKZ1QXAAMZVPEGKJ79YDN2CJQ9PEJMESKG2SQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP11A1G2F86SSPERF0KA3M5KTSKCTKR5Q23SFEMQQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3P1C7NBBG6E0AVZAZ3NR6VSFGP610EKTHS5STKZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPYXBP5VDHXE6FZGR439D7RNH0CEHAA0C4KAG1Y3))

		(ok true)))


```
