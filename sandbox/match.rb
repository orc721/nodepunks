require 'cocos'

require 'digest'




require_relative 'base'   ## build HASHES lookup/table


##
# get minted images

files = Dir.glob( "./punks/*.png" )
puts "  #{files.size} file(s)"

## make sure files are sorted
files = files.sort


mapping = []

errors = []

files.each_with_index do |file,i|

   inscribe_num = File.basename( file, File.extname(file) ).to_i(10)
   puts "==> #{i} - #{inscribe_num} =>  ..."
   blob = read_blob( file )
   image_hash = Digest::SHA256.hexdigest( blob )
   pp image_hash
 
   punk_nums = HASHES[ image_hash ]
   pp punk_nums

   if punk_nums.empty?
      puts "!! overflow - pirate / frontrunning mint ??"

      errors << "!! overflow (duplicate) - pirate / frontrunning mint @ #{inscribe_num}"
      next
   end

   mapping << [ inscribe_num, punk_nums.shift ]
end


pp mapping
puts "   #{mapping.size} punk(s)"


headers = ['num', 'ref']
buf = ""
buf << headers.join( ', ' )
buf << "\n"
mapping.each do |values|
   buf << values.join( ', ' )
   buf << "\n"
end 

write_text( "mint.csv", buf)


pp errors

puts "bye"
