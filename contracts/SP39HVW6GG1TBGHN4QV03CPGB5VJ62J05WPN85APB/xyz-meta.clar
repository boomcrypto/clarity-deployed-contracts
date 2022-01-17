;;Getting URIs of tokens by token-id
(define-map uri uint (string-ascii 209))
;; Set two orders.
(map-set uri u1 "bafyreigkbni2wd2f3k52xwwmx3ld25weechvfr4lhlhswwszwyg36ficle")
(map-set uri u2 "bafyreicrzdoddrfdqhcyew33yzxvnicfyhkj4jqr22el4q43jjubswcfza")
(map-set uri u3 "bafyreihyu3k6r5uizywgtqr5qb2ggfbkce3yvl4ufiyw5dx6knszkdz4lu")
(map-set uri u4 "bafyreif6nhqiaeyzlsmgqeok2h2df76cao2xkgu3zfjeiwprnq4gkoqvle")
(map-set uri u5 "bafyreihqngcn74l7qwcfubc5uy4reudju4k7435ik2lbcutowo55m7r45e")
(map-set uri u6 "bafyreiep3ofeps6fs2jah4gix6b5d4unlbqpaxwnxjvfgdixkantyomn6a")
(map-set uri u7 "bafyreifwtv4bradoeuu26nshhmt7ronfwbtfvd3z2olpt4nrtiviic6izq")
(map-set uri u8 "bafyreiafdjeunhgs46ngm5zi3hivm2qhvwlgfepvo4kwq3l7tt3q2dhhhy")
(map-set uri u9 "bafyreigl752lv7mvbxvlzwm6teqeeakvwmjfvasvysmwh7vhc5rdu3ls4m")
(map-set uri u10 "bafyreigqlef3z7iarzqzkx3kxdjapnupgrqhuakmgl364ddoygtxtjcsba")
;; retrieve order with ID u1.
(define-read-only (get-map (token-id uint))
    (ok (concat (concat "https://cloudflare-ipfs.com/ipfs/" (unwrap-panic (map-get? uri token-id))) "/metadata.json")))