;; title: aibtcdev-dao-traits-v1-1
;; version: 1.1.0
;; summary: A collection of traits for the aibtcdev DAO

;; IMPORTS

(use-trait faktory-token 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait)

;; EXTENSION TRAITS

(define-trait faktory-dex (
  ;; buy tokens from the dex
  ;; @param ft the token contract
  ;; @param ustx the amount of microSTX to spend
  ;; @returns (response bool uint)
  (buy (<faktory-token> uint) (response bool uint))
  ;; sell tokens to the dex
  ;; @param ft the token contract
  ;; @param amount the amount of tokens to sell
  ;; @returns (response bool uint)
  (sell (<faktory-token> uint) (response bool uint))
))
