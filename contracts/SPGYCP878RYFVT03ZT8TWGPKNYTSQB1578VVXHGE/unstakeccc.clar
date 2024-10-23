;; Liquid Staked Welsh
(define-public (process-liquid-staked-welsh)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh get-balance tx-sender) (err u1))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh unstake balance))
    (ok true)))

;; Liquid Staked Rock
(define-public (process-liquid-staked-rock)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-rock get-balance tx-sender) (err u2))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-rock unstake balance))
    (ok true)))

;; Liquid Staked Roo
(define-public (process-liquid-staked-roo)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-roo get-balance tx-sender) (err u3))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-roo unstake balance))
    (ok true)))

;; Liquid Staked Wif
(define-public (process-liquid-staked-wif)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-wif get-balance tx-sender) (err u4))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-wif unstake balance))
    (ok true)))

;; Liquid Staked Play
(define-public (process-liquid-staked-play)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-play get-balance tx-sender) (err u5))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-play unstake balance))
    (ok true)))

;; Liquid Staked Pepe
(define-public (process-liquid-staked-pepe)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-pepe get-balance tx-sender) (err u6))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-pepe unstake balance))
    (ok true)))

;; Liquid Staked Not
(define-public (process-liquid-staked-not)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-not get-balance tx-sender) (err u7))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-not unstake balance))
    (ok true)))

;; Liquid Staked Max
(define-public (process-liquid-staked-max)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-max get-balance tx-sender) (err u8))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-max unstake balance))
    (ok true)))

;; Liquid Staked Long
(define-public (process-liquid-staked-long)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-long get-balance tx-sender) (err u9))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-long unstake balance))
    (ok true)))

;; Liquid Staked Gus
(define-public (process-liquid-staked-gus)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-gus get-balance tx-sender) (err u10))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-gus unstake balance))
    (ok true)))

;; Liquid Staked Babywelsh
(define-public (process-liquid-staked-babywelsh)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-babywelsh get-balance tx-sender) (err u11))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-babywelsh unstake balance))
    (ok true)))

;; Liquid Staked Leo
(define-public (process-liquid-staked-leo)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-leo get-balance tx-sender) (err u12))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-leo unstake balance))
    (ok true)))

;; Liquid Staked Welsh V2
(define-public (process-liquid-staked-welsh-v2)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 get-balance tx-sender) (err u13))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-welsh-v2 unstake balance))
    (ok true)))

;; Liquid Staked Odin
(define-public (process-liquid-staked-odin)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-odin get-balance tx-sender) (err u14))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-odin unstake balance))
    (ok true)))

;; Liquid Staked Goat
(define-public (process-liquid-staked-goat)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-goat get-balance tx-sender) (err u15))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-goat unstake balance))
    (ok true)))

;; Liquid Staked Roo V2
(define-public (process-liquid-staked-roo-v2)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-roo-v2 get-balance tx-sender) (err u16))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-roo-v2 unstake balance))
    (ok true)))

;; Liquid Staked Boo
(define-public (process-liquid-staked-boo)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-boo get-balance tx-sender) (err u17))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-boo unstake balance))
    (ok true)))

;; Liquid Staked Hashiko
(define-public (process-liquid-staked-hashiko)
  (let ((balance (unwrap! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-hashiko get-balance tx-sender) (err u18))))
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-hashiko unstake balance))
    (ok true)))