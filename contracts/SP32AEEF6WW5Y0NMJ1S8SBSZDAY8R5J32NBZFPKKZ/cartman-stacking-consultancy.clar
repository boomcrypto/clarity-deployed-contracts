(define-constant yo-mama-jokes (list
"Yo mama's so poor she can't even pay attention"
"Yo mama's so poor the ducks throw bread at her"
"Yo mama's so poor when she goes to KFC, she has to lick other people's fingers"
"Yo mama's so poor, when she heard about the Last Supper she thought she was running out of food stamps"
"Yo mama's so poor she waves around a popsicle and calls it air conditioning"
"Yo mama's so poor she uses Cheerios for earrings"
"Yo mama's so poor she opend a Gmail account just so she could eat the spam"
"Yo mama's so poor when she gets mad she can't afford to fly off the handle so she's gotta go Greyhound off the handle"
"Yo mama's so poor she cuts coupons out to be institutionalized"
"Yo mama's so poor she only understands hand-outs"
"Yo mama's so poor she walked down the road with one shoe. And if you ask her if she lost a shoe, she'd say \"No, I found one.\""
))

(define-private (humiliate)
   (default-to "Got no more yo mama jokes" 
      (element-at yo-mama-jokes 
         (mod block-height
            (len yo-mama-jokes)))))

(define-private (does-meet-threshold) 
   (< 
      (contract-call? 'SP000000000000000000002Q6VF78.pox get-stacking-minimum)
      (/ (stx-get-balance tx-sender) u1000000)))

(define-read-only (cartman-can-i-stack) 
   (if 
      (does-meet-threshold)
      "Yes you can"
      (humiliate)))