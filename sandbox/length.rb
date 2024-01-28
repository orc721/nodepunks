
##
# check max filesize


files = Dir.glob( "../welovepunks/i/*.png" )
puts "  #{files.size} file(s)"
#=> 5000 file(s)

max = 0
files.each do |file|
    bytes = File.size( file )
    max   = bytes > max ? bytes : max
end

puts "max:  #{max} bytes"
#=> max:  372 bytes  !!!



puts "bye"