open util/integer
pred show {}


abstract sig c1_TimeLevel
{ r_c2_aggregatesTo : lone c2_aggregatesTo }
{ all disj x, y : this.@r_c2_aggregatesTo | (x.@ref) != (y.@ref) }

sig c2_aggregatesTo
{ ref : one c1_TimeLevel }
{ one @r_c2_aggregatesTo.this }

abstract sig c12_YearLevel extends c1_TimeLevel
{}
{ no this.@r_c2_aggregatesTo }

abstract sig c15_MonthLevel extends c1_TimeLevel
{}
{ (this.(@r_c2_aggregatesTo.@ref)) in c12_YearLevel }

abstract sig c19_WeekLevel extends c1_TimeLevel
{}
{ (this.(@r_c2_aggregatesTo.@ref)) in c15_MonthLevel }

lone sig c23_Year2012 extends c12_YearLevel
{}

lone sig c24_Jan2012 extends c15_MonthLevel
{}
{ (this.(@r_c2_aggregatesTo.@ref)) = c23_Year2012 }

lone sig c30_Week1 extends c19_WeekLevel
{}
{ (this.(@r_c2_aggregatesTo.@ref)) = c24_Jan2012 }

sig c36_Week1AggregatesTo
{ ref : one c1_TimeLevel }

fact { all disj x, y : c36_Week1AggregatesTo | (x.@ref) != (y.@ref) }
fact { (c30_Week1.(@r_c2_aggregatesTo.@ref)) in (c36_Week1AggregatesTo.@ref) }
fact { ((c30_Week1.@r_c2_aggregatesTo).(@ref.(@r_c2_aggregatesTo.@ref))) in (c36_Week1AggregatesTo.@ref) }
fact { (c36_Week1AggregatesTo.@ref) = (c24_Jan2012 + c23_Year2012) }
