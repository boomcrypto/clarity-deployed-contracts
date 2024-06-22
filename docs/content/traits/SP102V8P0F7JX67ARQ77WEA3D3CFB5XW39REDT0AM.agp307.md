---
title: "Trait agp307"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP328BD8TMVPJ42DQDX4T5VTXZBGR0PAJ4K2FTVKT))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2TGDR7E7EW5PKYV2XDN5CE4WNRGKGJ6WW5AQ1NW))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3GT29VT7J9HGN1TNN9950FMZ0FV6RAMKJHN10TG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPY34KFP8HNNANRH1G71YK6BY0PJWAA75ADERMGX))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2TK8B4QRFXEG3EB6RT3H56KTC5PTWEB05CZZKY0))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2417FTRE8NFQQW3NY4VR0GN0JT2T7MJTQBSQK4E))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP21KD9F8MSBB6THP7FCEP15XE2RH3PVCXA7PBY9K))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP1M9M6YNP05M7BVRYYNVFZ7Y04Z48X0BN87H80BG))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP78064ZF3TDWDNX3AZ293DW0QJ6EX3TJVWENYPA))
	(ok true)))
```
