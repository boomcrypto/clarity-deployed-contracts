
;; Type: Social
;; Author: SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20
;; Title: MDP-009
;; Description: Summary: Very simple web application that simulates combining various apes with suits.  Cost: 300 $MEGA  Details: - the simple application will accept ape and suit IDs to preview - multiple IDs can be provided - you can preview apes and suits you do not own  - preview for suit on and off (yes, naked apes) - will be made available on IPFS - no support or further enhancements guaranteed - payment after delivery if "DAO" is happy - when? Very soon of course.

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
