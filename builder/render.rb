require 'cocos'
require 'erb'

require_relative 'punk'
require_relative 'helper'



puts "punk config:"
pp PUNK



html = read_text( "./punk.html.erb" )
puts html

tmpl = ERB.new( html )
buf = tmpl.result

puts 
puts "---"
puts buf


write_text( "./tmp/index.html", buf )

puts "bye"
