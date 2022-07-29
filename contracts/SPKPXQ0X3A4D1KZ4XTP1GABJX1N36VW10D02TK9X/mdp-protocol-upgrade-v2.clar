;;     _____________  _______ _________  ___  ___  ____  ____
;;     / __/_  __/ _ |/ ___/ //_/ __/ _ \/ _ \/ _ |/ __ \/ __/
;;     _\ \  / / / __ / /__/ ,< / _// , _/ // / __ / /_/ /\ \  
;;    /___/ /_/ /_/ |_\___/_/|_/___/_/|_/____/_/ |_\____/___/  
;;                                                          
;;     ___  ___  ____  ___  ____  _______   __               
;;    / _ \/ _ \/ __ \/ _ \/ __ \/ __/ _ | / /               
;;   / ___/ , _/ /_/ / ___/ /_/ /\ \/ __ |/ /__              
;;  /_/  /_/|_|\____/_/   \____/___/_/ |_/____/              

;; Upgrade MegaDAO protocol

(impl-trait 'SPX9XMC02T56N9PRXV4AM9TS88MMQ6A1Z3375MHD.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
    (begin
        ;; Enable extensions.
        (try! (contract-call? 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-dao set-extensions
            (list
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-submission, enabled: false}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-voting, enabled: false}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-proposal-submission-v2, enabled: true}
                {extension: 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X.mega-proposal-voting-v2, enabled: true}
            )
        ))

        (print {message: "...to be a completely separate network and separate block chain, yet share CPU power with Bitcoin.", sender: sender})
        (ok true)
    )
)