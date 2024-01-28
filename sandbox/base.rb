
##
# check image hash

files = Dir.glob( "../welovepunks/i/*.png" )
puts "  #{files.size} file(s)"
#=> 5000 file(s)

HASHES = {}

files.each_with_index do |file,i|
   basename=File.basename( file, File.extname( file))
   num = basename.sub( 'punk', '' ).to_i(10)

   blob = read_blob( file )
   hash = Digest::SHA256.hexdigest( blob )
   HASHES[ hash ] ||= []
   HASHES[ hash] << num

   print "."
   print i    if i % 100 == 0
end
print "\n"



