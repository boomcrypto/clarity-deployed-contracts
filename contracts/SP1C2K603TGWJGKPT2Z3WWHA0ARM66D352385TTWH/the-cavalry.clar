(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-non-fungible-token The-Cavalry uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalties: (list 1000 uint)})
(define-map linked-ids uint uint)
(define-map transferable uint bool)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-MINTED-OUT (err u300))
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-INSUFFICIENT-FUNDS (err u400))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-METADATA-FROZEN (err u505))
(define-constant ERR-LISTING (err u507))
(define-constant ERR-ITEM-STAKED (err u402))
(define-constant ERR-BLACKLISTED (err u406))
(define-constant ERR-REDEEMED (err u405))
(define-constant MINT-LIMIT u1500)
(define-constant ERR-ITEM-LISTED (err u405))
(define-constant ERR-ITEM-NOT-STAKED (err u408))

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)
(define-data-var base-uri (string-ascii 120) "ipfs://Qmbia3wFKWENE6n77yZsVTKesLgdd8L7pqxGkLht2b1aAV/")
(define-data-var admin principal tx-sender)
(define-data-var royalties (list 1000 uint) (list u250 u250))
(define-data-var wallets (list 1000 principal) (list tx-sender 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6))
(define-data-var redeemed (list 2500 uint) (list ))
(define-data-var ids-blacklist (list 2500 uint) (list u1078 u1079 u1080 u1081 u1082 u1083 u1084 u1085 u1086 u1087 u1088 u1089 u1090 u1091 u1092 u1093 u1094 u1095 u1096 u1097 u1098 u1099 u1100 u1101 u1102 u1103 u1104 u1105 u1106 u1107 u1108 u1109 u1110 u1111 u1112 u1113 u1114 u1115 u1116 u1117 u1118 u1119 u1120 u1121 u1122 u1123 u1124 u1125 u1126 u1127 u1128 u1129 u1130 u1131 u1132 u1133 u1134 u1135 u1136 u1137 u1138 u1139 u1140 u1141 u1142 u1143 u1144 u1145 u1146 u1147 u1148 u1149 u1150 u1151 u1152 u1153 u1154 u1155 u1156 u1157 u1158 u1159 u1160 u1161 u1162 u1163 u1164 u1165 u1166 u1167 u1168 u1169 u1170 u1171 u1172 u1173 u1174 u1175 u1176 u1177 u1178 u1179 u1180 u1181 u1182 u1183 u1184 u1185 u1186 u1187 u1188 u1189 u1190 u1191 u1192 u1193 u1194 u1195 u1196 u1197 u1198 u1199 u1200 u1201 u1202 u1203 u1204 u1205 u1206 u1207 u1208 u1209 u1210 u1211 u1212 u1213 u1214 u1215 u1216 u1217 u1218 u1219 u1220 u1221 u1222 u1223 u1224 u1225 u1226 u1227 u1228 u1229 u1230 u1231 u1232 u1233 u1234 u1235 u1236 u1237 u1238 u1239 u1240 u1241 u1242 u1243 u1244 u1245 u1246 u1247 u1248 u1249 u1250 u1251 u1252 u1253 u1254 u1255 u1256 u1257 u1258 u1259 u1260 u1261 u1262 u1263 u1264 u1265 u1266 u1267 u1268 u1269 u1270 u1271 u1272 u1273 u1274 u1275 u1276 u1277 u1278 u1279 u1280 u1281 u1282 u1283 u1284 u1285 u1286 u1287 u1288 u1289 u1290 u1291 u1292 u1293 u1294 u1295 u1296 u1297 u1298 u1299 u1300 u1301 u1302 u1303 u1304 u1305 u1306 u1307 u1308 u1309 u1310 u1311 u1312 u1313 u1314 u1315 u1316 u1317 u1318 u1319 u1320 u1321 u1322 u1323 u1324 u1325 u1326 u1327 u1328 u1329 u1330 u1331 u1332 u1333 u1334 u1335 u1336 u1337 u1338 u1339 u1340 u1341 u1342 u1343 u1344 u1345 u1346 u1347 u1348 u1349 u1350 u1351 u1352 u1353 u1354 u1355 u1356 u1357 u1358 u1359 u1360 u1361 u1362 u1363 u1364 u1365 u1366 u1367 u1368 u1369 u1370 u1371 u1372 u1373 u1374 u1375 u1376 u1377 u1378 u1379 u1380 u1381 u1382 u1383 u1384 u1385 u1386 u1387 u1388 u1389 u1390 u1391 u1392 u1393 u1394 u1395 u1396 u1397 u1398 u1399 u1400 u1401 u1402 u1403 u1404 u1405 u1406 u1407 u1408 u1409 u1410 u1411 u1412 u1413 u1414 u1415 u1416 u1417 u1418 u1419 u1420 u1421 u1422 u1423 u1424 u1425 u1426 u1427 u1428 u1429 u1430 u1431 u1432 u1433 u1434 u1435 u1436 u1437 u1438 u1439 u1440 u1441 u1442 u1443 u1444 u1445 u1446 u1447 u1448 u1449 u1450 u1451 u1452 u1453 u1454 u1455 u1456 u1457 u1458 u1459 u1460 u1461 u1462 u1463 u1464 u1465 u1466 u1467 u1468 u1469 u1470 u1471 u1472 u1473 u1474 u1475 u1476 u1477 u1478 u1479 u1480 u1481 u1482 u1483 u1484 u1485 u1486 u1487 u1488 u1489 u1490 u1491 u1492 u1493 u1494 u1495 u1496 u1497 u1498 u1499 u1500 u1501 u1502 u1503 u1504 u1505 u1506 u1507 u1508 u1509 u1510 u1511 u1512 u1513 u1514 u1515 u1516 u1517 u1518 u1519 u1520 u1521 u1522 u1523 u1524 u1525 u1526 u1527 u1528 u1529 u1530 u1531 u1532 u1533 u1534 u1535 u1536 u1537 u1538 u1539 u1540 u1541 u1542 u1543 u1544 u1545 u1546 u1547 u1548 u1549 u1550 u1551 u1552 u1553 u1554 u1555 u1556 u1557 u1558 u1559 u1560 u1561 u1562 u1563 u1564 u1565 u1566 u1567 u1568 u1569 u1570 u1571 u1572 u1573 u1574 u1575 u1576 u1577 u1578 u1579 u1580 u1581 u1582 u1583 u1584 u1585 u1586 u1587 u1588 u1589 u1590 u1591 u1592 u1593 u1594 u1595 u1596 u1597 u1598 u1599 u1600 u1601 u1602 u1603 u1604 u1605 u1606 u1607 u1608 u1609 u1610 u1611 u1612 u1613 u1614 u1615 u1616 u1617 u1618 u1619 u1620 u1621 u1622 u1623 u1624 u1625 u1626 u1627 u1628 u1629 u1630 u1631 u1632 u1633 u1634 u1635 u1636 u1637 u1638 u1639 u1640 u1641 u1642 u1643 u1644 u1645 u1646 u1647 u1648 u1649 u1650 u1651 u1652 u1653 u1654 u1655 u1656 u1657 u1658 u1659 u1660 u1661 u1662 u1663 u1664 u1665 u1666 u1667 u1668 u1669 u1670 u1671 u1672 u1673 u1674 u1675 u1676 u1677 u1678 u1679 u1680 u1681 u1682 u1683 u1684 u1685 u1686 u1687 u1688 u1689 u1690 u1691 u1692 u1693 u1694 u1695 u1696 u1697 u1698 u1699 u1700 u1701 u1702 u1703 u1704 u1705 u1706 u1707 u1708 u1709 u1710 u1711 u1712 u1713 u1714 u1715 u1716 u1717 u1718 u1719 u1720 u1721 u1722 u1723 u1724 u1725 u1726 u1727 u1728 u1729 u1730 u1731 u1732 u1733 u1734 u1735 u1736 u1737 u1738 u1739 u1740 u1741 u1742 u1743 u1744 u1745 u1746 u1747 u1748 u1749 u1750 u1751 u1752 u1753 u1754 u1755 u1756 u1757 u1758 u1759 u1760 u1761 u1762 u1763 u1764 u1765 u1766 u1767 u1768 u1769 u1770 u1771 u1772 u1773 u1774 u1775 u1776 u1777 u1778 u1779 u1780 u1781 u1782 u1783 u1784 u1785 u1786 u1787 u1788 u1789 u1790 u1791 u1792 u1793 u1794 u1795 u1796 u1797 u1798 u1799 u1800 u1801 u1802 u1803 u1804 u1805 u1806 u1807 u1808 u1809 u1810 u1811 u1812 u1813 u1814 u1815 u1816 u1817 u1818 u1819 u1820 u1821 u1822 u1823 u1824 u1825 u1826 u1827 u1828 u1829 u1830 u1831 u1832 u1833 u1834 u1835 u1836 u1837 u1838 u1839 u1840 u1841 u1842 u1843 u1844 u1845 u1846 u1847 u1848 u1849 u1850 u1851 u1852 u1853 u1854 u1855 u1856 u1857 u1858 u1859 u1860 u1861 u1862 u1863 u1864 u1865 u1866 u1867 u1868 u1869 u1870 u1871 u1872 u1873 u1874 u1875 u1876 u1877 u1878 u1879 u1880 u1881 u1882 u1883 u1884 u1885 u1886 u1887 u1888 u1889 u1890 u1891 u1892 u1893 u1894 u1895 u1896 u1897 u1898 u1899 u1900 u1901 u1902 u1903 u1904 u1905 u1906 u1907 u1908 u1909 u1910 u1911 u1912 u1913 u1914 u1915 u1916 u1917 u1918 u1919 u1920 u1921 u1922 u1923 u1924 u1925 u1926 u1927 u1928 u1929 u1930 u1931 u1932 u1933 u1934 u1935 u1936 u1937 u1938 u1939 u1940 u1941 u1942 u1943 u1944 u1945 u1946 u1947 u1948 u1949 u1950 u1951 u1952 u1953 u1954 u1955 u1956 u1957 u1958 u1959 u1960 u1961 u1962 u1963 u1964 u1965 u1966 u1967 u1968 u1969 u1970 u1971 u1972 u1973 u1974 u1975 u1976 u1977 u1978 u1979 u1980 u1981 u1982 u1983 u1984 u1985 u1986 u1987 u1988 u1989 u1990 u1991 u1992 u1993 u1994 u1995 u1996 u1997 u1998 u1999 u2000 u2001 u2002 u2003 u2004 u2005 u2006 u2007 u2008 u2009 u2010 u2011 u2012 u2013 u2014 u2015 u2016 u2017 u2018 u2019 u2020 u2021 u2022 u2023 u2024 u2025 u2026 u2027 u2028 u2029 u2030 u2031 u2032 u2033 u2034 u2035 u2036 u2037 u2038 u2039 u2040 u2041 u2042 u2043 u2044 u2045 u2046 u2047 u2048 u2049 u2050 u2051 u2052 u2053 u2054 u2055 u2056 u2057 u2058 u2059 u2060 u2061 u2062 u2063 u2064 u2065 u2066 u2067 u2068 u2069 u2070 u2071 u2072 u2073 u2074 u2075 u2076 u2077)) 
(define-data-var approved-staking-contract principal (as-contract tx-sender))

