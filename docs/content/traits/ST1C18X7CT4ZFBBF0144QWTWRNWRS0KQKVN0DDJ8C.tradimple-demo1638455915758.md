---
title: "Trait tradimple-demo1638455915758"
draft: true
---
```
(use-trait nft 'ST2PABAF9FTAJYNFZH93XENAJ8FVY99RRM4DF2YCW.nft-trait.nft-trait)

(define-constant agent-1 'ST1AN7SG5VBW8YPPTBRMT69GJE272T7R57B0EJQ4S)
(define-constant agent-2 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C)
(define-constant agent-3 'ST1NRFCWJQG84Z3KY8RE5JGWBJADR47ZPC07914ZS)
(define-constant agent-4 'ST2KTZ3QX55G6DYWHHJFY5PAS52T132F84ZX52ZKE)
(define-constant agent-5 'ST3AJBFP27CMDGYMBS7C4NZBSGQSK5ZAHF7N7F7S0)
(define-constant agent-6 'STPF2FQE6T9KZVWMXGQ6YCKRB37P7GB2K0FW2RAZ)

(define-data-var agent-1-status bool false)
(define-data-var agent-2-status bool false)
(define-data-var agent-3-status bool false)
(define-data-var agent-4-status bool false)
(define-data-var agent-5-status bool false)
(define-data-var agent-6-status bool false)


(define-data-var flag bool false)

(define-data-var deal bool false)

(define-constant deal-closed (err u300))
(define-constant cannot-escrow-nft (err u301))
(define-constant cannot-escrow-stx (err u302))
(define-constant sender-already-confirmed (err u303))
(define-constant non-tradable-agent (err u304))
(define-constant release-escrow-failed (err u305))


;; u501 - Progress ; u502 - Cancelled ; u503 - Finished
(define-data-var contract-status uint u501)


(define-read-only (check-contract-status) (ok (var-get contract-status)))

(define-private (check-deal) (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true) (ok true) (ok false)))

(define-private (check-deal-status) (unwrap-panic (if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status)) deal-closed (ok true))))

(define-private (release-escrow)
(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u61 tx-sender agent-1)))
		(as-contract (stx-transfer? u353000000 tx-sender agent-1)))
	)
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u38 tx-sender agent-2)))
		(as-contract (stx-transfer? u232000000 tx-sender agent-2)))
	)
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u18 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u31 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u43 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u45 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u47 tx-sender agent-3)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u52 tx-sender agent-3)))
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u14 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u2 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u34 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u60 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u9 tx-sender agent-4)))
		(as-contract (stx-transfer? u211000000 tx-sender agent-4)))
	)
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u21 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u25 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u3 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u41 tx-sender agent-5)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u24 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u44 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u54 tx-sender agent-6)))
	(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u58 tx-sender agent-6)))

	(var-set deal true)
	(var-set contract-status u503)
	(ok true)
))

(define-private (cancel-escrow)
(begin        
	(if (is-eq (var-get agent-1-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u31 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u24 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u44 tx-sender agent-1)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u3 tx-sender agent-1)))
	(var-set agent-1-status false))
	true)
	(if (is-eq (var-get agent-2-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u43 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u2 tx-sender agent-2)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u9 tx-sender agent-2)))
	(var-set agent-2-status false))
	true)
	(if (is-eq (var-get agent-3-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u41 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u21 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u61 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u14 tx-sender agent-3)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u54 tx-sender agent-3)))
		(as-contract (stx-transfer? u450000000 tx-sender agent-3)))
	)
	(var-set agent-3-status false)
	)
	true
	)
	(if (is-eq (var-get agent-4-status) true)
	(begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u45 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u18 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u25 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u58 tx-sender agent-4)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u38 tx-sender agent-4)))
	(var-set agent-4-status false))
	true)
	(if (is-eq (var-get agent-5-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u52 tx-sender agent-5)))
		(as-contract (stx-transfer? u204000000 tx-sender agent-5)))
	)
	(var-set agent-5-status false)
	)
	true
	)
	(if (is-eq (var-get agent-6-status) true)
	(begin
	(unwrap-panic (begin
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u34 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u47 tx-sender agent-6)))
		(unwrap-panic (as-contract (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u60 tx-sender agent-6)))
		(as-contract (stx-transfer? u142000000 tx-sender agent-6)))
	)
	(var-set agent-6-status false)
	)
	true
	)

	(var-set contract-status u502)
	(ok true)
))

(define-public (confirm-and-escrow)
(begin
	(var-set flag false)
	(unwrap-panic (begin
		(if (is-eq tx-sender agent-1)
		(begin
		(asserts! (is-eq (var-get agent-1-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u31 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u24 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u44 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u3 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-1-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-2)
		(begin
		(asserts! (is-eq (var-get agent-2-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u43 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u2 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u9 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-2-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-3)
		(begin
		(asserts! (is-eq (var-get agent-3-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u41 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u21 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u61 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u14 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u54 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u450000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-3-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-4)
		(begin
		(asserts! (is-eq (var-get agent-4-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u45 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u18 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u25 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u58 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u38 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(var-set agent-4-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-5)
		(begin
		(asserts! (is-eq (var-get agent-5-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u52 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u204000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-5-status true)
		(var-set flag true))
		true)
		(if (is-eq tx-sender agent-6)
		(begin
		(asserts! (is-eq (var-get agent-6-status) false) sender-already-confirmed)
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u34 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u47 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (contract-call? 'ST1C18X7CT4ZFBBF0144QWTWRNWRS0KQKVN0DDJ8C.my-nft-test transfer u60 tx-sender (as-contract tx-sender))) cannot-escrow-nft )
		(asserts! (is-ok (stx-transfer? u142000000 tx-sender (as-contract tx-sender))) cannot-escrow-stx )
		(var-set agent-6-status true)
		(var-set flag true))
		true)

	(ok true)))

	(if (and  (var-get agent-1-status) (var-get agent-2-status) (var-get agent-3-status) (var-get agent-4-status) (var-get agent-5-status) (var-get agent-6-status) true) (begin (unwrap-panic (release-escrow))) true)
	(if (is-eq (var-get flag) true) (ok true) non-tradable-agent)
))

(define-public (cancel)
(begin (check-deal-status)
	(if (or  (is-eq tx-sender agent-1) (is-eq tx-sender agent-2) (is-eq tx-sender agent-3) (is-eq tx-sender agent-4) (is-eq tx-sender agent-5) (is-eq tx-sender agent-6))
	(begin
	(unwrap-panic (cancel-escrow))
	(ok true))
	(ok false))
))


```
