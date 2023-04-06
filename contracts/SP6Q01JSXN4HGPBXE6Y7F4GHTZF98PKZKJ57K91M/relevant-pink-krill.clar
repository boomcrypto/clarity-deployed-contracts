(define-read-only (get-reward-at-block-read (block-number uint)) 
(begin 
  {reward: (get-block-info? block-reward block-number), 
  claimer: (get-block-info? miner-address block-number)}))
