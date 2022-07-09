
;; Type: Social
;; Author: SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20
;; Title: MDP-002
;; Description: The Megapont Robot factory is a wonderful place so we want more components, animated or not, to further hone the art of Robot-making.

  (impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

  (define-public (execute (sender principal))
    (begin
      (print {event: "execute", sender: sender})
      (ok true)
    )
  )
