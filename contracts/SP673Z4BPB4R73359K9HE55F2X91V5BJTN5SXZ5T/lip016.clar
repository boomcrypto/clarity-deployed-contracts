
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list 
      { extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.liabtc-mint-endpoint, enabled: true })))
    (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.liabtc-mint-endpoint set-mint-paused false))
    (try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.liabtc-mint-endpoint set-burn-paused false))
		(ok true)))