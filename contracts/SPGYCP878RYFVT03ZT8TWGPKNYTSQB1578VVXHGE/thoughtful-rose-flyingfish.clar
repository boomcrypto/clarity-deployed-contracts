;; Simple Dungeon Explorer Contract
;; This contract calls the explore function of the Dungeon Crawler contract with fixed inputs

(define-public (explore-dungeon)
  (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dungeon-crawler-rc4 explore
    (some 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.meme-engine-cha-rc3) (some "TAP")
    (some 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.meme-engine-iouwelsh-rc1) (some "TAP")
    (some 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.meme-engine-iouroo-rc1) (some "TAP")
    (some 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.hot-potato-rc1) (some "PASS")
    none none
    none none
    none none
    none none
  )
)