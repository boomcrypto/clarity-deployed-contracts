;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant amount u823)
(define-constant recipient 'SP3841J71KW7PE3CK00YD436TT555CC9J14J6BPBS)

(define-public (execute (sender principal))
  (begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda transfer-fixed (* amount ONE_8) tx-sender recipient none))
    (ok true)))
