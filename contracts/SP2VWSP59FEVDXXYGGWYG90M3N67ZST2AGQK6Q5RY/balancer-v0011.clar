(define-public (balancer (dd uint) (mr uint) (ta uint))
    (begin
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v93-8 balancer dd mr ta))
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v17-1 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v11-4 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v19-9 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v35-5 balancer dd mr ta)) 
        (ok u11)
    )
)