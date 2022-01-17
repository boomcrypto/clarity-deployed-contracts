;; DEPLOY CONTRACT
;;
;; Demonstrates how to publish a simple contract, then call it.
;; -> Before you proceed, sign in using the button in the top right corner.

;; Defining a simple function to get your stx balance:

(define-read-only (my-stx-balance) 
  (stx-get-balance contract-caller))

;; Verifying the function returns a balance above zero - if not, rectify
;; by requesting more funds from the Faucet of Blockstack Explorer:


 
;; -> Publish the contract using Deploy Contract from the toolbox menu
;; then replace the string below with the name of the published contract:

(define-constant contract 
  .contract-0)

;; The contract function can be called when the contract is deployed.
;; The test verifies that the balance from the contract call is correct.



;; Note: It may take a few minutes before the contract is ready.
;; If it says no such contract exists, wait then refresh the call 
;; by typing in the editor.

;;
