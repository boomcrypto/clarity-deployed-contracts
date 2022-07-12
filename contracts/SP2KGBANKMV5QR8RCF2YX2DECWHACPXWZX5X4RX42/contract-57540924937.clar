;; DEPLOY CONTRACT
;;
;; Demonstrates how to publish a simple contract, then call it.
;; -> Before you proceed, sign in using the button in the top right corner.

;; Defining a simple function to get your stx balance:

(define-read-only (my-stx-balance)
  (stx-get-balance contract-caller))

;; Verifying the function returns a balance above zero:



;; If the balance is zero, use the faucet to top it up:
;; https://explorer.stacks.co/sandbox/faucet

;; Publish the contract using Deploy Contract from the Toolbox menu.

;; The contract function can be called when the contract is deployed.
;; This test verifies that the balance from the contract call is correct:



;; Note: It may take a few minutes before the contract is ready.
;; The call will fail until the contract has been fully deployed.
;; If the response says no such contract exists, wait, then refresh the call
;; by typing in the editor.

;;
