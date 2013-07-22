open util/integer
pred show {}


abstract sig c1_Path
{ r_c2_p : lone c2_p
, r_c3_isDir : lone c3_isDir }
{ (some this.@r_c3_isDir) => (some this.@r_c2_p) }

sig c2_p extends c1_Path
{}
{ one @r_c2_p.this }

sig c3_isDir
{}
{ one @r_c3_isDir.this }

lone sig c13_pth extends c1_Path
{}

