---
title: "Trait pontis-bridge-v4"
draft: true
---
```
(impl-trait .bridge-trait-v2.bridge-trait-v2)
(impl-trait .bridge-config-trait-v1.bridge-config-trait-v1)

(use-trait bridge-ft-trait .bridge-ft-trait.bridge-ft-trait)
(use-trait bridge-nft-trait .bridge-nft-trait.bridge-nft-trait)

(define-data-var btc-token principal tx-sender)
(define-data-var btc-paused bool false)
(define-data-var total-amount-key-utxo uint u0)
(define-data-var current-key-utxo uint u0)

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-HASH-EXISTS (err u101))
(define-constant ERR-RUNE-NOT-ACTIVE (err u102))
(define-constant ERR-PAUSED (err u103))
(define-constant ERR-WRONG-BTC-CONTRACT (err u104))
(define-constant ERR-MIN-AMOUNT (err u105))
(define-constant ERR-NO-ORDINAL-UTXO-FOUND (err u106))
(define-constant ERR-UNWRAP-ID (err u107))
(define-constant ERR-UNWRAP-RECIPIENT (err u108))
(define-constant ERR-UNWRAP-TX-HASH (err u109))
(define-constant ERR-UNWRAP-ITERATOR (err u110))
(define-constant ERR-WRONG-ARRAY-SIZE (err u111))
(define-constant ERR-EMPTY-ARRAY (err u112))
(define-constant ERR-MIN-AMOUNT-UNWRAP (err u113))
(define-constant ERR-BASE-FEE-UNWRAP (err u114))
(define-constant ERR-UNWRAP-HASH (err u115))
(define-constant ERR-UNWRAP-CONTRACT (err u116))
(define-constant ERR-UNWRAP-AMOUNT (err u117))
(define-constant ERR-REMOVING-USED-KEY-UTXO (err u118))
(define-constant ERR-REMOVING-NOT-EXISTING-KEY (err u119))
(define-constant ERR-UNWRAP-PRE-LAST-UTXO (err u120))
(define-constant ERR-NO-KEY-UTXO (err u121))
(define-constant ERR-ORDINALS-CONTRACT-NOT-ACTIVE (err u122))
(define-constant ERR-NO-SUCH-RUNE (err u123))
(define-constant ERR-WRONG-RUNE-CONTRACT (err u124))
(define-constant ERR_INVALID_BURN_HASH (err u125))

(define-constant ITERATOR (list
	u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99
	u100 u101 u102 u103 u104 u105 u106 u107 u108 u109 u110 u111 u112 u113 u114 u115 u116 u117 u118 u119 u120 u121 u122 u123 u124 u125 u126 u127 u128 u129 u130 u131 u132 u133 u134 u135 u136 u137 u138 u139 u140 u141 u142 u143 u144 u145 u146 u147 u148 u149 u150 u151 u152 u153 u154 u155 u156 u157 u158 u159 u160 u161 u162 u163 u164 u165 u166 u167 u168 u169 u170 u171 u172 u173 u174 u175 u176 u177 u178 u179 u180 u181 u182 u183 u184 u185 u186 u187 u188 u189 u190 u191 u192 u193 u194 u195 u196 u197 u198 u199
	u200 u201 u202 u203 u204 u205 u206 u207 u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232 u233 u234 u235 u236 u237 u238 u239 u240 u241 u242 u243 u244 u245 u246 u247 u248 u249 u250 u251 u252 u253 u254 u255 u256 u257 u258 u259 u260 u261 u262 u263 u264 u265 u266 u267 u268 u269 u270 u271 u272 u273 u274 u275 u276 u277 u278 u279 u280 u281 u282 u283 u284 u285 u286 u287 u288 u289 u290 u291 u292 u293 u294 u295 u296 u297 u298 u299
	u300 u301 u302 u303 u304 u305 u306 u307 u308 u309 u310 u311 u312 u313 u314 u315 u316 u317 u318 u319 u320 u321 u322 u323 u324 u325 u326 u327 u328 u329 u330 u331 u332 u333 u334 u335 u336 u337 u338 u339 u340 u341 u342 u343 u344 u345 u346 u347 u348 u349 u350 u351 u352 u353 u354 u355 u356 u357 u358 u359 u360 u361 u362 u363 u364 u365 u366 u367 u368 u369 u370 u371 u372 u373 u374 u375 u376 u377 u378 u379 u380 u381 u382 u383 u384 u385 u386 u387 u388 u389 u390 u391 u392 u393 u394 u395 u396 u397 u398 u399
	u400 u401 u402 u403 u404 u405 u406 u407 u408 u409 u410 u411 u412 u413 u414 u415 u416 u417 u418 u419 u420 u421 u422 u423 u424 u425 u426 u427 u428 u429 u430 u431 u432 u433 u434 u435 u436 u437 u438 u439 u440 u441 u442 u443 u444 u445 u446 u447 u448 u449 u450 u451 u452 u453 u454 u455 u456 u457 u458 u459 u460 u461 u462 u463 u464 u465 u466 u467 u468 u469 u470 u471 u472 u473 u474 u475 u476 u477 u478 u479 u480 u481 u482 u483 u484 u485 u486 u487 u488 u489 u490 u491 u492 u493 u494 u495 u496 u497 u498 u499
	u500 u501 u502 u503 u504 u505 u506 u507 u508 u509 u510 u511 u512 u513 u514 u515 u516 u517 u518 u519 u520 u521 u522 u523 u524 u525 u526 u527 u528 u529 u530 u531 u532 u533 u534 u535 u536 u537 u538 u539 u540 u541 u542 u543 u544 u545 u546 u547 u548 u549 u550 u551 u552 u553 u554 u555 u556 u557 u558 u559 u560 u561 u562 u563 u564 u565 u566 u567 u568 u569 u570 u571 u572 u573 u574 u575 u576 u577 u578 u579 u580 u581 u582 u583 u584 u585 u586 u587 u588 u589 u590 u591 u592 u593 u594 u595 u596 u597 u598 u599
	u600 u601 u602 u603 u604 u605 u606 u607 u608 u609 u610 u611 u612 u613 u614 u615 u616 u617 u618 u619 u620 u621 u622 u623 u624 u625 u626 u627 u628 u629 u630 u631 u632 u633 u634 u635 u636 u637 u638 u639 u640 u641 u642 u643 u644 u645 u646 u647 u648 u649 u650 u651 u652 u653 u654 u655 u656 u657 u658 u659 u660 u661 u662 u663 u664 u665 u666 u667 u668 u669 u670 u671 u672 u673 u674 u675 u676 u677 u678 u679 u680 u681 u682 u683 u684 u685 u686 u687 u688 u689 u690 u691 u692 u693 u694 u695 u696 u697 u698 u699
	u700 u701 u702 u703 u704 u705 u706 u707 u708 u709 u710 u711 u712 u713 u714 u715 u716 u717 u718 u719 u720 u721 u722 u723 u724 u725 u726 u727 u728 u729 u730 u731 u732 u733 u734 u735 u736 u737 u738 u739 u740 u741 u742 u743 u744 u745 u746 u747 u748 u749 u750 u751 u752 u753 u754 u755 u756 u757 u758 u759 u760 u761 u762 u763 u764 u765 u766 u767 u768 u769 u770 u771 u772 u773 u774 u775 u776 u777 u778 u779 u780 u781 u782 u783 u784 u785 u786 u787 u788 u789 u790 u791 u792 u793 u794 u795 u796 u797 u798 u799
	u800 u801 u802 u803 u804 u805 u806 u807 u808 u809 u810 u811 u812 u813 u814 u815 u816 u817 u818 u819 u820 u821 u822 u823 u824 u825 u826 u827 u828 u829 u830 u831 u832 u833 u834 u835 u836 u837 u838 u839 u840 u841 u842 u843 u844 u845 u846 u847 u848 u849 u850 u851 u852 u853 u854 u855 u856 u857 u858 u859 u860 u861 u862 u863 u864 u865 u866 u867 u868 u869 u870 u871 u872 u873 u874 u875 u876 u877 u878 u879 u880 u881 u882 u883 u884 u885 u886 u887 u888 u889 u890 u891 u892 u893 u894 u895 u896 u897 u898 u899
	u900 u901 u902 u903 u904 u905 u906 u907 u908 u909 u910 u911 u912 u913 u914 u915 u916 u917 u918 u919 u920 u921 u922 u923 u924 u925 u926 u927 u928 u929 u930 u931 u932 u933 u934 u935 u936 u937 u938 u939 u940 u941 u942 u943 u944 u945 u946 u947 u948 u949 u950 u951 u952 u953 u954 u955 u956 u957 u958 u959 u960 u961 u962 u963 u964 u965 u966 u967 u968 u969 u970 u971 u972 u973 u974 u975 u976 u977 u978 u979 u980 u981 u982 u983 u984 u985 u986 u987 u988 u989 u990 u991 u992 u993 u994 u995 u996 u997 u998 u999
))

(define-map rune-tokens-id-map (buff 26) principal)
(define-map rune-tokens-active principal bool)
(define-map ordinals-contracts principal bool)
(define-map processed-tx-hashes (buff 36) bool)

(define-map available-peg-out-key-utxo uint (buff 36))

(define-private (get-iterator (size uint))
	(ok (unwrap! (slice? ITERATOR u0 size) ERR-UNWRAP-ITERATOR))
)

(define-private (add-peg-out-key-utxo-fold (id uint) (state (response { key-utxos: (list 1000 (buff 36)) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(key-utxo (unwrap! (element-at? (get key-utxos unwrapped-state) id) ERR-WRONG-ARRAY-SIZE))
			(total-key-utxo (var-get total-amount-key-utxo))
		)
		(map-set available-peg-out-key-utxo total-key-utxo key-utxo)
		(var-set total-amount-key-utxo (+ total-key-utxo u1))
		state
	)
)

(define-public (add-peg-out-key-utxo (key-utxos (list 1000 (buff 36))))
	(let
		(
			(it (try! (get-iterator (len key-utxos))))
		)
		(asserts! (> (len key-utxos) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(try! (fold add-peg-out-key-utxo-fold it (ok {key-utxos: key-utxos})))
		(ok true)
	)
)

(define-private (remove-peg-out-key-utxo-fold (id uint) (state (response { keys: (list 1000 uint) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(key (unwrap! (element-at? (get keys unwrapped-state) id) ERR-WRONG-ARRAY-SIZE))
			(total-key-utxo (var-get total-amount-key-utxo))
			(pre-last-key (- total-key-utxo u1))
			(pre-last-key-utxo (unwrap! (map-get? available-peg-out-key-utxo pre-last-key) ERR-UNWRAP-PRE-LAST-UTXO))
		)
		(asserts! (>= key (var-get current-key-utxo)) ERR-REMOVING-USED-KEY-UTXO)
		(asserts! (< key total-key-utxo) ERR-REMOVING-NOT-EXISTING-KEY)
		(map-delete available-peg-out-key-utxo pre-last-key)
		(if (< key pre-last-key) (map-set available-peg-out-key-utxo key pre-last-key-utxo) false)

		(var-set total-amount-key-utxo (- total-key-utxo u1))
		state
	)
)

(define-public (remove-peg-out-key-utxo (keys (list 1000 uint)))
	(let
		(
			(it (try! (get-iterator (len keys))))
		)
		(asserts! (> (len keys) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(try! (fold remove-peg-out-key-utxo-fold it (ok {keys: keys})))
		(ok true)
	)
)

(define-read-only (get-current-key-utxo)
	(var-get current-key-utxo)
)

(define-read-only (get-total-amount-key-utxo)
	(var-get total-amount-key-utxo)
)

(define-read-only (get-btc-token)
	(ok (var-get btc-token))
)

(define-read-only (get-rune-token-by-id (rune (buff 26)))
	(let 
		(
			(rune-contract (unwrap! (map-get? rune-tokens-id-map rune) ERR-NO-SUCH-RUNE))
		)
		(ok { address: rune-contract, is-active: (map-get? rune-tokens-active rune-contract)})
	)
)

(define-read-only (get-is-rune-token-active (rune principal))
	(map-get? rune-tokens-active rune)
)

(define-read-only (get-is-ordinals-contract-active (ordinals-contract principal))
	(map-get? ordinals-contracts ordinals-contract)
)

(define-read-only (get-is-btc-paused)
	(var-get btc-paused)
)

(define-public (set-btc-token (btc-contract principal))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(ok (var-set btc-token btc-contract))
	)
)

(define-public (set-btc-paused (is-paused bool))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(ok (var-set btc-paused is-paused))
	)
)

(define-public (set-rune-token-by-id (rune (buff 26)) (rune-contract principal) (is-active bool))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(map-set rune-tokens-id-map rune rune-contract)
		(ok (map-set rune-tokens-active rune-contract is-active))
	)
)

(define-public (set-rune-token-active (rune (buff 26)) (is-active bool))
	(let 
		(
			(rune-contract (unwrap! (map-get? rune-tokens-id-map rune) ERR-NO-SUCH-RUNE))
		)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(ok (map-set rune-tokens-active rune-contract is-active))
	)
)

(define-public (set-ordinals-contract-active (ordinals-contract principal) (is-active bool))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(ok (map-set ordinals-contracts ordinals-contract is-active))
	)
)

(define-private (check-if-exists-and-mark (tx-hash-and-vout (buff 36)))
	(let 
		(
			(exists (default-to false (map-get? processed-tx-hashes tx-hash-and-vout)))
		)
		(asserts! (not exists) ERR-HASH-EXISTS)
		(ok (map-set processed-tx-hashes tx-hash-and-vout true))
	)
)

(define-private (check-utxo-increment (network (buff 12)))
	(ok (if (is-eq network 0x425443) (try! (get-and-increment-utxo)) 0x))
)

(define-private (get-and-increment-utxo)
	(let
		( 
			(key-utxo-index (var-get current-key-utxo))
		)
		(var-set current-key-utxo (+ key-utxo-index u1))
		(ok (unwrap! (map-get? available-peg-out-key-utxo key-utxo-index) ERR-NO-KEY-UTXO))
	)
)

(define-read-only (get-if-exists-fold (id uint) (state (response { tx-hashes-and-vout: (list 1000 (buff 36)), exists: (list 1000 bool) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(tx-hash-and-vout (unwrap! (element-at? (get tx-hashes-and-vout unwrapped-state) id) ERR-WRONG-ARRAY-SIZE))
			(exists (default-to false (map-get? processed-tx-hashes tx-hash-and-vout)))
		)
		(ok (merge unwrapped-state { exists: (unwrap! (as-max-len? (append (get exists unwrapped-state) exists) u1000) ERR-WRONG-ARRAY-SIZE) }))
	)
)

(define-read-only (get-if-exists-batch (tx-hashes-and-vout (list 1000 (buff 36))))
	(let
		(
			(it (try! (get-iterator (len tx-hashes-and-vout))))
		)
		(ok (get exists (try! (fold get-if-exists-fold it (ok {tx-hashes-and-vout: tx-hashes-and-vout, exists: (list)})))))
	)
)

(define-read-only (get-key-utxo-fold (id uint) (state (response { keys: (list 1000 uint), key-utxos: (list 1000 (buff 36)) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(key (unwrap! (element-at? (get keys unwrapped-state) id) ERR-WRONG-ARRAY-SIZE))
			(key-utxo (default-to 0x (map-get? available-peg-out-key-utxo key)))
		)
		(ok (merge unwrapped-state { key-utxos: (unwrap! (as-max-len? (append (get key-utxos unwrapped-state) key-utxo) u1000) ERR-WRONG-ARRAY-SIZE) }))
	)
)

(define-read-only (get-key-utxo-batch (keys (list 1000 uint)))
	(let
		(
			(it (try! (get-iterator (len keys))))
		)
		(ok (get key-utxos (try! (fold get-key-utxo-fold it (ok {keys: keys, key-utxos: (list)})))))
	)
)

(define-private (mint-runes-fold (id-to-mint uint) (state (response { rune-contracts: (list 100 <bridge-ft-trait>), amounts: (list 100 uint), recipients: (list 100 principal), tx-hashes-and-vout: (list 100 (buff 36)) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(rune-contract (unwrap! (element-at? (get rune-contracts unwrapped-state) id-to-mint) ERR-UNWRAP-CONTRACT))
			(recipient (unwrap! (element-at? (get recipients unwrapped-state) id-to-mint) ERR-UNWRAP-RECIPIENT))
			(amount (unwrap! (element-at? (get amounts unwrapped-state) id-to-mint) ERR-UNWRAP-AMOUNT))
			(tx-hash-and-vout (unwrap! (element-at? (get tx-hashes-and-vout unwrapped-state) id-to-mint) ERR-UNWRAP-TX-HASH))
		)
		(try! (check-if-exists-and-mark tx-hash-and-vout))
		(asserts! (default-to false (map-get? rune-tokens-active (contract-of rune-contract))) ERR-RUNE-NOT-ACTIVE)
		(try! (as-contract (contract-call? rune-contract mint amount recipient)))
		state
	)
)

(define-public (mint-runes-batch (rune-contracts (list 100 <bridge-ft-trait>)) (amounts (list 100 uint)) (recipients (list 100 principal)) (tx-hashes-and-vout (list 100 (buff 36))))
	(let
		(
			(it (try! (get-iterator (len amounts))))
		)
		(asserts! (and (and (is-eq (len amounts) (len rune-contracts)) (is-eq (len amounts) (len recipients))) (is-eq (len amounts) (len tx-hashes-and-vout))) ERR-WRONG-ARRAY-SIZE)
		(asserts! (> (len amounts) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))

		(try! (fold mint-runes-fold  it (ok {rune-contracts: rune-contracts, amounts: amounts, recipients: recipients, tx-hashes-and-vout: tx-hashes-and-vout})))
		(ok true)
	)
)

(define-public (mint-runes-batch-from-btc (rune-contracts (list 100 <bridge-ft-trait>)) (amounts (list 100 uint)) (recipients (list 100 principal)) (tx-hashes-and-vout (list 100 (buff 36))) (burn-hash (buff 32)) (burn-height uint))
	(let
		(
			(it (try! (get-iterator (len amounts))))
		)
		(asserts! (and (and (is-eq (len amounts) (len rune-contracts)) (is-eq (len amounts) (len recipients))) (is-eq (len amounts) (len tx-hashes-and-vout))) ERR-WRONG-ARRAY-SIZE)
		(asserts! (> (len amounts) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		;; Verify that Bitcoin hasn't forked by comparing the burn hash provided
		(asserts! (is-eq (some burn-hash) (get-burn-header burn-height)) ERR_INVALID_BURN_HASH)

		(try! (fold mint-runes-fold  it (ok {rune-contracts: rune-contracts, amounts: amounts, recipients: recipients, tx-hashes-and-vout: tx-hashes-and-vout})))
		(ok true)
	)
)

(define-public (mint-btc (btc-contract <bridge-ft-trait>) (amount uint) (recipient principal) (tx-hash-and-vout (buff 36)))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(try! (check-if-exists-and-mark tx-hash-and-vout))

		(asserts! (is-eq (var-get btc-token) (contract-of btc-contract)) ERR-WRONG-BTC-CONTRACT)
		(asserts! (not (var-get btc-paused)) ERR-PAUSED)

		(as-contract (contract-call? btc-contract mint amount recipient))
	)
)

(define-public (mint-btc-from-btc (btc-contract <bridge-ft-trait>) (amount uint) (recipient principal) (tx-hash-and-vout (buff 36)) (burn-hash (buff 32)) (burn-height uint))
	(begin
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(try! (check-if-exists-and-mark tx-hash-and-vout))
		;; Verify that Bitcoin hasn't forked by comparing the burn hash provided
		(asserts! (is-eq (some burn-hash) (get-burn-header burn-height)) ERR_INVALID_BURN_HASH)

		(asserts! (is-eq (var-get btc-token) (contract-of btc-contract)) ERR-WRONG-BTC-CONTRACT)
		(asserts! (not (var-get btc-paused)) ERR-PAUSED)

		(as-contract (contract-call? btc-contract mint amount recipient))
	)
)

(define-read-only (get-burn-header (height uint))
    ;; (get-burn-block-info? header-hash height)
    (get-tenure-info? burnchain-header-hash height)
)

(define-private (mint-ordinals-fold (id-to-mint uint) (state (response { ordinals-contract: <bridge-nft-trait>, ids: (list 1000 uint), recipients: (list 1000 principal), tx-hashes-and-vout: (list 1000 (buff 36)) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(id (unwrap! (element-at? (get ids unwrapped-state) id-to-mint) ERR-UNWRAP-ID))
			(ordinals-contract (get ordinals-contract unwrapped-state))
			(recipient (unwrap! (element-at? (get recipients unwrapped-state) id-to-mint) ERR-UNWRAP-RECIPIENT))
			(tx-hash-and-vout (unwrap! (element-at? (get tx-hashes-and-vout unwrapped-state) id-to-mint) ERR-UNWRAP-TX-HASH))
		)
		(try! (check-if-exists-and-mark tx-hash-and-vout))
		(try! (as-contract (contract-call? ordinals-contract mint id recipient)))
		state
	)
)

(define-public (mint-ordinals-batch (ordinals-contract <bridge-nft-trait>) (ids (list 1000 uint)) (recipients (list 1000 principal)) (tx-hashes-and-vout (list 1000 (buff 36))))
	(let
		(
			(it (try! (get-iterator (len ids))))
		)
		(asserts! (and (is-eq (len recipients) (len ids)) (is-eq (len ids) (len tx-hashes-and-vout))) ERR-WRONG-ARRAY-SIZE)
		(asserts! (> (len recipients) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(asserts! (default-to false (map-get? ordinals-contracts (contract-of ordinals-contract))) ERR-ORDINALS-CONTRACT-NOT-ACTIVE)

		(try! (fold mint-ordinals-fold it (ok {ordinals-contract: ordinals-contract, ids: ids, recipients: recipients, tx-hashes-and-vout: tx-hashes-and-vout})))
		(ok true)
	)
)

(define-public (mint-ordinals-batch-from-btc (ordinals-contract <bridge-nft-trait>) (ids (list 1000 uint)) (recipients (list 1000 principal)) (tx-hashes-and-vout (list 1000 (buff 36))) (burn-hash (buff 32)) (burn-height uint))
	(let
		(
			(it (try! (get-iterator (len ids))))
		)
		;; Verify that Bitcoin hasn't forked by comparing the burn hash provided
		(asserts! (is-eq (some burn-hash) (get-burn-header burn-height)) ERR_INVALID_BURN_HASH)
		(asserts! (and (is-eq (len recipients) (len ids)) (is-eq (len ids) (len tx-hashes-and-vout))) ERR-WRONG-ARRAY-SIZE)
		(asserts! (> (len recipients) u0) ERR-EMPTY-ARRAY)
		(try! (contract-call? .pontis-bridge-controller authorize-bridge-owner))
		(asserts! (default-to false (map-get? ordinals-contracts (contract-of ordinals-contract))) ERR-ORDINALS-CONTRACT-NOT-ACTIVE)

		(try! (fold mint-ordinals-fold it (ok {ordinals-contract: ordinals-contract, ids: ids, recipients: recipients, tx-hashes-and-vout: tx-hashes-and-vout})))
		(ok true)
	)
)

(define-public (bridge-out-runes (rune (buff 26)) (rune-contract <bridge-ft-trait>) (amount uint) (recipient (buff 64)) (network (buff 12)))
	(let
		(
			(percent-fee (contract-call? .pontis-bridge-fee-manager-2 calculate-runes-percent-fee amount))
			(key-utxo (try! (check-utxo-increment network)))
			(rune-token-by-id (unwrap! (get-rune-token-by-id rune) ERR-NO-SUCH-RUNE))
			(sender tx-sender)
		)
		(asserts! (is-eq (get address rune-token-by-id) (contract-of rune-contract)) ERR-WRONG-RUNE-CONTRACT)
		(asserts! (default-to false (map-get? rune-tokens-active (contract-of rune-contract))) ERR-RUNE-NOT-ACTIVE)
		(asserts! (>= amount (unwrap! (contract-call? .pontis-bridge-fee-manager-2 get-min-runes-bridge (contract-of rune-contract)) ERR-MIN-AMOUNT-UNWRAP)) ERR-MIN-AMOUNT)

		(try! (contract-call? .pontis-bridge-fee-manager-2 pay-stx-fee (unwrap! (contract-call? .pontis-bridge-fee-manager-2 get-runes-base-fee network) ERR-BASE-FEE-UNWRAP)))
		(try! (contract-call? .pontis-bridge-fee-manager-2 pay-ft-fee percent-fee rune-contract))

		(print {operation: "runes", key-utxo: key-utxo, percent-fee: percent-fee, rune: rune, amount: amount, recipient: recipient, network: network})
		(as-contract (contract-call? rune-contract burn (- amount percent-fee) sender))
	)
)

(define-public (bridge-out-btc (btc-contract <bridge-ft-trait>) (amount uint) (recipient (buff 64)) (network (buff 12)))
	(let
		(
			(percent-fee (contract-call? .pontis-bridge-fee-manager-2 calculate-btc-percent-fee amount))
			(key-utxo (try! (check-utxo-increment network)))
			(sender tx-sender)
		)

		(asserts! (is-eq (var-get btc-token) (contract-of btc-contract)) ERR-WRONG-BTC-CONTRACT)
		(asserts! (not (var-get btc-paused)) ERR-PAUSED)
		(asserts! (>= amount (unwrap! (contract-call? .pontis-bridge-fee-manager-2 get-min-btc-bridge) ERR-MIN-AMOUNT-UNWRAP)) ERR-MIN-AMOUNT)

		(try! (contract-call? .pontis-bridge-fee-manager-2 pay-stx-fee (unwrap! (contract-call? .pontis-bridge-fee-manager-2 get-btc-base-fee network) ERR-BASE-FEE-UNWRAP)))
		(try! (contract-call? .pontis-bridge-fee-manager-2 pay-ft-fee percent-fee btc-contract))

		(print {operation: "btc", key-utxo: key-utxo, percent-fee: percent-fee, amount: amount, recipient: recipient, network: network})
		(as-contract (contract-call? btc-contract burn (- amount percent-fee) sender))
	)
)


(define-private (peg-out-ordinals-fold (id-to-burn uint) (state (response { ordinals-contract: <bridge-nft-trait>, ids: (list 1000 uint) } uint)))
	(let
		(
			(unwrapped-state (try! state))
			(ordinals-contract (get ordinals-contract unwrapped-state))
			(id (unwrap! (element-at? (get ids unwrapped-state) id-to-burn) ERR-UNWRAP-HASH))
			(sender tx-sender)
		)
		(try! (as-contract (contract-call? ordinals-contract burn id sender)))
		state
	)
)

(define-public (peg-out-ordinals-batch (ordinals-contract <bridge-nft-trait>) (ids (list 1000 uint)) (recipients (list 1000 (buff 64))))
	(let
		(
			(it (try! (get-iterator (len ids))))
			(key-utxo (try! (check-utxo-increment 0x425443))) ;; Ordinals can be only wrapped and unwrapped
		)
		(try! (contract-call? .pontis-bridge-fee-manager-2 pay-ordinals-stx-fee (len ids)))
		(asserts! (default-to false (map-get? ordinals-contracts (contract-of ordinals-contract))) ERR-ORDINALS-CONTRACT-NOT-ACTIVE)

		(asserts! (is-eq (len recipients) (len ids)) ERR-WRONG-ARRAY-SIZE)
		(asserts! (> (len recipients) u0) ERR-EMPTY-ARRAY)
		(try! (fold peg-out-ordinals-fold it (ok {ordinals-contract: ordinals-contract, ids: ids})))
		(print {operation: "ordinals", key-utxo: key-utxo, ids: ids, recipients: recipients, ordinals-contract: ordinals-contract})
		(ok true)
	)
)

```
