##
# Ordapi.xyz 2023 | Privacy Policy | ordapi AT benchlabs.xyz | 
# donate:  bc1q4cgsxlk07hzgegrc54mpsqvv9jk5rh68e9y4cq

##
## progress
##   offset at 62520  of total 188_161 (check if total increases?)
##             30600  of total 191_619


###
# try hiro api
#  see https://docs.hiro.so/ordinals/introduction

##  "max_inscription_number"=>46080354, !!!!

##                            46084353
##                             191619

# https://api.hiro.so/ordinals/v1/inscriptions?from_number=46051102
## {"limit":20,"offset":0,"total":31653
## https://api.hiro.so/ordinals/v1/inscriptions?from_number=46051102&mime_type=image%2Fpng
## {"limit":20,"offset":0,"total":15,

## {"limit":20,"offset":0,"total":46_310_809,

## https://api.hiro.so/ordinals/v1/inscriptions?mime_type=image%2Fpng
## {"limit":20,"offset":0,"total":877153,"results


# https://api.hiro.so/ordinals/v1/inscriptions?mime_type=image%2Fpng&from_number=45926920
#
#  {"limit":20,"offset":0,"total":2582,"results":
#  {"limit":20,"offset":20,"total":2582,"results



$LOAD_PATH.unshift( "../pixelart/ordbase/ordinals/lib" )
require 'ordinals'
require 'ordlite'
require 'date'

OrdDb.open( './ord.db' )

puts
puts "  #{Inscribe.count} inscribe(s)"
puts "  #{Blob.count} blob(s)"


##
##  If your rate limits fall under 50 RPM, 
##  and you prefer unauthenticated access, 
## no further action is required. 



require 'webclient'

url = 'https://api.hiro.so/ordinals/v1/' 
=begin
{"server_version"=>"ordinals-api v2.0.1-beta.2 (beta:0692f02)",
 "status"=>"ready",
 "block_height"=>819782,
 "max_inscription_number"=>46080354,
 "max_cursed_inscription_number"=>-228015}
=end

module Hiro
def self.list_pngs( from_number:, offset: nil )

    url = 'https://api.hiro.so/ordinals/v1/inscriptions'

    url += "?from_number=#{from_number}"   ## '?from_number=45926920'
    ## url += '&mime_type=image%2Fpng'
    url += "&offset=#{offset}"  if offset
    ## url += "&order=desc"
    url += "&order=asc"   ### lowest numbers first!!!
    url += "&order_by=number"
    url += '&limit=60'   ## max. limit is 60
    # from_number = 45926920
    # ?mime_type=image%2Fpng

    res = nil
    loop do 
      res = Webclient.get( url )

      ## !! ERROR - 429 - Too Many Requests
      if res.status.code == 429
         puts "!! too many requests"
         puts "   sleep 10 secs"
         sleep( 11 )
      ##   522: Connection timed out
      elsif res.status.code == 522
         puts "!! connection timed out"
         puts "   sleep 10 secs"
         sleep( 11 )
      else
         break
      end
    end        

    if res.text.index( "{")
      data = res.json
      data
    else
        puts res.text
        puts "!! ERROR - #{res.status.code} - #{res.status.message}"
        exit 1
    end
end
end  # module Hiro


## pp Hiro.list_pngs( from_number:  45953257 )  #  46082718 )


def _parse_api( data )   ## parse api json data
    ## num via title
    attributes = {
     id:  data['id'],
     num: data['number'],
     bytes: data['content_length'], 
     sat:  data['sat_ordinal'],
     content_type:  data['content_type'],
     block: data['genesis_block_height'],
     fee: data['genesis_fee'].to_i(10),
     tx: data['genesis_tx_id'],
     address: data['address'],
     output: data['output'],
     value: data['value'].to_i(10),
     offset: data['offset'].to_i(10),
     # "2023-06-01 05:00:57 UTC"
     date:  Time.at( data['timestamp'] ).utc.to_datetime, 
   }
 
   attributes
 end
 

def _import_inscribe( data )
    Inscribe.create!( _parse_api( data ))
end




def import( from_number: nil, offset: nil )

=begin    
    if from_number.nil?
     from_number =  if Inscribe.count > 0 
                      Inscribe.maximum( :num )+1 
                   else 
                       45926920 
                   end
    end
=end

    puts "==> from_number #{from_number}..."


# {"limit"=>20, "offset"=>0, "total"=>0, "results"=>[]}
# 
delay_in_s = 1  # 0.5 

    min_num = 999999999999
    max_num = 0
    text_count = 0
    image_count = 0
    png_count = 0


    loop do
      data =  Hiro.list_pngs( from_number: from_number, 
                              offset: offset )

      if data.has_key?('results')
        puts "  #{data['results'].size} result(s)"

        print "limit: ", data["limit"]
        print " offset: ", data["offset"]
        print " total: ",  data["total"]
        print "\n"
      else
         pp data
         puts "!! ERROR ???"
         puts "  sleeping in #{delay_in_s}s..."   
         sleep( delay_in_s )
         next
      end

      if data['results'].size == 0
        pp data
         from_number += 60
         puts "  sleeping in #{delay_in_s}s..."   
         sleep( delay_in_s )
         next
      end


      data['results'].each do |h|
         num            = h['number']
         content_type   = h['content_type']
         content_length = h['content_length']
 
         min_num = min_num > num ? num : min_num
         max_num = max_num < num ? num : max_num
       
         text_count  += 1  if content_type.downcase.start_with?( 'text/' ) 
         image_count += 1  if content_type.downcase.start_with?( 'image/' )
     

         if content_type.downcase.start_with?( 'image/png' ) &&
            content_length <= 372
            print " #{num}(#{content_length}b)"

            inscribe = Inscribe.find_by( num: num )
            if inscribe  ## already in db; dump record
              ## pp inscribe
            else         ## fetch via ordinals.com api and update db
                _import_inscribe( h )
            end

            png_count += 1
         else
            print " x(#{num})"
         end
       end
       print "\n"

    ## from_number = data['results'][-1]['number']
     offset = offset ? offset+60 : 60   
     puts " new offset: #{offset}"

     puts "  min: #{min_num}, max: #{max_num}"
     puts "  text: #{text_count}, image: #{image_count} (png: #{png_count})"
   
     puts "  sleeping in #{delay_in_s}s..."   
    sleep( delay_in_s )
   end
