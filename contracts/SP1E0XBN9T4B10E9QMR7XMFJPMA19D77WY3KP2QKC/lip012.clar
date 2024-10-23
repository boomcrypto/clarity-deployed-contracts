
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list 
      { extension: .auto-alex-v3-endpoint-v2, enabled: false }
      { extension: .auto-alex-v3-endpoint-v2-01, enabled: true } )))
    (try! (contract-call? .auto-alex-v3-endpoint-v2 pause-create true))
    (try! (contract-call? .auto-alex-v3-endpoint-v2 pause-redeem true))
    (try! (contract-call? .auto-alex-v3-endpoint-v2-01 pause-create false))
    (try! (contract-call? .auto-alex-v3-endpoint-v2-01 pause-redeem false))    
		(ok true)))