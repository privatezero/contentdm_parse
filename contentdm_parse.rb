require 'csv'
require 'fileutils'

InputCSV = ARGV[0]
InputDIR = ARGV[1]
DesinationDIR = ARGV[2]
CSV.open("#{DesinationDIR}/metadata.csv", "wb") do |csv|
  CSV.foreach(InputCSV,col_sep: "\t", quote_char: "ア",headers: true) do |row|
    id = File.basename(row['Identifier'])
    id_path = Dir.glob("#{InputDIR}/**/#{id}")
    if ! id_path.empty?
      filesearch = id_path
      filesearch.each do |file|
        FileUtils.cp file, DesinationDIR + '/' + File.basename(file)
      end

    else
      filesearch = 'Path not found'
    end
    row ["Path"] = filesearch
    csv << row
  end
end