end


## start at  block?
##  https://www.ord.io/45926920

## from number - 45926920

##  from_number: 46092858

##  new offset: 97560
##  new offset: 162480
##   min: 46024480, max: 46089399
##
##  new offset: 166320
##   min: 46089400, max: 46093239

#
# limit: 60 offset: 252180 total: 316672

# limit: 60 offset: 251940 total: 315738
#  new offset: 252000


###
##  8:23 PM Central / 9:23 PM Eastern on 12/3/23
##  I took the screenshot before it loaded
##    8:20 pm =>  2023/12/04 03:30 
##
## block 819675 - 2023-12-04 03:24:04 UTC
##     - first inscription num. ->  45938348

##
## latest run
##   limit: 60 offset: 311700  ==> total: 355193
##                             ==> total: 385898
##
## latest run
##  limit: 60  offset: 384000  ==> total: 506064
##  ---
## limit: 60 offset: 432600 total: 513936
##       new offset: 432660


import( from_number: 45926920, offset: 384000 )  #, offset: 63300 ) # +600+1320 )


puts "bye"



__END__

{"limit"=>20,
 "offset"=>0,
 "total"=>2582,
 "results"=>
  [
    {"id"=>"378eb6f37542cfa1b5d585e101ab1d79ed165f1f2dfe3e93668c50d985c2e066i0",
    "number"=>46078217,
    "address"=>"bc1prjss8xgh0alyg8gglrpyth6zahja049q8ppvnar8qfm3ulwkfvnqwlt5z8",
    "genesis_address"=>"bc1prjss8xgh0alyg8gglrpyth6zahja049q8ppvnar8qfm3ulwkfvnqwlt5z8",
    "genesis_block_height"=>819773,
    "genesis_block_hash"=>"00000000000000000002175ab04075c3ddb732d6bc9451c9c10ae9c7f87dc6fc",
    "genesis_tx_id"=>"378eb6f37542cfa1b5d585e101ab1d79ed165f1f2dfe3e93668c50d985c2e066",
    "genesis_fee"=>"34650",
    "genesis_timestamp"=>1701718461000,
    "tx_id"=>"378eb6f37542cfa1b5d585e101ab1d79ed165f1f2dfe3e93668c50d985c2e066",
    "location"=>"378eb6f37542cfa1b5d585e101ab1d79ed165f1f2dfe3e93668c50d985c2e066:0:0",
    "output"=>"378eb6f37542cfa1b5d585e101ab1d79ed165f1f2dfe3e93668c50d985c2e066:0",
    "value"=>"546",
    "offset"=>"0",
    "sat_ordinal"=>"196673406872628",
    "sat_rarity"=>"common",
    "sat_coinbase_height"=>39334,
    "mime_type"=>"image/png",
    "content_type"=>"image/png",
    "content_length"=>261,
    "timestamp"=>1701718461000,
    "curse_type"=>nil,
    "recursive"=>false,
    "recursion_refs"=>nil},
   {"id"=>"3b74c470cf72f7ff48d4c27e775ce276b35a79be6fdc92493b51df52cf6a26edi0",
    "number"=>46074700,
    "address"=>"bc1phl0qu4g3ttlg2fsxq8qg8k8369q7yrldyjz0qhmgvq33pqgl30uqcaszws",
    "genesis_address"=>"bc1phl0qu4g3ttlg2fsxq8qg8k8369q7yrldyjz0qhmgvq33pqgl30uqcaszws",
    "genesis_block_height"=>819763,
    "genesis_block_hash"=>"000000000000000000020fb5a16766e93872074b5376c4117f08d747c761cc8c",
    "genesis_tx_id"=>"3b74c470cf72f7ff48d4c27e775ce276b35a79be6fdc92493b51df52cf6a26ed",
    "genesis_fee"=>"15318",
    "genesis_timestamp"=>1701704808000,
    "tx_id"=>"09bcacbdda675b912f62d15630084d8a3dca09807e6941e4a54483cc24b7da98",
    "location"=>"09bcacbdda675b912f62d15630084d8a3dca09807e6941e4a54483cc24b7da98:0:0",
    "output"=>"09bcacbdda675b912f62d15630084d8a3dca09807e6941e4a54483cc24b7da98:0",
    "value"=>"1000",
    "offset"=>"0",
    "sat_ordinal"=>"1629449114504054",
    "sat_rarity"=>"common",
    "sat_coinbase_height"=>463559,
    "mime_type"=>"image/png",
    "content_type"=>"image/png",
    "content_length"=>268,
    "timestamp"=>1701704808000,
    "curse_type"=>nil,
    "recursive"=>false,
    "recursion_refs"=>nil},
