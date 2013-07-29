open util/integer
pred show {}


one sig c1_Clafer1
{ r_c2_type : one c2_type }

one sig c2_type
{ r_c3_Type1 : lone c3_Type1
, r_c4_Type2 : lone c4_Type2 }
{ let children = (r_c3_Type1 + r_c4_Type2) | one children }

lone sig c3_Type1
{}
{ one r_c3_Type1 }

lone sig c4_Type2
{}
{ one r_c4_Type2 }

one sig c5_Clafer2
{ r_c6_clafer1 : one c6_clafer1
, r_c7_type : one c7_type }
{ all disj x, y : this.@r_c6_clafer1 | (x.@ref) != (y.@ref)
  (some (this.@r_c7_type).@r_c8_Type1) => (some ((this.@r_c6_clafer1).(@ref.@r_c2_type)).@r_c4_Type2)
  (some (this.@r_c7_type).@r_c8_Type1) => (some ((this.@r_c6_clafer1).(@ref.@r_c2_type)).@r_c4_Type2) }

one sig c6_clafer1
{ ref : one c1_Clafer1 }

one sig c7_type
{ r_c8_Type1 : lone c8_Type1
, r_c9_Type2 : lone c9_Type2 }
{ let children = (r_c8_Type1 + r_c9_Type2) | one children }

lone sig c8_Type1
{}
{ one r_c8_Type1 }

lone sig c9_Type2
{}
{ one r_c9_Type2 }