;;Read Only Functions
;; get mint limit
(define-read-only (get-mint-limit) MINT-LIMIT)

;;check if an item is transferable
(define-read-only (is-transferable (id uint))
  (default-to true (map-get? transferable id )))

;; token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;;links the ids of the 2 nfts collections
(define-read-only (get-linked-id (id uint))
  (default-to u0
    (map-get? linked-ids id)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? The-Cavalry id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
   (ok (some (concat (concat (var-get base-uri) (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.conversion lookup token-id))) ".json"))))

(define-read-only (calculate-royalties (percentages (list 1000 uint)) (amount uint))
  (let (
    (indexer (- (len percentages) u1))
    (transformer (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.uint-lists lookup amount indexer))
    (dividers (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.uint-lists lookup u10000 indexer))
    (amounts (map * transformer percentages))
    (royalty-amounts (map / amounts dividers))
  )
    royalty-amounts))
    
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-read-only (get-royalty-percent)
  (ok (fold + (var-get royalties) u0)))

;;Public Functions
;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq (is-transferable id) true) ERR-ITEM-STAKED)    
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; 1 Minotauri NFT = 1 The Cavalry NFT
(define-public (redeem (ids (list 2500 uint)))
    (begin 
        (asserts! (is-eq (len (filter not-owner ids)) u0) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (len (filter not-blacklisted ids)) u0) ERR-BLACKLISTED)
        (asserts! (is-eq (len (filter not-redeemed ids)) u0) ERR-REDEEMED)
        (map mint ids)
        (ok true)))

