
;; Type: Social
;; Author: SP9J6BTSPCXGQ5HC066NRYQPK43S48V7K299PTQX
;; Title: MDP-008
;; Description: I propose to offer free generative nfts to the nft holders of collapsed blockchains. (not for this proposal but for example; Galactic Punks on Luna blockchain)  The party who is entitled for the free drop, would have to create a stacks wallet in order to receive their free claim generative nft, and prove ownership of the nft they are holding that is subject to the collapse.  The DAO would have to decide on how an nft project would be selected for this program, who would be involved in communication with these projects, how often and when that role/roles would change, and how the whole process would be carried out with additional proposals if this initial proposal gets approved.

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
