
(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
  (begin
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.inc-aqua-crawdad set-extensions
      (list
        { extension: 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite, enabled: true }
        { extension: 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.fixed-emerald-penguin, enabled: true }
      )
    ))

    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.fixed-emerald-penguin set-approver 'SP2XZYH55AY5XZVZYJMPDP3YHMKM2QAZH1W5N56W4 true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.fixed-emerald-penguin set-approver 'SP1Y6ZZA5E5YQP7C5E4BHX7BS2DNHKQ19QVEA91YJ true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.fixed-emerald-penguin set-approver 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E true))

    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.fixed-emerald-penguin set-signals-required u2))
    
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 true))  
    (try! (contract-call? 'SP248NZ0P20BH3M3ZTM9DS69EMC9G6H3MQC6KM3E.stable-harlequin-kite set-allowed 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 true))

    (print { message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender })
    (ok true)
  )
)
