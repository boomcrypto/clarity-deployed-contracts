;; Token Balance Checker Contract
;; kraqen.btc

(define-public (get-all-balances (address principal))
    (let
        (
            (charisma-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-balance address))
            (dmg-balance (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-balance address))
            (synthetic-welsh-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh get-balance address))
            (cha-iouwelsh-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh get-balance address))
            (welsh-iouwelsh-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.welsh-iouwelsh get-balance address))
            (synthetic-roo-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo get-balance address))
            (roo-iouroo-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.roo-iouroo get-balance address))
            (synthetic-stx-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-stx get-balance address))
            (wstx-synstx-balance (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-synstx get-balance address))
        )
        (ok {
            charisma: charisma-balance,
            dmg: dmg-balance,
            synthetic-welsh: synthetic-welsh-balance,
            cha-iouwelsh: cha-iouwelsh-balance,
            welsh-iouwelsh: welsh-iouwelsh-balance,
            synthetic-roo: synthetic-roo-balance,
            roo-iouroo: roo-iouroo-balance,
            synthetic-stx: synthetic-stx-balance,
            wstx-synstx: wstx-synstx-balance
        })
    )
)

;; Read-only function to get individual token balances
(define-read-only (get-charisma-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token get-balance address)
)

(define-read-only (get-dmg-balance (address principal))
    (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-balance address)
)

(define-read-only (get-synthetic-welsh-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-welsh get-balance address)
)

(define-read-only (get-cha-iouwelsh-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.cha-iouwelsh get-balance address)
)

(define-read-only (get-welsh-iouwelsh-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.welsh-iouwelsh get-balance address)
)

(define-read-only (get-synthetic-roo-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-roo get-balance address)
)

(define-read-only (get-roo-iouroo-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.roo-iouroo get-balance address)
)

(define-read-only (get-synthetic-stx-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.synthetic-stx get-balance address)
)

(define-read-only (get-wstx-synstx-balance (address principal))
    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.wstx-synstx get-balance address)
)