---
title: "Trait agp354"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .self-listing-helper-v2-02 approve-token-x .token-wstx-v2 true u180000000000))
(try! (contract-call? .self-listing-helper-v2-02 reject-request u1 .token-wstx-v2 none))
(try! (contract-call? .self-listing-helper-v2-02 reject-request u2 .token-wstx-v2 none))
(try! (contract-call? .self-listing-helper-v2-02 reject-request u3 .token-wstx-v2 none))
(try! (contract-call? .auto-alex-apower-helper-v3 set-approved-operator 'SP17JDRQ402PC603JJK5YH9N0XRP9RBRGQ91RJHA3 true))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPQAY9TMJG0DHG6C4844MZ9AXBXAGDAVCMMN4ESQ))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2BDP72NNCNSGH0Z83BX4HQDBCPBB198QV8M1KH5))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SPNB1PKES205YJKJNDQ6GP8G8GKHMQ7ME4CQK90E))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP2R30BCFRQBEB4JT59DJ5RKEW5YNBBEGGHF0RAJN))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3XEZ6MQAGVJW18KY0XEKMMGV440DWSPTCQ00VF0))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP13H3FN4Q2F1ACVAEX7CY93T11A7364SAVS68ZXK))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3VZAMNT4Q4KJS1KC85NRGE4KJYGFTGQSPGVVZRW))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP3FFH1MKXXRF66WDTDWJZKXG13V8DVNXG8R9AZJE))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP254FHREFSM215P65Y89WN4W8B9WB2ZSNQ9S7F18))
(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate 'SP11P0H7AMS55VZMGPAGK6KKGNEEBTV9GD0T8CM66))
		(ok true)))
```
