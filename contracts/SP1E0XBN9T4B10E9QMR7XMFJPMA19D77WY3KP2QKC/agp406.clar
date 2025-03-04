;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04 approve-request u17 .token-wfatherwelsh none))
(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-04 approve-request u18 .token-wchillguy none))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP297SP7K6VJPXNHBSBNQMG79ASCW6RN1G6CNGNTN))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2GSXQZ8GVYEZK9F68M0DFY31M4XACD0MX5WWJS7))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPR9C8JZ8KQMME0FMHP9R0GKV1WBNMRSGVZ44WVX))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPE6M71Z9T87N4GE15AD9AWXRWZXF592AT770FST))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3MXNBD726SXE6D9RAG2X3MVT9QADJ0SDQQJMQ08))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP16RB0P99SD9PKSXP5XWMHQ68HPWR3M5EZRN3MNV))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3V0BBSJM6YPG07EFZQ4PJX71EJKW7D5MDW19NWX))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2C1VGBW6Q7EEQBCV74EM9EP8DDVF2P88K6ERWAP))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1PBYMWE6ZPWXDDTSSC3BB7SVBBNBT46DK7P5VD6))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1XP1NYZDM0HVKS7TD4FP3ZBRVTT5BEP533X0RAW))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3WXHE1Y6R2HFYPRNR8EQFKECHVZPC1H481SC0KY))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1J37HH3VE2JAHEXM7NHVPC3ZTJBG257YQ20MVVQ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP33A8X66WM5J3SP0BSJH8100Q8N8MRNZGQHS0XM1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP385DH7P31KSVWDTGW22A41Q2JJGVMS472YPKT8F))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2082R1TBJZF3BDVCB6103KYRH30EEW7SEQPH2S4))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2CGED7TF0N4N2BA1BS1J5QA1FJ41ZB6SZV3QJNE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPFGYRJ87S51A8JZTFGDV635MRWR5BPF0PJ0N5VZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPXR2V01CBQ8HMEYCECRQG3E841GB1X6RR983DBW))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3JSTY4NWE5KASVAGJ1TCWFZVC772CGMVAB3FM1))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1EP73EGJ5BQKEEAN74VAM0TB195RNYAA8HGY5NE))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP1F5K9HYZXW75M6QDF5J4642RJ1JK6YZHGMQSVJ3))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPKEFAGMYSZZ6XKCMD25SCYM01ZB2H941ZQVTREZ))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP20R581FHVH7XCV2NSVGW30JHB2Y5B46R1R1BGB0))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP13H73J4P1VKR5K8ADMR98FDSX1DSEHTZ9B80XTW))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SPAPHJ1YPE74NB1JGJ5Z3TDDF8SGS5SQQWMCZS6P))

		(ok true)))

