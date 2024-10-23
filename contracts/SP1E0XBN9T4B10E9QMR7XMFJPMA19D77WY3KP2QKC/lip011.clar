
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list 
      { extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-endpoint, enabled: false }
      { extension: .auto-alex-v3-endpoint-v2, enabled: true } )))
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-endpoint pause-create true))
    (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.auto-alex-v3-endpoint pause-redeem true))
    (try! (contract-call? .auto-alex-v3-endpoint-v2 pause-create false))
    (try! (contract-call? .auto-alex-v3-endpoint-v2 pause-redeem false))    
		(ok true)))