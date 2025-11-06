;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (begin
    ;; Create the vote
    (try! (contract-call? 'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.alex-voting-v1-01 create-vote
      u"ALEX Governance Proposal: LiaBTC Emissions Vote"
      u"## ALEX Governance Proposal: LiaBTC Emissions Vote is Now Live \u{1f5f3}\n![2025-09-24 13.02.52.jpg](https://imagedelivery.net/Cf_H0cL_1lwKJtdaD6H5NQ/64d20e7a-e3ae-45d1-dae9-435620e65600/public)\n\nSubject to governance vote approval, the ALEX Lab Foundation proposes:\n\n\u{1f538} Allocating $aBTC - $LiaBTC emissions toward the $STX - $ALEX pool from cycle #346 onward\n\n\u{1f4d6} Full Proposal: [Click here](https://medium.com/alexgobtc/alex-governance-proposal-liabtc-emissions-and-roadmap-update-860c713218a6) \n\n\u{1f4ac} Live community discussion channel: [Click here ](https://discord.com/channels/856358412303990794/1420214819507929138)\n\n__\u{23f3} Voting Opens:__ 26th September 2025 <br>\n__\u{231b}\u{fe0f} Voting Closes:__ 3rd October 2025\n\nMake your voice count, be sure to cast your vote \u{2705}"
      u1758895200
      u1759500000
      (list u"Approve" u"Disapprove" u"Abstain")
      none))

    (ok true)))
