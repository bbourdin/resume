all
rule 'MD013', :line_length => 500
# we dont have a first top level header
exclude_rule 'MD002'
exclude_rule 'MD041'
exclude_rule 'MD033'
# we have multiple quotes listed
exclude_rule 'MD028'
# we have some list of jobs with a description just below
exclude_rule 'MD032'
# the R code embeded in R-markdown can have some comment which is not a header
exclude_rule 'MD023'
# when having comments in the marp header
exclude_rule 'MD022'
