---
title: "Trait agp345"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wban u100000000 u60000000))
(try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wban u100000000 u60000000))
(try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wban u100000000 u0))
(try! (contract-call? .amm-registry-v2-01 set-max-in-ratio .token-alex .token-wslm u100000000 u60000000))
(try! (contract-call? .amm-registry-v2-01 set-max-out-ratio .token-alex .token-wslm u100000000 u60000000))
(try! (contract-call? .amm-registry-v2-01 set-start-block .token-alex .token-wslm u100000000 u0))
(try! (contract-call? .self-listing-helper-v2-01 approve-request u8 .token-wwen none))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-wrapped migrate))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2TY6PV9EHPJKDKK373MV9YCTH4N158EV1M2NGBQ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1DK0Y2WS2JEN0EDRNT2K60C5F20FGHAF06VTP6P))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPDS6VPEJKXVX9HAS2NE1Y9MFM6MJH0H4C17PW3J))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1DW2D361PXVM0VC3Z0MPTGAVC8RQYPAG19YSBVG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3DTRHXJF6HBAT0EY784GDYRHG1YCFZXJXB5ZTNW))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP6FXFH3X03PVGX6ZRGKKQBWBHP3EK1DGXVNVDZ3))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP15EX1SE0QC4G8NG2S7ECBT59GHYTHZBD5Z09N2C))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1V0WTFRPTPADF8FFQXWX6CX97G134JTBZJ8M8WB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP20PX90HTV4ENVE0WT865FRXRDFJW4QB3KTN1PPG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPHE7T1KZVKVH95N374B29QR67SJ6WJAJKSCZRGX))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1ZXRM9416FQQT2MW8DKSDHYRZT6RFEPZDN3DNKT))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2Y92G4K7T5YE55AYRE1HT03P86226SBPYB07WXJ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1N99ZSHDC32KSWPC9AC2ZBHJM3R1E1N6Z0XJQFB))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP23JVTY5WRTSHH6V0KSKZM5JNWVCNTJXZ1PWPA47))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPQSXRJTMPJHWCS6W3N5S36GHK226H8MDX0WB02W))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3FJC98HRM60AX7N2W3BVG1SDNRA7TCM5SJ91CT1))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPV991N9W4W9VH6FV9VDFP23TGQJ0QKY1SP6ZAZP))
(ok true)))
```
