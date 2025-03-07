(impl-trait .proposal-trait.proposal-trait)
(define-constant recipient 'SP2Q73Z6GADQ2D5PAH7RRR54T3JWQM4FRWA40PKX1)
(define-constant old-recipient 'SM3Q5F3JFF5TGW61T9W8MG06K8XBYC1EQ0VVR5370)
(define-constant amount u25807400000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .token-alex edg-mint-many (list { recipient: recipient, amount: amount })))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-fixed amount old-recipient))
		(try! (contract-call? .self-listing-helper-v2-01 approve-request u6 .token-wgme none))
		(try! (contract-call? .self-listing-helper-v2-01 approve-request u7 .token-wdfv none))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2616CGGP1GSXMQVFGMSWSHSJTCV3BDB3R7N2R24))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1PCJ92G70A48949236JGDYWH0RMJ6ET85EV9JJV))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPEW25Y6T22DQ58KE0J8CVGDZGTF6GCZNE4ZG7MK))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1HXVYG71K90BCW2VGBDV6Q6AVT539WKAAKWARK5))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPWQMAKRF2ZFH926J7TRXTVCBFPSJX8QBQ0DGEDJ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3QE8XY1MAC43WBJY2Y295ERFSV44XD6SPHYYN6Q))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP4TSR7RRW87BB0W4KJEP8K7AHZZSR2SJ36MFDJ5))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP5DWSZ7S23FVKWJE95ZE499G5GSDFFFH9A8150A))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP25X4DMW7QBASM7SF4M00CD3GP1PNHM230HFYPEV))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3TPWRHRM7M9ZK8PVMPT7XQHHYT44VEKSFVY90E8))		
		(ok true)))