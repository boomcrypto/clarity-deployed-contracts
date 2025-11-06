;; This contract use the SIP-010 community-standard Fungible Token trait
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) ;;

(define-trait commission-ft
    ((pay (uint uint <sip-010-trait>) (response bool uint))))