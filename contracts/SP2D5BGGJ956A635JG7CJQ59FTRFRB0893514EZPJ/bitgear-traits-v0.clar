(use-trait collection-contract  .nft-trait.nft-trait)
(use-trait gear-contract        .nft-trait.nft-trait)

(define-trait character-trait
  (
    (roll-character ((string-utf8 16) <collection-contract> uint) (response bool uint))

    (get-character (principal) 
      (response 
        (tuple 
          (name (string-utf8 16))
          (collection principal)
          (avatar uint) 
        )
        uint
      )
    )
  )
)

(define-trait equipment-trait
  (
    (initialize-equipment () (response bool uint))

    (equip-gear-main-hand (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-off-hand (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-two-hand (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-head (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-neck (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-wrists (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-right-ring-finger (<character-trait> <gear-contract> uint) (response bool uint))
    (equip-gear-left-ring-finger (<character-trait> <gear-contract> uint) (response bool uint))

    (get-equipment (principal) 
      (response 
        (tuple 
          (main-hand (optional uint)) 
          (off-hand (optional uint)) 
          (two-hand (optional uint)) 
          (head (optional uint)) 
          (neck (optional uint)) 
          (wrists (optional uint)) 
          (right-ring-finger (optional uint)) 
          (left-ring-finger (optional uint))
        )
        uint
      )
    )
  )
)