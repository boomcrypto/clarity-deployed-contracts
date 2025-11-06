;; https://explorer.hiro.so/txid/SPFAQ8JFM2GPQDJR1PARSMDSV4D46PSFPN1S53YJ.util-sbtc-wstx?chain=mainnet
;; https://explorer.hiro.so/txid/SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-farming-core-v1_1_1-0070?chain=mainnet

(define-read-only
    (get-user-balance (user principal))
    (contract-call?
        'SPFAQ8JFM2GPQDJR1PARSMDSV4D46PSFPN1S53YJ.util-sbtc-wstx
        get-user-sBTC-balance
        user
        (get end
            (contract-call?
                'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-farming-core-v1_1_1-0070
                get-user-staked
                user
            )
        )
    )
)

(define-public
    (retrieve-user-balance (user principal))
    (ok 
        (contract-call?
            'SPFAQ8JFM2GPQDJR1PARSMDSV4D46PSFPN1S53YJ.util-sbtc-wstx
            get-user-sBTC-balance
            user
            (get end
                (contract-call?
                    'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-farming-core-v1_1_1-0070
                    get-user-staked
                    user
                )
            )
        )
    )
)
