;; constants
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant CONTRACT-OWNER tx-sender)

;;(define-data-var holders (string-ascii 256) "hi")


;;;;;;;;;;;;;;

(define-read-only (get-vault-by-id (vault-id uint))
  (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vault-data-v1-1 get-vault-by-id vault-id)
)


(define-read-only (get-debt-for-vault (vault-id uint))
  (let ((vault (get-vault-by-id vault-id))) (ok (get debt vault)))
)

(print (get-vault-by-id u666))
(print (get-vault-by-id u667))
(print (get-vault-by-id u668))
(print (get-vault-by-id u669))
(print (get-vault-by-id u670))
(print (get-vault-by-id u671))
(print (get-vault-by-id u672))
(print (get-vault-by-id u673))
(print (get-vault-by-id u674))
(print (get-vault-by-id u675))
(print (get-vault-by-id u676))
(print (get-vault-by-id u677))
(print (get-vault-by-id u678))
(print (get-vault-by-id u679))
(print (get-vault-by-id u680))
(print (get-vault-by-id u681))
(print (get-vault-by-id u682))
(print (get-vault-by-id u683))
(print (get-vault-by-id u684))
(print (get-vault-by-id u685))
(print (get-vault-by-id u686))
(print (get-vault-by-id u687))
(print (get-vault-by-id u688))
(print (get-vault-by-id u689))
(print (get-vault-by-id u690))
(print (get-vault-by-id u691))
(print (get-vault-by-id u692))
(print (get-vault-by-id u693))
(print (get-vault-by-id u694))
(print (get-vault-by-id u695))
(print (get-vault-by-id u696))
(print (get-vault-by-id u697))
(print (get-vault-by-id u698))
(print (get-vault-by-id u699))
(print (get-vault-by-id u700))
(print (get-vault-by-id u701))
(print (get-vault-by-id u702))
(print (get-vault-by-id u703))
(print (get-vault-by-id u704))
(print (get-vault-by-id u705))
(print (get-vault-by-id u706))
(print (get-vault-by-id u707))
(print (get-vault-by-id u708))
(print (get-vault-by-id u709))
(print (get-vault-by-id u710))
(print (get-vault-by-id u711))
(print (get-vault-by-id u712))
(print (get-vault-by-id u713))
(print (get-vault-by-id u714))
(print (get-vault-by-id u715))
(print (get-vault-by-id u716))
(print (get-vault-by-id u717))
(print (get-vault-by-id u718))
(print (get-vault-by-id u719))
(print (get-vault-by-id u720))
(print (get-vault-by-id u721))
(print (get-vault-by-id u722))
(print (get-vault-by-id u723))
(print (get-vault-by-id u724))
(print (get-vault-by-id u725))
(print (get-vault-by-id u726))
(print (get-vault-by-id u727))
(print (get-vault-by-id u728))
(print (get-vault-by-id u729))
(print (get-vault-by-id u730))
(print (get-vault-by-id u731))
(print (get-vault-by-id u732))
(print (get-vault-by-id u733))
(print (get-vault-by-id u734))
(print (get-vault-by-id u735))
(print (get-vault-by-id u736))
(print (get-vault-by-id u737))
(print (get-vault-by-id u738))
(print (get-vault-by-id u739))
(print (get-vault-by-id u740))
(print (get-vault-by-id u741))
(print (get-vault-by-id u742))
(print (get-vault-by-id u743))
(print (get-vault-by-id u744))
(print (get-vault-by-id u745))
(print (get-vault-by-id u746))
(print (get-vault-by-id u747))
(print (get-vault-by-id u748))
(print (get-vault-by-id u749))
(print (get-vault-by-id u750))
(print (get-vault-by-id u751))
(print (get-vault-by-id u752))
(print (get-vault-by-id u753))
(print (get-vault-by-id u754))
(print (get-vault-by-id u755))
(print (get-vault-by-id u756))
(print (get-vault-by-id u757))
(print (get-vault-by-id u758))
(print (get-vault-by-id u759))
(print (get-vault-by-id u760))