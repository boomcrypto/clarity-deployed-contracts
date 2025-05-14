;; SPDX-License-Identifier: BUSL-1.1

;; AGP-473 Proposal Contract
;;
;; This contract implements the proposal-trait and is intended to be executed by the DAO.
;; Its purpose is to update the set of enabled extensions in the system, specifically:
;;   - Disables the old self-farming-helper-v2-01 extension
;;   - Enables the new self-farming-helper-v2-02 extension
;;
;; This is done by calling the `set-extensions` function on the executor-dao contract,
;; passing a list of extension status objects.
;;
;; The execute function can only be called by the executor DAO.

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places (not used in this proposal, but included for consistency)

;; The main entry point for the proposal.
;; When executed, it updates the enabled/disabled status of the relevant extensions.
(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3KHTHEDJ6P9R33RT1P703JWAMS3MJJQ0N9BGQKT))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP3JEC294V9ES53KBPCBA95CZER2HD8330NGTQPNV))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.migrate-legacy-v2-wl finalise-migrate 'SP2417H88DQFN7FNDMSKM9N0B3Q6GNGEM40W7ZAZW))

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer-fixed (* u3700000 ONE_8) tx-sender 'SPFD5XBCJWX0RJP35N6YF4S32JWRVXKGZCQ0BX7S none))
        (ok true)
    )
)