(define-public (pay-royalties (addresses (list 1000 principal)) (percentages (list 1000 uint)) (amount uint))
  (let (
    (amounts (calculate-royalties percentages amount))
    (total-royalties (fold + amounts u0))
    (total (+ total-royalties amount))
  )
    (asserts! (>= (stx-get-balance tx-sender) total) (err ERR-INSUFFICIENT-FUNDS))
    (print (map pay addresses amounts))
    (ok true)))

(define-public (pay (address principal) (amount uint))
  (begin
    (if (> amount u0)
     (begin
      (try! (stx-transfer? amount tx-sender address))
      (ok true)
     )
     (begin
      (ok true)
     ))))

(define-public (burn (id uint))
    (let (
        (owner (unwrap-panic (unwrap-panic (get-owner id))))
    )
    (asserts! (is-eq tx-sender owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (asserts! (is-eq (is-transferable id) true) ERR-ITEM-STAKED)
    (match (nft-burn? The-Cavalry id owner)
        success
        (let
        ((current-balance (get-balance owner)))
          (begin
            (map-set token-count
              owner
              (- current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm), royalties: (var-get royalties)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (is-transferable id) true) ERR-ITEM-STAKED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let 
      (
        (owner (unwrap! (nft-get-owner? The-Cavalry id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing))
        (artists-royalty (get royalties listing))
        (paid (pay-royalties (var-get wallets) artists-royalty price))
      )  
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;;callable only from staking
(define-public (set-transferable (contract principal) (id uint) (switch bool))
  (begin 
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq contract-caller contract) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq contract-caller (var-get approved-staking-contract)) ERR-NOT-AUTHORIZED)
    (if (not switch) (asserts! (is-none (get-listing-in-ustx id)) ERR-ITEM-LISTED) true)
    (map-set transferable id switch)
    (ok true)))

;; set base uri
(define-public (set-base-uri (new-base-uri (string-ascii 120)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-uri new-base-uri)
    (ok true)))      

;; change royalty amounts
(define-public (royalty-change (amounts (list 1000 uint)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set royalties amounts))
    (err ERR-NOT-AUTHORIZED)))

;; change royalty addressess
(define-public (royalty-addresses-change (addresses (list 1000 principal)))
  (if (is-eq tx-sender (var-get admin))
    (ok (var-set wallets addresses))
    (err ERR-NOT-AUTHORIZED)))

;; freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; change contract admin
(define-public (change-admin (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (var-set admin address)
    (ok true)))

;; change staking contract
(define-public (change-staking (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (var-set approved-staking-contract address)
    (ok true)))

;;Private Functions
;;check if the tx sender is non the owner
(define-private (not-owner (id uint))
    (not (is-eq (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.minotauri-nft get-owner id))) tx-sender)))

;;check if the id is not blacklisted
(define-private (not-blacklisted (id uint))
    (is-some (index-of (var-get ids-blacklist) id)))

;;check if the id is not already redeemed
(define-private (not-redeemed (id uint))
    (is-some (index-of (var-get redeemed) id)))

;; mint new NFT
(define-private (mint (old-id uint))
    (let (
        (next-id (+ u1 (var-get last-id)))
    )
    (asserts! (<= next-id MINT-LIMIT) ERR-MINTED-OUT)
      (match (nft-mint? The-Cavalry next-id tx-sender)
        success
        (let (
            (current-balance (get-balance tx-sender))
            (redeemed-ids (var-get redeemed))
            )          
            (var-set last-id next-id)
            (var-set redeemed (unwrap-panic (as-max-len? (append redeemed-ids old-id) u2500)))
            (map-set token-count tx-sender (+ current-balance u1))
            (map-set linked-ids old-id next-id)
            (ok true))
        error (err (* error u10000)))))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? The-Cavalry id sender recipient)
        success
          (let
            ((sender-balance (get-balance sender))
            (recipient-balance (get-balance recipient)))
              (map-set token-count
                    sender
                    (- sender-balance u1))
              (map-set token-count
                    recipient
                    (+ recipient-balance u1))
              (ok success))
        error (err error)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? The-Cavalry id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))