require 'cocos'

require 'digest'

$LOAD_PATH.unshift( "../pixelart/ordbase/ordinals/lib" )
require 'ordinals'
require 'ordlite'
require 'date'



require_relative 'base'    ## build HASHES lookup/table







OrdDb.open( './ord.db' )

puts
puts "  #{Inscribe.count} inscribe(s)"
puts "  #{Blob.count} blob(s)"



NODE_PUNKS = []

# limit = 100
# Inscribe.order( :num ).limit( limit ).each do |inscribe|

###
##  8:23 PM Central / 9:23 PM Eastern on 12/3/23
##  I took the screenshot before it loaded
##    8:20 pm =>  2023/12/04 02:20 
##
## block 819665  -2023-12-04 02:13:02 UTC
##      - first inscription num. -> 45910612


=begin
## delete "front-runners" - no "front-runners" found
Inscribe.order( :num ).where( 'num < 45910612' ).each do |inscribe|

    if File.exist?( "./punks/#{inscribe.num}.png" )
       puts "!! deleting punk #{inscribe.num}"  
    elsif File.exist?( "./other/#{inscribe.num}.png" )
       ## skip
    else  ## download and image check
    end
end
=end



Inscribe.order( :num ).each do |inscribe|

   if File.exist?( "./punks/#{inscribe.num}.png" )
      NODE_PUNKS << inscribe.num  
   elsif File.exist?( "./other/#{inscribe.num}.png" )
      ## skip
   else  ## download and image check
  content = Ordinals.content( inscribe.id )
  ## pp content

  image_hash = Digest::SHA256.hexdigest( content.data )
  pp image_hash

  punk_nums = HASHES[ image_hash ]

  if punk_nums
     puts " bingo!!"
     write_blob( "./punks/#{inscribe.num}.png", content.data)
     NODE_PUNKS << inscribe.num
  else
     puts "    x(num)"
    write_blob( "./other/#{inscribe.num}.png", content.data)
  end
end
end


pp NODE_PUNKS
puts "   #{NODE_PUNKS.size} punk(s)"

puts "bye"
