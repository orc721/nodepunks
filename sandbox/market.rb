$LOAD_PATH.unshift( "../pixelart/ordbase/ordinals/lib" )
require 'ordinals'
require 'ordlite'
require 'date'

OrdDb.open( './ord.db' )

puts
puts "  #{Inscribe.count} inscribe(s)"
puts "  #{Blob.count} blob(s)"



recs = read_csv( './mint.csv' )
puts "  #{recs.size} record(s)"

meta = read_csv( '../welovepunks/welovepunks.csv' )
puts "  #{meta.size} meta record(s)"


data = []

recs = recs.sort { |l,r|  l['ordzaar'].to_i <=> r['ordzaar'].to_i }

recs.each do |rec|
    num     = rec['num'].to_i
    ref     = rec['ref'].to_i
    ordzaar = rec['ordzaar'].to_i

    inscribe = Inscribe.find_by( num: num )

    spec = meta[ ref ]
    background = spec['background']
    type       = spec['type']
    accessories = (spec['accessories'] || '').split( '/' ).map {|acc| acc.strip }
 
    attributes = []
    attributes << { 'trait_type' => 'type',
                    'value'      => type }
    accessories.each do |acc|   ## change name to attribute (from accessory)
        attributes << { 'trait_type' => 'attribute',
                        'value'      => acc } 
    end
    attributes <<  { 'trait_type' => 'attribute count',
                     'value' => accessories.size.to_s }  ## number (type) possible?
    attributes <<  { 'trait_type' => 'background',
                     'value' =>  background }
 

    data << {
               'id' => inscribe.id,
               'meta' => {
                 'name' => "Node Punk \##{ordzaar}",
                 'attributes' => attributes
                }
            }
end


write_json( "inscriptions.json", data )

puts "bye"

