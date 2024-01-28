require 'cocos'

require 'digest'



##
# check image hash

files = Dir.glob( "../welovepunks/i/*.png" )
puts "  #{files.size} file(s)"
#=> 5000 file(s)


hashes = {}

files.each_with_index do |file,i|
   basename=File.basename( file, File.extname( file))
   num = basename.sub( 'punk', '' ).to_i(10)

   blob = read_blob( file )
   hash = Digest::SHA256.hexdigest( blob )
   hashes[ hash ] ||= []
   hashes[ hash] << num

   print "."
   print i    if i % 100 == 0
end
print "\n"

## check if any duplicates?
duplicates = Hash.new(0)
hashes.each do |hash, nums|
    if nums.size > 1
        puts "!! #{hash}"
        pp nums

        duplicates[nums.size] += 1 
    end
end

#=> 279 duplicates!!

puts "duplicates:"
pp duplicates

##
## {2  => 234, 
##  3  => 29, 
#   4  =>6,
#   5  =>3,
#   6  =>3
#   7  =>1,
#   8  =>1, 
#   13 =>2, 

puts "bye"
