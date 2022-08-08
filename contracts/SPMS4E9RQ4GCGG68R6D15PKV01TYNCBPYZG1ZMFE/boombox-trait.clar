(define-trait boombox-trait
  (
    (mint (uint principal uint {hashbytes: (buff 20), version: (buff 1)} uint) (response uint uint))
    (get-owner (uint) (response (optional principal) uint))
    (get-owner-at-block (uint uint) (response (optional principal) uint))
    (set-boombox-id (uint) (response bool uint))
  )
)