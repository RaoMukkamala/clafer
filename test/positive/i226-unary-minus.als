open util/integer
pred show {}


lone sig c1_x
{ ref : one Int }

fact { (c1_x.@ref) = ((-1.mul[(1.add[2])]).div[3]) }
