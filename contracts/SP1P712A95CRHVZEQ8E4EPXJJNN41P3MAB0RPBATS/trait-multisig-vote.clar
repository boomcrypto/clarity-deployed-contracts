(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)

(define-trait multisig-vote-trait
  (
    (propose (uint (string-utf8 256) (string-utf8 256) uint uint) (response uint uint))
    (vote-for (<ft-trait> uint uint) (response uint uint))  
    (vote-against (<ft-trait> uint uint) (response uint uint))  
    (end-proposal (uint) (response bool uint))
    (return-votes-to-member (<ft-trait> uint principal) (response bool uint))
  )
)

(define-trait multisig-vote-sft-trait
  (
    (propose (uint uint (string-utf8 256) (string-utf8 256) uint uint) (response uint uint))
    (vote-for (<sft-trait> uint uint) (response uint uint))  
    (vote-against (<sft-trait> uint uint) (response uint uint))  
    (end-proposal (uint) (response bool uint))
    (return-votes-to-member (<sft-trait> uint principal) (response bool uint))
  )
)