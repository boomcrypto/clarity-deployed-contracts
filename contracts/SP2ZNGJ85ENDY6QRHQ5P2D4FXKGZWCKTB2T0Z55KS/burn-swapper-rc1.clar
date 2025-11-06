;; Title: Burn Swap Router - Fixed Version
;; Version: 1.1.0
;; Description: 
;;   Executes a strategy by burning LP tokens, swapping the underlying assets
;;   through multiple hops. Fixed to properly handle multihop return types.

;; Use Traits
(use-trait pool-trait .dexterity-traits-v0.liquidity-pool-trait)
(use-trait ft-trait .charisma-traits-v1.sip010-ft-trait)

;; Constants
(define-constant CONTRACT (as-contract tx-sender))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_OPERATION (err u401))
(define-constant ERR_TRANSFER_FAILED (err u402))
(define-constant ERR_MULTIHOP_RESULT (err u404))

;; Opcodes for pool operations
(define-constant OP_SWAP_A_TO_B 0x00)
(define-constant OP_SWAP_B_TO_A 0x01)
(define-constant OP_ADD_LIQUIDITY 0x02)
(define-constant OP_REMOVE_LIQUIDITY 0x03)

;; Helper function to extract final amount from multihop result
(define-private (get-final-amount (multihop-result (list 10 {dx: uint, dy: uint, dk: uint})))
  (get dy (unwrap-panic (element-at multihop-result (- (len multihop-result) u1)))))

;; @desc Execute 0-hop/1-hop burn-swap (Token A no swap, Token B 1-hop)
(define-public (execute-burn-swap-0-1
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a <ft-trait>)
    (token-b-final <ft-trait>)
    (token-b-hop {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Token A stays as-is, Token B gets swapped via 1-hop
      (let ((token-b-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dy burn-result) 
                                                token-b-hop)))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get dx burn-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-amount: token-a-amount,
            token-b-multihop: token-b-result
          }))))))

;; @desc Execute 0-hop/2-hop burn-swap (Token A no swap, Token B 2-hop)
(define-public (execute-burn-swap-0-2
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a <ft-trait>)
    (token-b-final <ft-trait>)
    (token-b-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Token A stays as-is, Token B gets swapped via 2-hop
      (let ((token-b-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dy burn-result) 
                                                (get hop-1 token-b-hops) 
                                                (get hop-2 token-b-hops))))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get dx burn-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-amount: token-a-amount,
            token-b-multihop: token-b-result
          }))))))

;; @desc Execute 1-hop/0-hop burn-swap (Token A 1-hop, Token B no swap)
(define-public (execute-burn-swap-1-0
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b <ft-trait>)
    (token-a-hop {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Token A gets swapped via 1-hop, Token B stays as-is
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dx burn-result) 
                                                token-a-hop)))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get dy burn-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-amount: token-b-amount
          }))))))

;; @desc Execute 2-hop/0-hop burn-swap (Token A 2-hop, Token B no swap)
(define-public (execute-burn-swap-2-0
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b <ft-trait>)
    (token-a-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Token A gets swapped via 2-hop, Token B stays as-is
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dx burn-result) 
                                                (get hop-1 token-a-hops) 
                                                (get hop-2 token-a-hops))))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get dy burn-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-amount: token-b-amount
          }))))))

;; @desc Execute 1-hop/1-hop burn-swap
(define-public (execute-burn-swap-1-1
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b-final <ft-trait>)
    (token-a-hop {pool: <pool-trait>, opcode: (optional (buff 16))})
    (token-b-hop {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Execute 1-hop swaps for both tokens using .multihop
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dx burn-result) 
                                                token-a-hop))))
            (token-b-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dy burn-result) 
                                                token-b-hop)))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-multihop: token-b-result
          }))))))

;; @desc Execute 1-hop/2-hop burn-swap
(define-public (execute-burn-swap-1-2
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b-final <ft-trait>)
    (token-a-hop {pool: <pool-trait>, opcode: (optional (buff 16))})
    (token-b-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Execute swaps using .multihop
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dx burn-result) 
                                                token-a-hop))))
            (token-b-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dy burn-result) 
                                                (get hop-1 token-b-hops) 
                                                (get hop-2 token-b-hops))))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-multihop: token-b-result
          }))))))

;; @desc Execute 2-hop/1-hop burn-swap
(define-public (execute-burn-swap-2-1
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b-final <ft-trait>)
    (token-a-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}})
    (token-b-hop {pool: <pool-trait>, opcode: (optional (buff 16))}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Execute swaps using .multihop
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dx burn-result) 
                                                (get hop-1 token-a-hops) 
                                                (get hop-2 token-a-hops)))))
            (token-b-result (try! (as-contract (contract-call? .multihop swap-1 
                                                (get dy burn-result) 
                                                token-b-hop)))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-multihop: token-b-result
          }))))))

;; @desc Execute 2-hop/2-hop burn-swap
(define-public (execute-burn-swap-2-2
    (lp-pool <pool-trait>)
    (lp-token <ft-trait>)
    (lp-amount uint)
    (token-a-final <ft-trait>)
    (token-b-final <ft-trait>)
    (token-a-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}})
    (token-b-hops {hop-1: {pool: <pool-trait>, opcode: (optional (buff 16))}, hop-2: {pool: <pool-trait>, opcode: (optional (buff 16))}}))
  (let (
    (sender tx-sender))
    
    ;; Step 1: Transfer LP tokens to contract
    (try! (contract-call? lp-token transfer lp-amount sender CONTRACT none))
    
    ;; Step 2: Burn LP tokens to get underlying assets (dx = token A, dy = token B)
    (let ((burn-result (try! (as-contract (contract-call? lp-pool execute lp-amount (some OP_REMOVE_LIQUIDITY))))))
      
      ;; Step 3: Execute 2-hop swaps for both tokens using .multihop
      (let ((token-a-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dx burn-result) 
                                                (get hop-1 token-a-hops) 
                                                (get hop-2 token-a-hops)))))
            (token-b-result (try! (as-contract (contract-call? .multihop swap-2 
                                                (get dy burn-result) 
                                                (get hop-1 token-b-hops) 
                                                (get hop-2 token-b-hops))))))
        
        ;; Step 4: Transfer tokens back to sender using provided token contracts
        (let ((token-a-amount (get-final-amount token-a-result))
              (token-b-amount (get-final-amount token-b-result)))
          
          (try! (as-contract (contract-call? token-a-final transfer token-a-amount CONTRACT sender none)))
          (try! (as-contract (contract-call? token-b-final transfer token-b-amount CONTRACT sender none)))
          
          ;; Return the execution details
          (ok {
            burn-result: burn-result,
            token-a-multihop: token-a-result,
            token-b-multihop: token-b-result
          }))))))