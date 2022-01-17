;; Crypto Graffiti
;; Artist: BennyCage.btc

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define a new NFT
(define-non-fungible-token crypto-graffiti uint)

;; Define the errors
(define-constant err-invalid-token u200)
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-commission u400)
(define-constant err-invalid-user u500)
(define-constant err-nft-claimed u600)

;; Define commission address
(define-constant commission-address tx-sender)

;; Define artist address
(define-data-var artist-address principal 'SP1B6FGZWBJK2WJHJP76C2E4AW3HA4BVAR5DGK074)

;; Define the NFT's in the contract
(define-map nft-data uint {
  metadata: (string-ascii 55),
  price: uint,
  claimed: bool
})

(define-constant total-nfts u186)

;; Set map metadata, price, and claimed

(map-set nft-data u1 {
  metadata: "ipfs://QmP9FPzznGtqYYPVmiTwN6pRcvBNEQAKXV13tvobh3Z3Bc",
  price: u25000000,
  claimed: false
})


(map-set nft-data u2 {
  metadata: "ipfs://Qmaj2UXwQ8589QU17YvjwU29m2dz5YM4aSUSVWvgKik7Cw",
  price: u25000000,
  claimed: false
})


(map-set nft-data u3 {
  metadata: "ipfs://QmUvkKAXSQ4seMUFAmbRJQbejp3F5FTGUVy49tKdncS48x",
  price: u25000000,
  claimed: false
})


(map-set nft-data u4 {
  metadata: "ipfs://QmQC4giVACguoQ5TJAM8QkrVPczttY3MKhM3cqvGbKAcVN",
  price: u25000000,
  claimed: false
})


(map-set nft-data u5 {
  metadata: "ipfs://QmQTXj6Y79YywXfpcxUs5X3e2ey4Xm4vJ8ApU9EApVSbsH",
  price: u25000000,
  claimed: false
})

(map-set nft-data u6 {
  metadata: "ipfs://QmTnCUGu8mWnPHpFb6CWwUva5igp6Cozruh7RGJMM8Q1HW",
  price: u25000000,
  claimed: false
})


(map-set nft-data u7 {
  metadata: "ipfs://QmSdi5cZcWJW21YFBVxdcHaH8xBUHZV73nsziMs1Annixi",
  price: u25000000,
  claimed: false
})


(map-set nft-data u8 {
  metadata: "ipfs://QmfYieBGvArBUYuxR422zSVyKBhuoikJCsceUwD9x2dikG",
  price: u25000000,
  claimed: false
})


(map-set nft-data u9 {
  metadata: "ipfs://QmS9EFycSEEQHWnazzjKTQgrhb5rvuUWytUyWcRA8CjQpY",
  price: u25000000,
  claimed: false
})


(map-set nft-data u10 {
  metadata: "ipfs://QmQt1waYj15ywn7uiZ2Xsevb8bG5qRmbDvDYwhrPSAyEsG",
  price: u25000000,
  claimed: false
})


(map-set nft-data u11 {
  metadata: "ipfs://QmYccNv2noXekHorM65Layc8N1dXk7JJWnXb2ac9iqGknn",
  price: u25000000,
  claimed: false
})


(map-set nft-data u12 {
  metadata: "ipfs://QmdjDG8ATnfVnPi7fKLCUJj7R3UURRcZQ9BjdpnFmcE5ni",
  price: u25000000,
  claimed: false
})


(map-set nft-data u13 {
  metadata: "ipfs://QmVAfk242HHo8SynzzDcimfzVy8GiCnxrt1Rwa2YzpL47g",
  price: u25000000,
  claimed: false
})


(map-set nft-data u14 {
  metadata: "ipfs://Qmf69vvwCUetDPB1KiPmdSKYHtXWbgTKkirfdDMjcTYxY5",
  price: u25000000,
  claimed: false
})


(map-set nft-data u15 {
  metadata: "ipfs://QmWB3FmQGXsbatjykhk3m5ExqXSh5jhprEzAe9edTpaKGx",
  price: u25000000,
  claimed: false
})


(map-set nft-data u16 {
  metadata: "ipfs://QmY5qNVVGTveQm7DjDHHVnP68Ht4zAzHKGQThdBvrooVkx",
  price: u25000000,
  claimed: false
})


(map-set nft-data u17 {
  metadata: "ipfs://Qmf6t2Hmj8Z5rWBYXayGTikp2VazsrULvo1zt2qV33ZzQd",
  price: u25000000,
  claimed: false
})


(map-set nft-data u18 {
  metadata: "ipfs://QmRwuMsDwWP8ywb7gMSTSwdDJzPWJ1UhqLPwDzTidnqkmL",
  price: u25000000,
  claimed: false
})


(map-set nft-data u19 {
  metadata: "ipfs://QmWs3y7TbH74hsWT9y92YvNJTCi7ntvnZ4VcHi9jy3TEbc",
  price: u25000000,
  claimed: false
})


(map-set nft-data u20 {
  metadata: "ipfs://QmRfkvS3SkeYgRy6K3euCUbCaL1rR6D2pgkjyN89n3jDNX",
  price: u25000000,
  claimed: false
})


(map-set nft-data u21 {
  metadata: "ipfs://QmYfpDpjtjL6RWezZtFKhhfDDpHGcuvwDH3vWwqNdiRYwe",
  price: u25000000,
  claimed: false
})


(map-set nft-data u22 {
  metadata: "ipfs://QmRnKLNRQz121aR7sZarGCbiC6hqLTPd8pnoX47j4Daz2q",
  price: u25000000,
  claimed: false
})


(map-set nft-data u23 {
  metadata: "ipfs://QmT6dEoSVxE6GhDZLhDXYpm7GXnd45hDph2upBMgBnNoxC",
  price: u50000000,
  claimed: false
})


(map-set nft-data u24 {
  metadata: "ipfs://QmR1mHffPRSAR7buGVZKpE2TPEPCBB29ccRsVYZecJrEsi",
  price: u50000000,
  claimed: false
})


(map-set nft-data u25 {
  metadata: "ipfs://QmZELTeJMxaowYg3rGE7SxMqBUzdJQZf4jxN9J36SBxrN8",
  price: u50000000,
  claimed: false
})


(map-set nft-data u26 {
  metadata: "ipfs://QmeZFmENtVZfU38CLkuKXkWPHPU3L4QLB6LtK5bP6qemVz",
  price: u50000000,
  claimed: false
})


(map-set nft-data u27 {
  metadata: "ipfs://QmVzcaroPwUPFpHLwVnh1SLwGfSgQGi9Ve2bWyEBHDbBst",
  price: u50000000,
  claimed: false
})


(map-set nft-data u28 {
  metadata: "ipfs://QmVSY4xLrEJjVVdDz9n8bwM5rm1TBW6CHWcrVE3VPs7y8Q",
  price: u50000000,
  claimed: false
})


(map-set nft-data u29 {
  metadata: "ipfs://QmYuays9qkpr2LLvkGi8gbjSDdi66Xdf3DQZNpjzPD7QQa",
  price: u50000000,
  claimed: false
})


(map-set nft-data u30 {
  metadata: "ipfs://QmcJcZFdQu16LAzYeCqjAGXdAzpVj7eZ85M3QiocZApXEv",
  price: u50000000,
  claimed: false
})


(map-set nft-data u31 {
  metadata: "ipfs://QmPNEMxamrAGeQSwowNwMxtY2TWgnfBvyaW3GQ81g4Yq5z",
  price: u50000000,
  claimed: false
})


(map-set nft-data u32 {
  metadata: "ipfs://QmdLc8Gyam4XTfoCHRXfTgWB8Uau2y9MoyKFLZ18FmP5yt",
  price: u50000000,
  claimed: false
})


(map-set nft-data u33 {
  metadata: "ipfs://QmUgfZD6Yk9VCP992psRGcBsrG8nLD3RE9XFLiJthGgWGJ",
  price: u50000000,
  claimed: false
})


(map-set nft-data u34 {
  metadata: "ipfs://Qmebz6VCyeyF37ze3hB4E8qEDEUtuq8nwCbCKPARDtdnJS",
  price: u50000000,
  claimed: false
})


(map-set nft-data u35 {
  metadata: "ipfs://QmP3RfAGNST8b8XkxkwPswidHGWebAmMyRqXBqeAmy9PsJ",
  price: u50000000,
  claimed: false
})


(map-set nft-data u36 {
  metadata: "ipfs://QmXQ4SyJzE65pcRMhHYQEMpNJ4jsTU5ujJzBGaqW3Z4s8m",
  price: u50000000,
  claimed: false
})


(map-set nft-data u37 {
  metadata: "ipfs://Qmb8eRr7Cihd93Rf9gHiFyz7QRVXBRWvUPLfZczzc6FJ8k",
  price: u50000000,
  claimed: false
})


(map-set nft-data u38 {
  metadata: "ipfs://QmWEPLq6ZpgJ7eQWYGBzfic2r442Hk8SLTpZQL6iLYtngt",
  price: u50000000,
  claimed: false
})


(map-set nft-data u39 {
  metadata: "ipfs://QmWrCYaZGmXNnximEs3G45pdvndrNSmgfuDdP8v1N3Wosj",
  price: u50000000,
  claimed: false
})


(map-set nft-data u40 {
  metadata: "ipfs://QmVKohTDuSqg7t3FdC4KJ6rwneocNUdTouDhwpNL2QJDEi",
  price: u50000000,
  claimed: false
})


(map-set nft-data u41 {
  metadata: "ipfs://QmYmY3ymXj59qsDbQ8UBKdRMTb8ZsyFwtLBo368GExXasN",
  price: u50000000,
  claimed: false
})


(map-set nft-data u42 {
  metadata: "ipfs://Qmc4amxMnGJRMqp4VjYgXtAKc59SPjUJFXcDEWsHtY4zSg",
  price: u50000000,
  claimed: false
})


(map-set nft-data u43 {
  metadata: "ipfs://QmUitzxNXU6GZs6JJCe4ecn6eop8br6QgrvuzrxiZEmD6f",
  price: u50000000,
  claimed: false
})


(map-set nft-data u44 {
  metadata: "ipfs://QmemMWnKibcMWpmBSzv2ib5uTaQDVzxdAsKc2JeJgcjAbd",
  price: u50000000,
  claimed: false
})


(map-set nft-data u45 {
  metadata: "ipfs://QmNtENHyqJFfSGPDRwbgEvyPAwN3q7cds4zSzCKAXsPqTd",
  price: u50000000,
  claimed: false
})


(map-set nft-data u46 {
  metadata: "ipfs://QmVz7KSjgYDw8T7u666KPvaGAB815ddqgA5yfFhyyZqi93",
  price: u50000000,
  claimed: false
})


(map-set nft-data u47 {
  metadata: "ipfs://QmbsyNqVquPCQCvq8x3FpdAAsTPQ7xmtTfsgTdkNJzK4B4",
  price: u50000000,
  claimed: false
})


(map-set nft-data u48 {
  metadata: "ipfs://QmRmNbEs9wprUMVmHphtESDpmJUqmeCjokhaBNYz6tx4RP",
  price: u75000000,
  claimed: false
})


(map-set nft-data u49 {
  metadata: "ipfs://QmZmFvYT3ec87F6nn3CNy33r7hmYsroTGfp4XyHBuHxbRm",
  price: u75000000,
  claimed: false
})


(map-set nft-data u50 {
  metadata: "ipfs://QmZKASXPutWYoBu3bTcGUiCL6uH8sfVfGys9dmQB6bWmDj",
  price: u75000000,
  claimed: false
})


(map-set nft-data u51 {
  metadata: "ipfs://QmZ6nSAtGGTjk5yRKwf71ynnDzYjrcyuSaqjaivFRfpko7",
  price: u75000000,
  claimed: false
})


(map-set nft-data u52 {
  metadata: "ipfs://QmUxutjz8UenZrXKG2haQ6ZkWEm4ayThKwCyfiBt73WRqh",
  price: u75000000,
  claimed: false
})


(map-set nft-data u53 {
  metadata: "ipfs://QmRJWdz3WomZvsFu6ZCvuTtAkbd2qCW2iVnEmRsqSBovZp",
  price: u75000000,
  claimed: false
})


(map-set nft-data u54 {
  metadata: "ipfs://QmVqfhqcKoNd8RtAKbiQwwjJ2ULYxqHW4jH7zXQXDMDANo",
  price: u75000000,
  claimed: false
})


(map-set nft-data u55 {
  metadata: "ipfs://QmVr6Zc64BJovBqoq3e9Z3eQXAPGUAvroGPDk9oD5YkF1N",
  price: u75000000,
  claimed: false
})


(map-set nft-data u56 {
  metadata: "ipfs://Qma8V3D8nHG9fwAgYRjev21tKwiHyr4ooCktTzyq7XJA5n",
  price: u75000000,
  claimed: false
})


(map-set nft-data u57 {
  metadata: "ipfs://QmT3neX1iBMPJKuPb6WXt97Z7T7vZdCzUe3XqspwVa6pFJ",
  price: u75000000,
  claimed: false
})


(map-set nft-data u58 {
  metadata: "ipfs://Qme4agqSdWM46HDKWpZYuZavznTZc5xGifQgonQWLMsbcz",
  price: u75000000,
  claimed: false
})


(map-set nft-data u59 {
  metadata: "ipfs://QmeZoLUYzACYpMb9PDkd1okAevkkwMNXbw9jTDCzFEW7eL",
  price: u75000000,
  claimed: false
})


(map-set nft-data u60 {
  metadata: "ipfs://QmSGT263F3jvV4xGJntcS8eRTFmjhqov3RcaKzbyYZvHu7",
  price: u75000000,
  claimed: false
})


(map-set nft-data u61 {
  metadata: "ipfs://QmWp7JebLFxd1SSvFDqXzVwgPz6PFeUza9FdWSLYr2LixV",
  price: u75000000,
  claimed: false
})


(map-set nft-data u62 {
  metadata: "ipfs://Qmd9eT4THyQ8iaMbFZccPUxjWsJVM6AnY9RXPwTMkuUouV",
  price: u75000000,
  claimed: false
})


(map-set nft-data u63 {
  metadata: "ipfs://QmVxhzQXPGBukseos3jLxi1kqWYWCsp8HmHyNBUkLHToiy",
  price: u75000000,
  claimed: false
})


(map-set nft-data u64 {
  metadata: "ipfs://QmcQucen9cw1abSqnNDgFY2baq9dKiq9Vancb1xNeJyozc",
  price: u75000000,
  claimed: false
})


(map-set nft-data u65 {
  metadata: "ipfs://QmXSytifhvNaAsLcTf7Xxg79ByGPBmpNv29KwTr44Y3HGb",
  price: u75000000,
  claimed: false
})


(map-set nft-data u66 {
  metadata: "ipfs://QmXLL32u6Fya6L697kBJWj55rcjtRMo2KrjSZVusHcDri9",
  price: u75000000,
  claimed: false
})


(map-set nft-data u67 {
  metadata: "ipfs://QmfSYrzhAck2wNUEGytSMkP1CYzmx6eaop7Jmhu6RvXGUM",
  price: u75000000,
  claimed: false
})


(map-set nft-data u68 {
  metadata: "ipfs://QmPJwxtyZVTfufMS1ABHZKv1SjXWgrAJ1L4s57cX8LNKsz",
  price: u75000000,
  claimed: false
})


(map-set nft-data u69 {
  metadata: "ipfs://QmVpCWJt3YSzts2c5j4NM1w5F5Q6tHNGGyYyy542YKpKTU",
  price: u75000000,
  claimed: false
})


(map-set nft-data u70 {
  metadata: "ipfs://QmUbKt3jrbCUfyD4k8Y7oiz1KGNyEtnFnbqVA6ehYTZthD",
  price: u75000000,
  claimed: false
})


(map-set nft-data u71 {
  metadata: "ipfs://QmYxNLyZNdc1KjEXvH3CGvzjWe8s5q5D6PFTMngVUK2BCo",
  price: u75000000,
  claimed: false
})


(map-set nft-data u72 {
  metadata: "ipfs://QmaZs3kapcXs8JRPJbBif98Qga1PSNRAE7ePtzrdj9q4Gf",
  price: u75000000,
  claimed: false
})


(map-set nft-data u73 {
  metadata: "ipfs://QmTYfA7YKHKmRsTTiMyxVLg5eyMB3m6vSbuuUpP1c7XvQx",
  price: u100000000,
  claimed: false
})


(map-set nft-data u74 {
  metadata: "ipfs://QmapwtY2neWBF2e4uCn3uXPCpCQxzsfohXr7Kqq6xYNjEs",
  price: u100000000,
  claimed: false
})


(map-set nft-data u75 {
  metadata: "ipfs://Qmb4dRWcrbuccrJTqT8uXHZRsYVDkFxVcfAqbxhaisVb2E",
  price: u100000000,
  claimed: false
})


(map-set nft-data u76 {
  metadata: "ipfs://QmWRQaDPW3GVKHWRaffztRtra41fxM6pQJrkwLEydQVAsU",
  price: u100000000,
  claimed: false
})


(map-set nft-data u77 {
  metadata: "ipfs://QmWe5LkGM1uqubDJWKqdNRXKwyJTU7FZaNeVtvNawx3yDq",
  price: u100000000,
  claimed: false
})


(map-set nft-data u78 {
  metadata: "ipfs://QmPa1bnHCP83CwTHmXwZsR5i5SqBoZ7EgYJNsukcxRjgir",
  price: u100000000,
  claimed: false
})


(map-set nft-data u79 {
  metadata: "ipfs://QmWmoM5K4qjc1KzrX1C5GGzQPKLPDKVT9ZxCYC62obAFcX",
  price: u100000000,
  claimed: false
})


(map-set nft-data u80 {
  metadata: "ipfs://QmaC6co8fcNWqsA5Dmm1PuKy2yDYiag9rPpPvimi1bRfNq",
  price: u100000000,
  claimed: false
})


(map-set nft-data u81 {
  metadata: "ipfs://QmXhdjTVN7Bq5Bo2gZxYQE5ipQBpvKeqCr3buM68CLJ1X7",
  price: u100000000,
  claimed: false
})


(map-set nft-data u82 {
  metadata: "ipfs://QmcgEoHx46nxbgLCLMoxmDfUzeJza89ABC8dwEnLEocjkK",
  price: u100000000,
  claimed: false
})


(map-set nft-data u83 {
  metadata: "ipfs://QmVRQfTsBbTUvGC1mYAHmfeSL2zoMk3LN1a7vyLEZuQQrT",
  price: u100000000,
  claimed: false
})


(map-set nft-data u84 {
  metadata: "ipfs://QmS2V3aireRfMLUx3qDsnWUQcMkBTQYNBX4Lb7e5RmvD4i",
  price: u100000000,
  claimed: false
})


(map-set nft-data u85 {
  metadata: "ipfs://QmbKBipeN8qdPxexxrNpPM9yDeimdCag7YsFSUSBUafU3B",
  price: u100000000,
  claimed: false
})


(map-set nft-data u86 {
  metadata: "ipfs://QmfHtxVDsvyXn8rnTWog8X8ipZMABSLmaaYF3jjkQV88J7",
  price: u100000000,
  claimed: false
})


(map-set nft-data u87 {
  metadata: "ipfs://QmcMqwMjjrMTYAMHQPCgVivPAMvm9Hxcb7AYa14ojoffBk",
  price: u100000000,
  claimed: false
})


(map-set nft-data u88 {
  metadata: "ipfs://QmPpuyaNysmXErUMhFK3p8fbJFLs7G6snEJAExTaLxHrMq",
  price: u100000000,
  claimed: false
})


(map-set nft-data u89 {
  metadata: "ipfs://QmZ4cTsPawDkzVmoFXKHKs3LFMyYV4M8f6otuy5YH1xUFH",
  price: u100000000,
  claimed: false
})


(map-set nft-data u90 {
  metadata: "ipfs://QmVpobXfWwuGUYTKVFskU3JDg33KN6EcoiMfHQjbSCGhYG",
  price: u100000000,
  claimed: false
})


(map-set nft-data u91 {
  metadata: "ipfs://QmcaAmoYPMASDMzxhsJKX1f74iSegvTwKxgxe6W6DZSZmY",
  price: u100000000,
  claimed: false
})


(map-set nft-data u92 {
  metadata: "ipfs://QmRzGvuRLZHXQyEGF9VoUyPKeFHmifFFaUMPsUEb5qWmws",
  price: u100000000,
  claimed: false
})


(map-set nft-data u93 {
  metadata: "ipfs://QmfTntrTdfKhJNMBQDjhFJH6fPVDJWq3coULRu1qsBgtyb",
  price: u100000000,
  claimed: false
})


(map-set nft-data u94 {
  metadata: "ipfs://QmX29vCipU1ijAVFMBqzebFukBsYSYm844SJjLpSbXbhrR",
  price: u100000000,
  claimed: false
})


(map-set nft-data u95 {
  metadata: "ipfs://QmPE4vYtQPXEzUT7Kdx7Td5BRCV1CHQ489HGiRuCMercR2",
  price: u100000000,
  claimed: false
})


(map-set nft-data u96 {
  metadata: "ipfs://QmXHrffLiwMQLvsYf2YULyxYiAiu2XuEMJVM5MYD5fyg6Q",
  price: u100000000,
  claimed: false
})


(map-set nft-data u97 {
  metadata: "ipfs://QmSE41CZoX8LHggurW4HLcT9XUymkELDeMMTUKR485S8us",
  price: u100000000,
  claimed: false
})


(map-set nft-data u98 {
  metadata: "ipfs://QmQqXGVGdFg63TkxBrHi3j2jC9W3xHS3SfGNvWd3U6axJe",
  price: u150000000,
  claimed: false
})


(map-set nft-data u99 {
  metadata: "ipfs://QmWDhTjd2KpF3xrwHSTdYDKSdLazu5h6JiJ6vvC4LCuHsA",
  price: u150000000,
  claimed: false
})


(map-set nft-data u100 {
  metadata: "ipfs://QmQSDm5eeCxqBKLTQ8sAigiFsCd938sy8U8oyBiQypitKV",
  price: u150000000,
  claimed: false
})


(map-set nft-data u101 {
  metadata: "ipfs://QmTP5podJr42XtbyECmmbfQQZHchAiZS3Yw81SLxzhQ2eg",
  price: u150000000,
  claimed: false
})


(map-set nft-data u102 {
  metadata: "ipfs://QmWbdyu2RPX8gyjVKre24oUhSi1nB4PdAc3xJqbnbCPzaP",
  price: u150000000,
  claimed: false
})


(map-set nft-data u103 {
  metadata: "ipfs://QmTkPDJg4yDQLaV6Yegj2YUvEeuHsvswENcPTAXsLqzRNw",
  price: u150000000,
  claimed: false
})


(map-set nft-data u104 {
  metadata: "ipfs://QmdouyheDWk5fU9fkZgkSREQKmhmehZXZWTLTVLX5qkuyV",
  price: u150000000,
  claimed: false
})


(map-set nft-data u105 {
  metadata: "ipfs://Qme14EJwqNr7Mi531dmxSd894z53nqqEApBVwca2puBmrC",
  price: u150000000,
  claimed: false
})


(map-set nft-data u106 {
  metadata: "ipfs://QmTwVr84kZX9zSSifncvFnuxYxRsg36WuRASw7x3cXjno2",
  price: u150000000,
  claimed: false
})


(map-set nft-data u107 {
  metadata: "ipfs://Qma43z9NsRP8j8fqgsBQEdfg5yp11sdeXoeYwijx5CSi5K",
  price: u150000000,
  claimed: false
})


(map-set nft-data u108 {
  metadata: "ipfs://QmcXfZykPNmdbRBPEM4XuTnKqCMWmJ7esY6vVPMo7YtiVh",
  price: u150000000,
  claimed: false
})


(map-set nft-data u109 {
  metadata: "ipfs://QmdwxNST2FG63qpBwhLiurKKqsXgKkP54foebPGMcqzHvH",
  price: u150000000,
  claimed: false
})


(map-set nft-data u110 {
  metadata: "ipfs://QmWVVikcDK2f4jPrbU7cnyx98w1pa9GTKzDUXv8YnRSuVZ",
  price: u150000000,
  claimed: false
})


(map-set nft-data u111 {
  metadata: "ipfs://QmQVfDTKDbwZ8o3moDXXtQ8tUkJpr55qGtBkLxYnNSG56F",
  price: u150000000,
  claimed: false
})


(map-set nft-data u112 {
  metadata: "ipfs://QmXzbByYkpdcG3wC5gdSVeNQdcqKXFRgSCtNtmYcdkAwNW",
  price: u150000000,
  claimed: false
})


(map-set nft-data u113 {
  metadata: "ipfs://QmPJiCuqeukgn9HKGppDgqpbezsPcbodaWCJKbbdTLzqkt",
  price: u150000000,
  claimed: false
})


(map-set nft-data u114 {
  metadata: "ipfs://QmdDiSaak4sBoovX3rAWe9wwULmiUpNRHjgR4qBeTeQBht",
  price: u150000000,
  claimed: false
})


(map-set nft-data u115 {
  metadata: "ipfs://QmX3rQFnhiHgsBLaJ95EBW27Zc3iRFW8SttxRXdKwEWdeC",
  price: u150000000,
  claimed: false
})


(map-set nft-data u116 {
  metadata: "ipfs://QmcDoSdRBKP3iw6QBPAz9Lj3b2upW9XsfVLawYkGvj6oJa",
  price: u150000000,
  claimed: false
})


(map-set nft-data u117 {
  metadata: "ipfs://QmXxoy4QsavS5fBbTf9To36KF9cFLE32GGfYZEnd8xHFyX",
  price: u150000000,
  claimed: false
})


(map-set nft-data u118 {
  metadata: "ipfs://QmU6QFJKsLQa9UAhVR1EYqmdB4UrykDRy4yYmUVc2uZZGH",
  price: u150000000,
  claimed: false
})


(map-set nft-data u119 {
  metadata: "ipfs://QmfGjnan9PudA5dSLGXRRye1i4XjjqLqV4RWKNizxnRaRT",
  price: u150000000,
  claimed: false
})


(map-set nft-data u120 {
  metadata: "ipfs://QmbHu7qGSZfS7bnZU9juR1tpdGSLozEnEGWEyWoZfgUsw3",
  price: u150000000,
  claimed: false
})


(map-set nft-data u121 {
  metadata: "ipfs://QmQ8QpUKp6BeqCbxvNX2vT4PR65tNSiUyM81Z4gqGfAbu6",
  price: u150000000,
  claimed: false
})


(map-set nft-data u122 {
  metadata: "ipfs://QmaMRagnvP5zpNFgHPfQ9hMnErbEHEBrFN7PJb7aTKYivD",
  price: u150000000,
  claimed: false
})


(map-set nft-data u123 {
  metadata: "ipfs://QmYNd8BUNmQLnAYoZdyiPwQ4AGDCiHyP3B4nzBoKY28YbS",
  price: u200000000,
  claimed: false
})


(map-set nft-data u124 {
  metadata: "ipfs://QmZnAa85FducikC8s7yr4GNpH2UgWLjdAcgHWjs3g7YMfn",
  price: u200000000,
  claimed: false
})


(map-set nft-data u125 {
  metadata: "ipfs://QmYhRmyepBUDc35aNTDyX9UR9UdRFUSwFLXxp9oFTcVyL8",
  price: u200000000,
  claimed: false
})


(map-set nft-data u126 {
  metadata: "ipfs://QmU9jQuj6Cc1uVp1gy4MNkjRjmgP6HxEQxLiJmvJh4m8my",
  price: u200000000,
  claimed: false
})


(map-set nft-data u127 {
  metadata: "ipfs://QmdFUxXwVdhe3cGDy7Vo4SA14isHcPutA2f9bvic33gwS6",
  price: u200000000,
  claimed: false
})


(map-set nft-data u128 {
  metadata: "ipfs://QmQaZaHzvvaz7rLAejceUKz47WJsrnBswhk7q6Rs2HV4rZ",
  price: u200000000,
  claimed: false
})


(map-set nft-data u129 {
  metadata: "ipfs://Qma3y8WMBvXsUtSV3DMEkwmR994i1rMM1dQs7eD4nby25z",
  price: u200000000,
  claimed: false
})


(map-set nft-data u130 {
  metadata: "ipfs://Qmbxib3VdT3ypwYZQdXjWhksXn7rxHHWfnDjLJa5jcmHLA",
  price: u200000000,
  claimed: false
})


(map-set nft-data u131 {
  metadata: "ipfs://QmWYxTTsTQJ7eYEHwR3Fe2xGzycoQ18jY1YHyBt3CHsEQk",
  price: u200000000,
  claimed: false
})


(map-set nft-data u132 {
  metadata: "ipfs://QmfNadSXzs1StvLH9mSvYPEwR1WWiNtg5STB9EgpRC4Y99",
  price: u200000000,
  claimed: false
})


(map-set nft-data u133 {
  metadata: "ipfs://QmPsghSBQjUsvshibp9msnjdHTT3QZonpwRrottiGkrhtG",
  price: u200000000,
  claimed: false
})


(map-set nft-data u134 {
  metadata: "ipfs://QmPnCXFxPbhX2mqpzEV8AiFZBbijiSuuzraUyQCWNqno6v",
  price: u200000000,
  claimed: false
})


(map-set nft-data u135 {
  metadata: "ipfs://QmXWyHcA76VBZ6f73tvVGbh42utx2ct3uTymfEzJDJZiyD",
  price: u200000000,
  claimed: false
})


(map-set nft-data u136 {
  metadata: "ipfs://QmaE3DpUGMSBiA66gtvoTYuYUuV8PyxbTMfPPE2BNgz9PD",
  price: u200000000,
  claimed: false
})


(map-set nft-data u137 {
  metadata: "ipfs://QmYhJTkbcCY1rFm9GNvxpqNTpwd6NMDyz7tmT98JxY6kXu",
  price: u200000000,
  claimed: false
})


(map-set nft-data u138 {
  metadata: "ipfs://QmQFy3ULP4QNERoswy1PGsXcLgZZxyBnbq954ZuehdQy2J",
  price: u200000000,
  claimed: false
})


(map-set nft-data u139 {
  metadata: "ipfs://QmQACjMYxCawkEm76vrqgXgJu4ihtxKfPyQGC6JyJRG2e8",
  price: u200000000,
  claimed: false
})


(map-set nft-data u140 {
  metadata: "ipfs://QmYejT14BDZ9ZwYkkM2GVQReAXT2KA8waoN8oCMpmwbFEt",
  price: u200000000,
  claimed: false
})


(map-set nft-data u141 {
  metadata: "ipfs://QmYE7VWVwPxVx9suuGSto3Ge3j8RZRNdXtDSE6s8o8GJSi",
  price: u200000000,
  claimed: false
})


(map-set nft-data u142 {
  metadata: "ipfs://QmZwehoDbXUvASESozLcc4FwA5JB3qxc5GBBEsCPxb4xoo",
  price: u200000000,
  claimed: false
})


(map-set nft-data u143 {
  metadata: "ipfs://QmdCczKin3txYKu6oXX9NfkkvkXwaMysfsGhxBK3RCpmUo",
  price: u200000000,
  claimed: false
})


(map-set nft-data u144 {
  metadata: "ipfs://QmctxeWc7U3QgZH84ViRydveGXTL7P94iX3GSXDvpcnrfQ",
  price: u200000000,
  claimed: false
})


(map-set nft-data u145 {
  metadata: "ipfs://QmQKoWXSJcYT9ebWrrmjD5hJKUafbDCXuEBXxN1QmEGiiX",
  price: u200000000,
  claimed: false
})


(map-set nft-data u146 {
  metadata: "ipfs://QmaaUoDLXLeMJektGTLcKuaXDs5PL82mrtpUJEuTA1a2jB",
  price: u200000000,
  claimed: false
})


(map-set nft-data u147 {
  metadata: "ipfs://QmVvKzstF9swz99LFReqU4yhdkYpDHHnw6JNnHBFMFLHVV",
  price: u200000000,
  claimed: false
})


(map-set nft-data u148 {
  metadata: "ipfs://Qmer9WGMqUnjJvUmpYupY41wa3PMvwxHCDqbjG5ZY5zcAA",
  price: u500000000,
  claimed: false
})


(map-set nft-data u149 {
  metadata: "ipfs://QmehYrCxUXPY7SS6oc8mvjCG1f2HTAnRs2vQa5RZd4PpTi",
  price: u500000000,
  claimed: false
})


(map-set nft-data u150 {
  metadata: "ipfs://QmYe1BaYMuWZEkMecB5vfUSbgXAVfpAusjUgDGBVRkjCfM",
  price: u500000000,
  claimed: false
})


(map-set nft-data u151 {
  metadata: "ipfs://QmR1n5TkejVqWnE79jZq3uuvaFnEgBCtw1ARTNP3LiCJba",
  price: u500000000,
  claimed: false
})


(map-set nft-data u152 {
  metadata: "ipfs://QmYmMM4E8QbowcUSryibn5ruikuqsuQAEbnJRq8rVQJ61P",
  price: u500000000,
  claimed: false
})


(map-set nft-data u153 {
  metadata: "ipfs://QmVWHMS5tD6u1HxTsnVUqkgtnutbGxh75dh1YGGsTnsMJU",
  price: u500000000,
  claimed: false
})


(map-set nft-data u154 {
  metadata: "ipfs://QmZAP45AXUXp2KEB4k6P2SAiyLBG8XP27Wgkct9vuTo7aq",
  price: u500000000,
  claimed: false
})


(map-set nft-data u155 {
  metadata: "ipfs://QmR9m1Mp2P45hGQm6WjDy7xCYwU4tXZGcqsLso4TEEMdNA",
  price: u500000000,
  claimed: false
})


(map-set nft-data u156 {
  metadata: "ipfs://QmZNqzPm8hHwEQ7VSC1w2kCNGT5DKPGB7dFLbuCNGCsxtx",
  price: u500000000,
  claimed: false
})


(map-set nft-data u157 {
  metadata: "ipfs://QmeiRBCoaLEuJkN7XzVv7qGQxj7GNaEWLzB849Chz5GdNx",
  price: u500000000,
  claimed: false
})


(map-set nft-data u158 {
  metadata: "ipfs://QmaDvg7uCHgpmWnZFxQQWWUwm3CBnofcPKvuNGpdFL6EC8",
  price: u500000000,
  claimed: false
})


(map-set nft-data u159 {
  metadata: "ipfs://QmTxeUscDs4x6Z6hH8JC9BC1Wtc3WbPdU1BQcFyvwJngkw",
  price: u500000000,
  claimed: false
})


(map-set nft-data u160 {
  metadata: "ipfs://QmV44qFv56oY6C7Urz98JWqjQkFxG2TFUkx5bP4FTuQbby",
  price: u500000000,
  claimed: false
})


(map-set nft-data u161 {
  metadata: "ipfs://QmbEUda5xVTgY4jM1WGNzT3h6WAsKhCuYzCsDE5MtTiUDm",
  price: u500000000,
  claimed: false
})


(map-set nft-data u162 {
  metadata: "ipfs://QmQf8TZMGXeT1ZnwzVSHsHFXzA27Vy346USQ7masWjJScH",
  price: u500000000,
  claimed: false
})


(map-set nft-data u163 {
  metadata: "ipfs://QmXsnuu667NgUqmefDJ75ThLr26QWtupK66cGTUzQhbgEJ",
  price: u500000000,
  claimed: false
})


(map-set nft-data u164 {
  metadata: "ipfs://QmdvZXADsa3GX6A1a1Gvt6Ug6xsXguvYfwHzZWAWfcMi2y",
  price: u500000000,
  claimed: false
})


(map-set nft-data u165 {
  metadata: "ipfs://QmYmnXri1dJy7KUgjed7VvVn8QPC61VLY5cEnGh6Gnkgwu",
  price: u500000000,
  claimed: false
})


(map-set nft-data u166 {
  metadata: "ipfs://QmYQDCgKdMJL2NVpMx7j2ach21vrt3SwxzWUDUxAJ9ejbX",
  price: u500000000,
  claimed: false
})


(map-set nft-data u167 {
  metadata: "ipfs://Qmbq4fJGx4QJe4PwpwwvWc6Uhww2dHmRYHJqeC4vdqqvc5",
  price: u500000000,
  claimed: false
})


(map-set nft-data u168 {
  metadata: "ipfs://QmXxsw83cx7gR9A1sHCaazFeRpVPcj7qP6SGkZga778j5j",
  price: u500000000,
  claimed: false
})


(map-set nft-data u169 {
  metadata: "ipfs://QmSA9v7kbZ3VPgpBKg2ouzJ2qRVY6JDmrG6aQnFG5FeW2i",
  price: u500000000,
  claimed: false
})


(map-set nft-data u170 {
  metadata: "ipfs://QmcwGEfXNscXE3rYvnFWSgZrLz9zxvwYwq1wFCAusJantN",
  price: u500000000,
  claimed: false
})


(map-set nft-data u171 {
  metadata: "ipfs://QmfH97gtaKbEVQC5heSYX538pAMCRmC7SBrvi6BmFian1k",
  price: u500000000,
  claimed: false
})


(map-set nft-data u172 {
  metadata: "ipfs://Qmddx67xEfgQ6SQXLkJtwerKEJMc8v5qHzPYKxvLbG8hrc",
  price: u500000000,
  claimed: false
})


(map-set nft-data u173 {
  metadata: "ipfs://QmaUNhCAWBYmvgcdzQsEGBRDQV3nBJqfMTAkwvufEmWWKW",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u174 {
  metadata: "ipfs://QmerXApHPGsp4NJEN3bdX22DqvTTqgHdHYEekcL3aetGS5",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u175 {
  metadata: "ipfs://QmdtXwmKvkpZpDFdXKfwEt5bWDnXgXAn4S2HJ6wrUodUhW",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u176 {
  metadata: "ipfs://QmUK55mR3C2mx8WySPgE7qNFJi3y4XMmg7CW1bCojyPNNR",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u177 {
  metadata: "ipfs://QmejnnkHXzixjRMWNumuSGSrozrWHZfpRTd5DZNSfJCCta",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u178 {
  metadata: "ipfs://QmP666PW7TJcVahnw7CgCs1EyifjopB9huWgQtAGNwXkoA",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u179 {
  metadata: "ipfs://QmP2fapkTq7rzegg2HqMhimTxq8dTtZaxougb8Ev4R1aK3",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u180 {
  metadata: "ipfs://QmURwiMXg9P7jxWDJ7NHu8EYRdXnBmePahAoFnYkgZJhJj",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u181 {
  metadata: "ipfs://QmUKiM7zaEuiMKaMKPAnvjKcbQ62TPf2RVi8fWRd3CLD4P",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u182 {
  metadata: "ipfs://QmUfDAK98KRuYV4BHok8GCCwZdHxLBt4SDvQooLFnFo7vr",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u183 {
  metadata: "ipfs://QmZF6WGDwJCksL6z2Wm1S6dNUbcgX8ixmrALJFvCpAaEGh",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u184 {
  metadata: "ipfs://QmVufhLBTr4YTryFnVs1gjWUnWrfpbYmTNkh7vwepqmjeX",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u185 {
  metadata: "ipfs://QmfYTYFpLurVpuQ9YcBc6dhGSLEADf6wLXVLgWmYbtXobd",
  price: u1000000000,
  claimed: false
})


(map-set nft-data u186 {
  metadata: "ipfs://QmZQ9dAdN65KUQWMewNxaJtQj8215nFPXDhgrTrStdHW1L",
  price: u1000000000,
  claimed: false
})

;; Define commission (basis points 2.00% = u100)
(define-data-var commission uint u200)

;; Claim a new NFT
(define-public (claim (nft-id uint))
  (mint tx-sender nft-id))

;; Claim a new NFT
(define-public (claim-helpdesk (nft-id uint))
  (if (is-eq tx-sender commission-address)
    (mint (var-get artist-address) nft-id)
    (err err-invalid-user)))

(define-public (set-artist-address (address principal))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set artist-address address)
      (ok true)
    )
    (err err-invalid-user)))

;; Artist sets commission (between 1% - 10%)
;; The NFT will be featured based on commission and price of the NFT
(define-public (set-commission (preferred-commission uint))
  (if (is-eq tx-sender (var-get artist-address))
    (if (and (>= preferred-commission u100) (<= preferred-commission u1000))
      (begin 
        (var-set commission preferred-commission)
        (ok u0))
      (err err-invalid-commission))
  (err err-invalid-user)))

;; Get the commission
(define-read-only (get-commission)
  (ok (var-get commission)))

;; Get the claimed property
(define-read-only (get-claimed (token-id uint))
  (match (map-get? nft-data token-id)
      next-nft
      (ok (get claimed next-nft))
      (err err-invalid-token)))

;; Get the NFT Price
(define-read-only (get-price (token-id uint))
  (match (map-get? nft-data token-id)
      next-nft
      (ok (get price next-nft))
      (err err-invalid-token)))

;; Artist can reset claim price for unclaimed NFT's
(define-public (set-price (price uint) (token-id uint))
  (if (is-eq tx-sender (var-get artist-address))
  (match (map-get? nft-data token-id)
      next-nft
      (if (get claimed next-nft)
        (err err-nft-claimed)
        (ok 
          (map-set nft-data token-id {
            metadata: (get metadata next-nft),
            price: price,
            claimed: (get claimed next-nft)
          }))
      )
      (err err-invalid-token))
    (err err-invalid-user)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (is-eq tx-sender sender)
      (match (nft-transfer? crypto-graffiti token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? crypto-graffiti token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok total-nfts))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (get metadata (map-get? nft-data token-id))))

;; Internal - Mint new NFT with a commission
(define-private (mint (new-owner principal) (nft-id uint))
  (match (map-get? nft-data nft-id)
    next-nft
    (let
      ((total-price (get price next-nft))
       (total-commission (/ (* total-price (var-get commission)) u10000))
       (total-artist (- total-price total-commission)))
      (if (and (is-eq tx-sender (var-get artist-address))
          (not (get claimed next-nft)))
        (mint-helper new-owner nft-id next-nft)
        (if (is-eq tx-sender commission-address)
          (begin
            (mint-helper new-owner nft-id next-nft))
          (begin
            (try! (stx-transfer? total-commission tx-sender commission-address))
            (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
            (mint-helper new-owner nft-id next-nft)))))
    (err err-no-more-nfts)
  )
)

;; Internal - Helper to mint new NFT
(define-private (mint-helper
  (new-owner principal)
  (nft-id uint)
  (next-nft {
    metadata: (string-ascii 55),
    price: uint,
    claimed: bool
  }))
  (match (nft-mint? crypto-graffiti nft-id new-owner)
      mint-success
        (begin
          (map-set nft-data nft-id {
            metadata: (get metadata next-nft),
            price: (get price next-nft),
            claimed: true
          })
          (ok true))
      error (err error)))
