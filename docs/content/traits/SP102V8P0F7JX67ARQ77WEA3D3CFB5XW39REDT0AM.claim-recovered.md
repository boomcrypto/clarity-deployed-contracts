---
title: "Trait claim-recovered"
draft: true
---
```
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.extension-trait.extension-trait)
(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(use-trait extension-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.extension-trait.extension-trait)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-EXTENSION-NOT-AUTHORIZED (err u1001))
(define-constant ERR-ALREADY-CLAIMED (err u1002))
(define-constant ERR-CANNOT-UPDATE (err u1003))
(define-constant ERR-RECIPIENT-NOT-FOUND (err u1004))
(define-constant ERR-UPDATE-CLAIMED-FAILED (err u1005))
(define-constant ERR-PAUSED (err u1006))
(define-data-var paused bool true)
(define-map claim principal {
  claimed: bool,
  amt-token-wbtc: uint,
  amt-age000-governance-token: uint,
  amt-token-abtc: uint,
  amt-token-wgus: uint,
  amt-token-wplay: uint,
  amt-token-wlqstx: uint,
  amt-token-susdt: uint,
  amt-token-wvibes: uint,
  amt-token-slunr: uint,
  amt-token-wdiko: uint,
  amt-token-wpepe: uint,
  amt-token-wleo: uint,
  amt-token-wlong: uint,
  amt-token-wmick: uint,
  amt-token-wnope: uint,
  amt-token-waewbtc: uint,
  amt-token-wmax: uint,
  amt-token-wmega-v2: uint,
  amt-token-waeusdc: uint,
  amt-token-wfast: uint,
  amt-token-wfrodo: uint,
  amt-token-wwif: uint,
  amt-stx20-stxs: uint,
  amt-token-ssl-PomBoo-VPNTA: uint,
  amt-token-ssl-mooneeb-JGGPQS: uint,
  amt-token-ssl-wsbtc-08JSD: uint,
  amt-token-ssl-all-AESDE: uint,
  amt-token-ssl-nakamoto-08JSD: uint,
  amt-token-ssl-parker-QW155: uint,
  amt-token-ssl-memegoatstx-E0G14: uint,
  amt-token-ssl-stacks-rock-F6KBQ: uint,
  amt-token-ssl-pikachu-W1K62: uint,
  amt-token-ssl-hashiko-16Z1P: uint,
  amt-token-ssl-Runestone-7JYRJ: uint,
})
(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))
(define-read-only (get-paused)
  (var-get paused))
(define-read-only (get-claim-or-default (recipient principal))
  (default-to
{
  claimed: false,
  amt-token-wbtc: u0,
  amt-age000-governance-token: u0,
  amt-token-abtc: u0,
  amt-token-wgus: u0,
  amt-token-wplay: u0,
  amt-token-wlqstx: u0,
  amt-token-susdt: u0,
  amt-token-wvibes: u0,
  amt-token-slunr: u0,
  amt-token-wdiko: u0,
  amt-token-wpepe: u0,
  amt-token-wleo: u0,
  amt-token-wlong: u0,
  amt-token-wmick: u0,
  amt-token-wnope: u0,
  amt-token-waewbtc: u0,
  amt-token-wmax: u0,
  amt-token-wmega-v2: u0,
  amt-token-waeusdc: u0,
  amt-token-wfast: u0,
  amt-token-wfrodo: u0,
  amt-token-wwif: u0,
  amt-stx20-stxs: u0,
  amt-token-ssl-PomBoo-VPNTA: u0,
  amt-token-ssl-mooneeb-JGGPQS: u0,
  amt-token-ssl-wsbtc-08JSD: u0,
  amt-token-ssl-all-AESDE: u0,
  amt-token-ssl-nakamoto-08JSD: u0,
  amt-token-ssl-parker-QW155: u0,
  amt-token-ssl-memegoatstx-E0G14: u0,
  amt-token-ssl-stacks-rock-F6KBQ: u0,
  amt-token-ssl-pikachu-W1K62: u0,
  amt-token-ssl-hashiko-16Z1P: u0,
  amt-token-ssl-Runestone-7JYRJ: u0,
}
  (map-get? claim recipient)))
(define-public (pause (new-paused bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set paused new-paused))))
(define-public (set-claim-many (recipients (list 200 { recipient: principal, details:
{
  claimed: bool,
  amt-token-wbtc: uint,
  amt-age000-governance-token: uint,
  amt-token-abtc: uint,
  amt-token-wgus: uint,
  amt-token-wplay: uint,
  amt-token-wlqstx: uint,
  amt-token-susdt: uint,
  amt-token-wvibes: uint,
  amt-token-slunr: uint,
  amt-token-wdiko: uint,
  amt-token-wpepe: uint,
  amt-token-wleo: uint,
  amt-token-wlong: uint,
  amt-token-wmick: uint,
  amt-token-wnope: uint,
  amt-token-waewbtc: uint,
  amt-token-wmax: uint,
  amt-token-wmega-v2: uint,
  amt-token-waeusdc: uint,
  amt-token-wfast: uint,
  amt-token-wfrodo: uint,
  amt-token-wwif: uint,
  amt-stx20-stxs: uint,
  amt-token-ssl-PomBoo-VPNTA: uint,
  amt-token-ssl-mooneeb-JGGPQS: uint,
  amt-token-ssl-wsbtc-08JSD: uint,
  amt-token-ssl-all-AESDE: uint,
  amt-token-ssl-nakamoto-08JSD: uint,
  amt-token-ssl-parker-QW155: uint,
  amt-token-ssl-memegoatstx-E0G14: uint,
  amt-token-ssl-stacks-rock-F6KBQ: uint,
  amt-token-ssl-pikachu-W1K62: uint,
  amt-token-ssl-hashiko-16Z1P: uint,
  amt-token-ssl-Runestone-7JYRJ: uint,
}
})))
  (begin
    (try! (is-dao-or-extension))
    (ok (map set-claim recipients))))
(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao set-extensions
      (list
        {extension: .claim-recovered, enabled: true}
      )      
    ))
    (ok true)
  )
)
(define-public (get-tokens (extension <extension-trait>))
  (begin
    (asserts! (not (get-paused)) ERR-PAUSED)
    (asserts! (is-eq (contract-of extension) (as-contract tx-sender)) ERR-EXTENSION-NOT-AUTHORIZED)
    (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.executor-dao request-extension-callback extension 0x)))
(define-public (callback (sender principal) (memo (buff 34)))
  (let (
      (details (get-claim-or-default sender))
      (updated-details (merge details { claimed: true })))
  (asserts! (not (get claimed details)) ERR-ALREADY-CLAIMED)
    (and (> (get amt-token-wbtc details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc transfer-fixed (get amt-token-wbtc details) tx-sender sender none)))
    (and (> (get amt-age000-governance-token details) u0) (try! (contract-call? .token-alex transfer-fixed (get amt-age000-governance-token details) tx-sender sender none)))
    (and (> (get amt-token-abtc details) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (get amt-token-abtc details) tx-sender sender none)))
    (and (> (get amt-token-wgus details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wgus transfer-fixed (get amt-token-wgus details) tx-sender sender none)))
    (and (> (get amt-token-wplay details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wplay transfer-fixed (get amt-token-wplay details) tx-sender sender none)))
    (and (> (get amt-token-wlqstx details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wlqstx transfer-fixed (get amt-token-wlqstx details) tx-sender sender none)))
    (and (> (get amt-token-susdt details) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed (get amt-token-susdt details) tx-sender sender none)))
    (and (> (get amt-token-wvibes details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvibes transfer-fixed (get amt-token-wvibes details) tx-sender sender none)))
    (and (> (get amt-token-slunr details) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-slunr transfer-fixed (get amt-token-slunr details) tx-sender sender none)))
    (and (> (get amt-token-wdiko details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko transfer-fixed (get amt-token-wdiko details) tx-sender sender none)))
    (and (> (get amt-token-wpepe details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wpepe transfer-fixed (get amt-token-wpepe details) tx-sender sender none)))
    (and (> (get amt-token-wleo details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wleo transfer-fixed (get amt-token-wleo details) tx-sender sender none)))
    (and (> (get amt-token-wlong details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wlong transfer-fixed (get amt-token-wlong details) tx-sender sender none)))
    (and (> (get amt-token-wmick details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmick transfer-fixed (get amt-token-wmick details) tx-sender sender none)))
    (and (> (get amt-token-wnope details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnope transfer-fixed (get amt-token-wnope details) tx-sender sender none)))
    (and (> (get amt-token-waewbtc details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waewbtc transfer-fixed (get amt-token-waewbtc details) tx-sender sender none)))
    (and (> (get amt-token-wmax details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmax transfer-fixed (get amt-token-wmax details) tx-sender sender none)))
    (and (> (get amt-token-wmega-v2 details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmega-v2 transfer-fixed (get amt-token-wmega-v2 details) tx-sender sender none)))
    (and (> (get amt-token-waeusdc details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-waeusdc transfer-fixed (get amt-token-waeusdc details) tx-sender sender none)))
    (and (> (get amt-token-wfast details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wfast transfer-fixed (get amt-token-wfast details) tx-sender sender none)))
    (and (> (get amt-token-wfrodo details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wfrodo transfer-fixed (get amt-token-wfrodo details) tx-sender sender none)))
    (and (> (get amt-token-wwif details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wwif transfer-fixed (get amt-token-wwif details) tx-sender sender none)))
    (and (> (get amt-stx20-stxs details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.stx20-stxs transfer-fixed (get amt-stx20-stxs details) tx-sender sender none)))
    (and (> (get amt-token-ssl-PomBoo-VPNTA details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-PomBoo-VPNTA transfer-fixed (get amt-token-ssl-PomBoo-VPNTA details) tx-sender sender none)))
    (and (> (get amt-token-ssl-mooneeb-JGGPQS details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-mooneeb-JGGPQS transfer-fixed (get amt-token-ssl-mooneeb-JGGPQS details) tx-sender sender none)))
    (and (> (get amt-token-ssl-wsbtc-08JSD details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-wsbtc-08JSD transfer-fixed (get amt-token-ssl-wsbtc-08JSD details) tx-sender sender none)))
    (and (> (get amt-token-ssl-all-AESDE details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-all-AESDE transfer-fixed (get amt-token-ssl-all-AESDE details) tx-sender sender none)))
    (and (> (get amt-token-ssl-nakamoto-08JSD details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-nakamoto-08JSD transfer-fixed (get amt-token-ssl-nakamoto-08JSD details) tx-sender sender none)))
    (and (> (get amt-token-ssl-parker-QW155 details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-parker-QW155 transfer-fixed (get amt-token-ssl-parker-QW155 details) tx-sender sender none)))
    (and (> (get amt-token-ssl-memegoatstx-E0G14 details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-memegoatstx-E0G14 transfer-fixed (get amt-token-ssl-memegoatstx-E0G14 details) tx-sender sender none)))
    (and (> (get amt-token-ssl-stacks-rock-F6KBQ details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-stacks-rock-F6KBQ transfer-fixed (get amt-token-ssl-stacks-rock-F6KBQ details) tx-sender sender none)))
    (and (> (get amt-token-ssl-pikachu-W1K62 details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-pikachu-W1K62 transfer-fixed (get amt-token-ssl-pikachu-W1K62 details) tx-sender sender none)))
    (and (> (get amt-token-ssl-hashiko-16Z1P details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-hashiko-16Z1P transfer-fixed (get amt-token-ssl-hashiko-16Z1P details) tx-sender sender none)))
    (and (> (get amt-token-ssl-Runestone-7JYRJ details) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssl-Runestone-7JYRJ transfer-fixed (get amt-token-ssl-Runestone-7JYRJ details) tx-sender sender none)))
  (asserts! (map-set claim sender updated-details) ERR-UPDATE-CLAIMED-FAILED)
  (print { object: "claim-recovered", action: "claim", sender: sender, details: updated-details })
  (ok true)))
(define-private (set-claim (recipient { recipient: principal, details:
{
  claimed: bool,
  amt-token-wbtc: uint,
  amt-age000-governance-token: uint,
  amt-token-abtc: uint,
  amt-token-wgus: uint,
  amt-token-wplay: uint,
  amt-token-wlqstx: uint,
  amt-token-susdt: uint,
  amt-token-wvibes: uint,
  amt-token-slunr: uint,
  amt-token-wdiko: uint,
  amt-token-wpepe: uint,
  amt-token-wleo: uint,
  amt-token-wlong: uint,
  amt-token-wmick: uint,
  amt-token-wnope: uint,
  amt-token-waewbtc: uint,
  amt-token-wmax: uint,
  amt-token-wmega-v2: uint,
  amt-token-waeusdc: uint,
  amt-token-wfast: uint,
  amt-token-wfrodo: uint,
  amt-token-wwif: uint,
  amt-stx20-stxs: uint,
  amt-token-ssl-PomBoo-VPNTA: uint,
  amt-token-ssl-mooneeb-JGGPQS: uint,
  amt-token-ssl-wsbtc-08JSD: uint,
  amt-token-ssl-all-AESDE: uint,
  amt-token-ssl-nakamoto-08JSD: uint,
  amt-token-ssl-parker-QW155: uint,
  amt-token-ssl-memegoatstx-E0G14: uint,
  amt-token-ssl-stacks-rock-F6KBQ: uint,
  amt-token-ssl-pikachu-W1K62: uint,
  amt-token-ssl-hashiko-16Z1P: uint,
  amt-token-ssl-Runestone-7JYRJ: uint,
}}))
  (ok (map-set claim (get recipient recipient) (get details recipient))))
```
