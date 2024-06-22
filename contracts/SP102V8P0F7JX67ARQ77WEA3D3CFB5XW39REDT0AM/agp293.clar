(impl-trait .proposal-trait.proposal-trait)
(define-constant batch-0 (list 
	{ recipient: 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8, details: { claimed: false, amt-token-wbtc: u0, amt-age000-governance-token: u98645336998454, amt-token-abtc: u983222944, amt-token-wgus: u114648664004023000, amt-token-wplay: u280016039, amt-token-wlqstx: u10251281229701, amt-token-susdt: u8078089134612, amt-token-wvibes: u0, amt-token-slunr: u1448322412, amt-token-wdiko: u1271620000, amt-token-wpepe: u31603996941045300, amt-token-wleo: u0, amt-token-wlong: u3393807997094630000, amt-token-wmick: u5938893733846940000, amt-token-wnope: u0, amt-token-waewbtc: u0, amt-token-wmax: u1851056102, amt-token-wmega-v2: u2245215503447, amt-token-waeusdc: u0, amt-token-wfast: u4586687322, amt-token-wfrodo: u0, amt-token-wwif: u205128090130972000, amt-stx20-stxs: u0, amt-token-ssl-PomBoo-VPNTA: u0, amt-token-ssl-mooneeb-JGGPQS: u0, amt-token-ssl-wsbtc-08JSD: u0, amt-token-ssl-all-AESDE: u0, amt-token-ssl-nakamoto-08JSD: u0, amt-token-ssl-parker-QW155: u0, amt-token-ssl-memegoatstx-E0G14: u0, amt-token-ssl-stacks-rock-F6KBQ: u0, amt-token-ssl-pikachu-W1K62: u0, amt-token-ssl-hashiko-16Z1P: u0, amt-token-ssl-Runestone-7JYRJ: u0 } }
))
(define-constant batch-1 (list 
	{ participant: 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8, details: { stx: u694318738737, alex: u642872252626880 }}
))
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .claim-recovered set-claim-many batch-0))
		(try! (contract-call? .treasury-grant set-vesting-many batch-1))
		(ok true)))