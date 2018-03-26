require 'csv'

InputCSV = ARGV[0]
InputDIR = ARGV[1]
CSV.foreach(InputCSV,col_sep: "\t", quote_char: "ア",headers: true) do |row|
  id = File.basename(row['Identifier'])
  id_path = Dir.glob("#{InputDIR}/**/#{id}")
  puts id_path
end
