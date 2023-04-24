(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait lookup-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.lookup-trait.lookup-trait)

(define-public (unstake-all (collections (list 1000 <nft-trait>)) (tables (list 1000 <lookup-trait>)) (ids (list 1000 uint)))
 (ok (map unstake collections tables ids)))

(define-private (unstake (collection <nft-trait>) (table <lookup-trait>) (id uint)) 
    (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.staking-helper unstake collection table id))

(define-read-only (get-all-staked-nfts (addresses (list 10 principal)) (collections (list 10 principal))) 
    (map get-staked-nfts addresses collections))
    
(define-private (get-staked-nfts (address principal) (collection principal))
    (contract-call? 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.spaghettipunk-staking get-staked-nfts address collection))