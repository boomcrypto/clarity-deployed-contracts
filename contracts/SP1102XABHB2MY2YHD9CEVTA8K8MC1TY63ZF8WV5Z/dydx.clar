(use-trait fees-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)

(define-public 
  (get-y-for-x
   (r0        uint)
   (r1        uint)
   (fees            <fees-trait>)
   (amt-in          uint)
)
  (let (
        (res              (try! (contract-call? fees calc-fees amt-in)))
        (amt-in-adjusted  (get amt-in-adjusted  res))
        (amt-out (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx r1 r0 amt-in-adjusted) )
    )

     amt-out
    ))


(define-public 
  (get-x-for-y
   (r0        uint)
   (r1        uint)
   (fees            <fees-trait>)
   (amt-in          uint)
)
  (let (
        (res              (try! (contract-call? fees calc-fees amt-in)))
        (amt-in-adjusted  (get amt-in-adjusted  res))
        (amt-out (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx r0 r1 amt-in-adjusted))
    )

     amt-out
    ))
