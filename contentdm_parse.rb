require 'csv'

Input = ARGV[0]
var = CSV.read(Input,col_sep: "\t", quote_char: "ア",headers: true)
