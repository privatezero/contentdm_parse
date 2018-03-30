require 'csv'
require 'fileutils'
require 'optparse'
require 'digest'


$inputTSV = ''
$inputDIR = ''
$desinationDIR = ''

ARGV.options do |opts|
  opts.on("-t", "--tsv=val", String)   { |val| $inputTSV = val }
  opts.on("-d", "--directory=val", String)  { |val| $inputDIR = val }
  opts.on("-o", "--output=val", String)     { |val| $desinationDIR = val }
  opts.parse!
end
    
# Create Archivematica transfer structure
if ! File.exists?("#{$desinationDIR}/objects")
  Dir.mkdir "#{$desinationDIR}/objects"
end
if ! File.exists?("#{$desinationDIR}/metadata")
  Dir.mkdir "#{$desinationDIR}/metadata"
end

# Parse CONTENTdm CSV
CSV.open("#{$desinationDIR}/metadata/metadata.csv", "wb") do |csv|
  CSV.foreach($inputTSV,col_sep: "\t", quote_char: "ア",headers: true) do |row|
    if ! row['Identifier'].nil?
      # If found, copy files to transfer package and add relative path to CSV
      id = File.basename(row['Identifier'])
      id_path = Dir.glob("#{$inputDIR}/**/#{id}.*")
      if ! id_path.empty?
        filesearch = id_path
        filesearch.each do |original_file|
          package_file = "#{$desinationDIR}/objects" + '/' + File.basename(original_file)
          if ! File.exist? package_file
            puts "Copying: #{id_path}"
            FileUtils.cp original_file, package_file
            # Verify fixity integrity of copied files
            md5_original = Digest::MD5.file(original_file)
            md5_package = Digest::MD5.file(package_file)
            if md5_original == md5_package
              puts "Fixity of #{package_file} validated"
              row ["filename"] = "objects/#{File.basename(original_file)}"
            else
              abort "Critical Error: MD5 mismatch with source and #{package_file}  Exiting"
            end
          end
        end
      else
        # If not found, note in CSV and add to missing files log
        filesearch = 'Path not found'
        open("#{$desinationDIR}/missing_file_list.txt", 'a') do |missing|
          missing << "#{File.basename(row['Identifier'])}.\n"
          row ["filename"] = "FILE NOT FOUND"
        end
      end
    end
    if $. == 2
      # Parse CONTENTdm DC export headers into Archivematica DC ingest format
      @output_headers = Array.new
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
        @output_headers << finalheader
      end
      # Swap file location column to first position (Archivematica ingest rule)
      header_new_order = []
      header_new_order << @output_headers.last
      @output_headers[0...-1].each do |header|
        header_new_order << header
      end
      csv << header_new_order
    end
    row_new_order = []
    row_new_order << row["#{@output_headers.last}"]
    row.headers[0...-1].each do |content|
      row_new_order << row["#{content}"]
    end
    csv << row_new_order
end
end
