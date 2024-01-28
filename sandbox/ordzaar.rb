require 'cocos'

require 'digest'

$LOAD_PATH.unshift( "../pixelart/ordbase/ordinals/lib" )
require 'ordinals'
require 'ordlite'
require 'date'


require_relative 'base'    ## build HASHES lookup/table


## check overflows / duplicates?
pp HASHES[ '039edaa18a7f12e08ea311b9015661a707ac020b4557f810fad6ab65120c2bd0' ]
# => [1506] -  ???




OrdDb.open( './ord.db' )

puts
puts "  #{Inscribe.count} inscribe(s)"
puts "  #{Blob.count} blob(s)"



data = read_json( "./ordzaar/inscriptions.json")

puts "  #{data.size} record(s)"
#=>  4659 record(s)

## Node Punk #1
ORDZAAR_NUM_RX = /\ANode Punks? #(?<num>[0-9]+)\z/
 
def ordzaar_num( str )
     if m=ORDZAAR_NUM_RX.match( str )
        m[:num].to_i(10)    ## use base 10
     else
        puts "!! ERROR - no match; no number found in >#{str}<"
        exit 1   ## not found - raise exception - why? why not?
     end
end
 

mapping = []

errors = []


missing_count = 0

## try to match nums
data.each_with_index do |meta,i|
    id = meta['id']

    # "meta": { "name": "Node Punk #1" }
    name = meta['meta']['name']
    ordzaar_num = ordzaar_num( name )

  ## not yet indexed??
  next if [ 
    'a868a3ce3f34d75ca8233ece91a66026a31ad1fefc9dddee4c10f2c417392d68i0', # 20.0 sat/vB - 6080 sat       
    'eed23ab0bf1c8c234c24aed51bac6d990c19a6d4df5b897e1ac4fc95d79baebfi0', # 20.0 sat/vB - 5900 sat
  ].include?( id )


=begin  
      'db8d83d1ee95ade2cb1e4a0b4fbc98815823ec3b0ef21389118621677252f403i0', # 40.1 sat/vB - 12920 sat 
      '11bb6f5cd1de5cbdd362af9f5c5ffb62d78b2f1f56a194a3ca5d5f46d362fc62i0', # 30.1 sat/vB - 9180 sat
      'efd6d0505866348585e509319c17e3c6b781eea1eb1ce3bc172e22ef0365b165i0', # 30.0 sat/vB - 9030 sat  
      '796756df91c3ef2e63ad69b47474498dbc8864cfac00e319993d452f02b060eei0', # 30.0 sat/vB - 10170 sat 
      'c9db4f4272ba445e3c7c74c9e06671cf9f1537b499025b595e65ec589de7035ci0', # 30.0 sat/vB - 8910 sat 
      '54c08bc056dcbfe8444930689340f6136d0475c0cc55191778016c897dfad8c0i0', # 40.0 sat/vB - 12680 sat 
      '480641211872559317880c8cb44d05db7405f332fb94205edac6eb992f604dffi0',
      'bb4125806f6043be5a91f6b2a1410c4faf84080546ec576d1f1448b054b4952bi0',
      '56fcb73cd05953324200516aa4954eeacc790ba23f821c9b8bfb4cb66fc4ef5ci0',
      'a4c7e3832ccfada87e0629903fc1b3ef91369951316056bf0ae56afca4834da9i0',
      'c942a2e78b88c05792089861d0cc2351aacada1582f8e2a4b9f1d6364eab7663i0',
      '2e4f9da503db5d24d7366a35f7f34b2fc4ff99108f68c612935aa509c6b404f9i0',
=end

    puts "==> #{i+1} / #{data.size}"
    inscribe = Inscribe.find_by( id: id )
    if inscribe
      puts "  #{inscribe.num}"

      ## check for image
      path = "./punks/#{inscribe.num}.png"
      blob = if File.exist?( path )
                  read_blob( path )  
             else  ## download and image check
                content = Ordinals.content( inscribe.id )
                ## pp content
                write_blob( "./punks/#{inscribe.num}.png", content.data )
                content.data
             end

      image_hash = Digest::SHA256.hexdigest( blob )
      pp image_hash
   
      punk_nums = HASHES[ image_hash ]
      pp punk_nums
   
      if punk_nums.empty?
         puts "!! overflow - pirate / frontrunning mint ??"

         errors << "!! overflow (duplicate) - pirate / frontrunning mint @ #{inscribe.num}"
         next
      end
   
      ### mapping << [ inscribe.num, punk_nums.shift ]
      ## quick hack - always use first ref
      mapping << [ inscribe.num, ordzaar_num, punk_nums[0] ]
    else
      puts " !!! missing #{id}"
      meta_api = Ordinals.inscription( id )
      Inscribe.create!( Inscribe._parse_api( meta_api ))
      missing_count += 1
    end
end


pp mapping
puts "   #{mapping.size} punk(s)"


## sort by num
mapping = mapping.sort {|l,r| l[0] <=> r[0] }

headers = ['num', 'ordzaar', 'ref']
buf = ""
buf << headers.join( ', ' )
buf << "\n"
mapping.each do |values|
   buf << values.join( ', ' )
   buf << "\n"
end 

write_text( "mint.csv", buf)


puts "  #{missing_count} missing count"


pp errors


puts "bye"