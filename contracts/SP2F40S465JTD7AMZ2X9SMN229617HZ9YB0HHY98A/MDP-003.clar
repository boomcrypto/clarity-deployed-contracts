
;; Type: Social
;; Author: SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A
;; Title: MDP-003
;; Description: Summary: DAO discord integration  Purpose:  Integrate Megapont governance activity with the Megapont discord server.  Deliverable: Any new DAO proposals will create a new thread in the Megapont discord server for discussion of that proposal. A role-based ping will go out to notify users of the new proposal.   Implementation: Open source STX event listener and discord bot.  Cost: 6000 MEGA paid to jake.stx.  Timeline: 1 week of proposal being passed.  Ongoing Support: Proposal will include 2 months of ongoing tech support and feature requests supported by jake.stx, after which time future development responsibilities will be handed off to the DAO.  Feature requests should be submitted through DAO proposals.  Needed from team: New dao-notifications role in the discord server. Discord bot access to create threads and send messages.

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
