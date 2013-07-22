open util/integer
pred show {}


abstract sig c1_Book
{ r_c2_title : one c2_title
, r_c4_year : one c4_year
, r_c5_page : set c5_page
, r_c6_format : one c6_format
, r_c10_kind : one c10_kind
, r_c17_authors : some c17_authors
, r_c33_ISBN : lone c33_ISBN }
{ 2 <= #r_c5_page
  all disj x, y : this.@r_c17_authors | (x.@ref) != (y.@ref)
  ((this.(@r_c4_year.@ref)) >= 5) => (some this.@r_c33_ISBN) }

sig c2_title
{ ref : one Int
, r_c3_subtitle : lone c3_subtitle }
{ one @r_c2_title.this }

sig c3_subtitle
{ ref : one Int }
{ one @r_c3_subtitle.this }

sig c4_year
{ ref : one Int }
{ one @r_c4_year.this }

sig c5_page
{}
{ one @r_c5_page.this }

sig c6_format
{ r_c7_paper : lone c7_paper
, r_c9_electronic : lone c9_electronic }
{ one @r_c6_format.this
  let children = (r_c7_paper + r_c9_electronic) | one children }

sig c7_paper
{ r_c8_hardcover : lone c8_hardcover }
{ one @r_c7_paper.this }

sig c8_hardcover
{}
{ one @r_c8_hardcover.this }

sig c9_electronic
{}
{ one @r_c9_electronic.this }

sig c10_kind
{ r_c11_textbook : lone c11_textbook
, r_c12_manual : lone c12_manual
, r_c13_reference : lone c13_reference
, r_c14_fiction : lone c14_fiction
, r_c15_nonfiction : lone c15_nonfiction
, r_c16_other : lone c16_other }
{ one @r_c10_kind.this
  let children = (r_c11_textbook + r_c12_manual + r_c13_reference + r_c14_fiction + r_c15_nonfiction + r_c16_other) | one children }

sig c11_textbook
{}
{ one @r_c11_textbook.this }

sig c12_manual
{}
{ one @r_c12_manual.this }

sig c13_reference
{}
{ one @r_c13_reference.this }

sig c14_fiction
{}
{ one @r_c14_fiction.this }

sig c15_nonfiction
{}
{ one @r_c15_nonfiction.this }

sig c16_other
{ ref : one Int }
{ one @r_c16_other.this }

sig c17_authors
{ ref : one c44_Author }
{ one @r_c17_authors.this }

sig c33_ISBN
{ ref : one Int
, r_c34_GS1 : lone c34_GS1 }
{ one @r_c33_ISBN.this
  (((this.~@r_c33_ISBN).(@r_c4_year.@ref)) >= 6) => (some this.@r_c34_GS1) }

sig c34_GS1
{ ref : one Int }
{ one @r_c34_GS1.this }

abstract sig c41_Person
{ r_c42_name : one c42_name
, r_c43_dob : lone c43_dob }

sig c42_name
{ ref : one Int }
{ one @r_c42_name.this }

sig c43_dob
{ ref : one Int }
{ one @r_c43_dob.this }

abstract sig c44_Author extends c41_Person
{ r_c45_books : some c45_books }
{ all disj x, y : this.@r_c45_books | (x.@ref) != (y.@ref) }

sig c45_books
{ ref : one c1_Book }
{ one @r_c45_books.this }

lone sig c55_GenerativeProgramming extends c1_Book
{}
{ (((((((((this.(@r_c2_title.@ref)) = 0) && (no (this.@r_c2_title).@r_c3_subtitle)) && ((this.(@r_c4_year.@ref)) = 5)) && ((#(this.@r_c5_page)) = 4)) && (some (this.@r_c6_format).@r_c7_paper)) && (some (this.@r_c10_kind).@r_c15_nonfiction)) && ((this.(@r_c17_authors.@ref)) = (c90_Czarnecki + c98_Eisenecker))) && ((this.(@r_c33_ISBN.@ref)) = 0)) && (no (this.@r_c33_ISBN).@r_c34_GS1) }

lone sig c90_Czarnecki extends c44_Author
{}
{ ((this.(@r_c42_name.@ref)) = 0) && (c55_GenerativeProgramming in (this.(@r_c45_books.@ref))) }

lone sig c98_Eisenecker extends c44_Author
{}
{ ((this.(@r_c42_name.@ref)) = 0) && (c55_GenerativeProgramming in (this.(@r_c45_books.@ref))) }

