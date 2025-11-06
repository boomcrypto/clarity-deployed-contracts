;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (begin
    ;; Set the voting power contract
    (try! (contract-call? .alex-voting-v1-01 set-voting-power-contract .alex-voting-power-v1-02))
    
    ;; Set the voting power LP pools
    (try! (contract-call? .alex-voting-power-v1-02 set-voting-power-lp-pools (list u7 u10 u11 u12 u13 u20 u31 u32 u33 u34 u35 u36 u37 u38 u39 u41 u42 u43 u44 u46 u52 u53 u54 u56 u61 u70 u74 u75 u76 u77 u78 u80 u85 u88 u91 u95 u105 u111 u113 u115 u118 u119 u125 u130 u139 u147 u150 u151 u152 u161 u171)))
    
    ;; Create the vote
    (try! (contract-call? .alex-voting-v1-01 create-vote
      u"ALEX Governance Proposal: Year 4 Emissions Vote"
			u"![1_0WNKnI5iaqNmF4IZE5nC4Q.webp](https://imagedelivery.net/Cf_H0cL_1lwKJtdaD6H5NQ/68e3582b-87e0-4886-2146-38dc04070200/public)\n\n## ALEX Governance Proposal: Year 4 Emissions Vote is Now Live \u{1f5f3} ##\n\nSubject to governance vote approval, the ALEX Lab Foundation proposes:\n\n\u{1f538} Delay emissions halving to Cycle #400 <br>\n\u{1f538} Maintain current emissions, with option to increase by up to 36.5% vs. Year 3, subject to governance approval <br>\n\u{1f538} Redistribute emissions to farming pools identified as contributors to the ALEX ecosystem <br>\n\n\u{1f4d6} Full Proposal: [Click here](https://medium.com/alexgobtc/alex-governance-proposal-year-4-emissions-vote-69866312d3b4) <br>\n\u{1f4ac} Live community discussion channel: [Click here](https://discord.com/channels/856358412303990794/1386691415852974221)\n\n\u{23f3} Voting Opens: 28th June 2025 <br>\n\u{231b} Voting Closes: 5th July 2025 <br>\n\nMake your voice count, be sure to cast your vote \u{2705}"
      u1751124600
      u1751729400
      (list u"Approve" u"Disapprove" u"Abstain")
      none))
    
    (ok true)))
