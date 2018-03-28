require 'csv'
require 'fileutils'

InputCSV = ARGV[0]
InputDIR = ARGV[1]
DesinationDIR = ARGV[2]
CSV.open("#{DesinationDIR}/metadata.csv", "wb") do |csv|
  CSV.foreach(InputCSV,col_sep: "\t", quote_char: "ア",headers: true) do |row|
    if ! row['Identifier'].nil?
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
    end
    row ["filename"] = filesearch
    if $. == 2
      output_headers = Array.new
      row.headers.each do |original_header|
        if original_header == 'Title'
          finalheader = 'dc.title'
        elsif original_header == 'Date'
          finalheader = 'dc.date'
        elsif original_header == 'Subject'
          finalheader = 'dc.subject'
        elsif original_header == 'Creator'
          finalheader = 'dc.creator'
        elsif original_header == 'Description'
          finalheader = 'dc.description'
        elsif original_header == 'Rights'
          finalheader = 'dc.rights'
        elsif original_header == 'Type'
          finalheader = 'dc.type'
        elsif original_header == 'Identifier'
          finalheader = 'dc.identifer'
        elsif original_header == 'Source'
          finalheader = 'dc.source'
        elsif original_header == 'Publisher'
          finalheader = 'dc.publisher'
        elsif original_header == 'Language'
          finalheader = 'dc.language'
        elsif original_header == 'coverage'
          finalheader = 'dc.coverage'
        elsif original_header == 'Format'
          finalheader = 'dc.format'
        else
          finalheader = original_header
        end
        output_headers << finalheader
      end
      csv << output_headers
    end
  csv << row
  end
end
