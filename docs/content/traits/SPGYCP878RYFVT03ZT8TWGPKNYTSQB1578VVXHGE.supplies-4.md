---
title: "Trait supplies-4"
draft: true
---
```
(define-read-only (get-group1)
  (ok
    (tuple
      (chdollar
        (unwrap-panic (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.chdollar
                                      get-total-supply)))
      (anonymous-welsh-cvlt
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.anonymous-welsh-cvlt
                                      get-total-supply)))
      (stx-hoot-lp-token
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.stx-hoot-lp-token
                                      get-total-supply)))
      (satoshis-private-key
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.satoshis-private-key
                                      get-total-supply)))
      (stdollar
        (unwrap-panic (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.stdollar
                                      get-total-supply)))
    )
  )
)

(define-read-only (get-group2)
  (ok
    (tuple
      (charismatic-corgi-liquidity
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charismatic-corgi-liquidity
                                      get-total-supply)))
      (mecha-meme
        (unwrap-panic (contract-call? 'SP3T1M18J3VX038KSYPP5G450WVWWG9F9G6GAZA4Q.mecha-meme
                                      get-total-supply)))
      (dungeon-master-liquidity
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dungeon-master-liquidity
                                      get-total-supply)))
      (welsh-community-lp
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.welsh-community-lp
                                      get-total-supply)))
      (upgraded-shark
        (unwrap-panic (contract-call? 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.upgraded-shark
                                      get-total-supply)))
    )
  )
)

(define-read-only (get-group3)
  (ok
    (tuple
      (iron-ingots-lp
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.iron-ingots-lp
                                      get-total-supply)))
      (stone-mask
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.stone-mask
                                      get-total-supply)))
      (sexy-pepe
        (unwrap-panic (contract-call? 'SP15WAVKQNT241YVCGQMJS777E17H9TS96M21Q5DX.sexy-pepe
                                      get-total-supply)))
      (stxshark
        (unwrap-panic (contract-call? 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS.stxshark
                                      get-total-supply)))
      (charismatic-flow
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charismatic-flow
                                      get-total-supply)))
    )
  )
)

(define-read-only (get-group4)
  (ok
    (tuple
      (dexterity-pool-v1
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dexterity-pool-v1
                                      get-total-supply)))
      (we-are-legion
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.we-are-legion
                                      get-total-supply)))
      (owlbear-form
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.owlbear-form
                                      get-total-supply)))
      (dmghoot-lp-token
        (unwrap-panic (contract-call? 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS.dmghoot-lp-token
                                      get-total-supply)))
      (leo-unchained-lp
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.leo-unchained-lp
                                      get-total-supply)))
    )
  )
)

(define-read-only (get-group5)
  (ok
    (tuple
      (pirate-ship-lp
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.pirate-ship-lp
                                      get-total-supply)))
      (anime-demon-girl
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.anime-demon-girl
                                      get-total-supply)))
      (president-pepe-lp
        (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.president-pepe-lp
                                      get-total-supply)))
    )
  )
)

(define-public (get-all-groups)
  (ok
    (tuple
      (group1 (as-contract (get-group1))) 
      (group2 (as-contract (get-group2)))
      (group3 (as-contract (get-group3)))
      (group4 (as-contract (get-group4)))
      (group5 (as-contract (get-group5)))
    )
  )
)
```
