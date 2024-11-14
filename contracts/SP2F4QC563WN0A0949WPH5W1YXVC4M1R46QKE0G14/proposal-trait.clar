(define-trait proposal-trait
	(
		(get-votes () (response 
			{
				op1: {id: uint, votes: uint}, 
				op2: {id: uint, votes: uint}, 
				op3: {id: uint, votes: uint}, 
				op4: {id: uint, votes: uint}
			} 
			uint)
		)
		(get-total-votes () (response uint uint))
    (vote (uint) (response bool uint))
		(activate (uint) (response bool uint))
		(execute (principal uint) (response bool uint))
	)
)