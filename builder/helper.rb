################
# (view) helpers


def spritesheet( path )  ## spritesheet metadata / record helpers
  recs = read_csv( path )

###
# id, category, name, more_names
# 0, , classic,
# 1, , dark,
# 2, , zombie,

##
# id, name, gender, size, type, more_names
# 0, Male 1, m, l, Archetype,
# 1, Male 2, m, l, Archetype,
# 2, Male 3, m, l, Archetype,


  buf = String.new('')
  buf << "id, name\n"
  
  recs.each do |rec|
    id         =  rec['id']
    name       =  rec['name']
    more_names = (rec['more_names'] || '').split( '|' )

    names = [name]
    names += more_names

    buf << "#{id}, #{names.join(' | ')}\n"
  end

  buf
end




def render_options( spec )

  buf = String.new('')

  spec.each do |name, h|

    options = h[:options]
    options = ['None'] + options   if h[:none]

    legend = h[:legend]

    buf += radio_options_w_sprites( options,
                                      name:    name,
                                      legend:  legend )


    buf += "\n#{h[:notes]}\n\n"    if h[:notes]
  end

  buf
end




def radio_button_tag( name, value, checked: false, id: )
  buf = %Q[  <input type="radio" id="#{id}" name="#{name}" value="#{value}" ]
  buf += " checked "   if checked
  buf += ">\n"
  buf
end

def label_tag( content, id: )
  %Q[    <label for="#{id}">#{content}</label>\n]
end

def sprite_tag( name )
  %Q[    <span class="sprite" data-name="#{name}"></span>\n]
end




def radio_options_w_sprites( options, name:, legend: )
   radio_options( options, name: name,
                           legend: legend,
                           sprites: true )
end


def radio_options( options, name:,
                            legend:,
                            sprites: false )

buf = <<TXT
<fieldset>
<legend>#{legend}:</legend>
TXT

options.each_with_index do |option,i|

  value = option.downcase.strip

  label = option
  id    = "#{name}#{i}"    ## use for input (dom) id / label for [id]


  ## note. add class columns - via css turns div into 250px inline-blocks
buf += "<div class='columns'>\n"
buf +=  radio_button_tag( name, value,
                          id: id,
                          checked: i==0  )

buf2 = String.new( '' )
if sprites
  if ['none'].include?( value )
    ## do nothing  - no sprite(s) - for none & friends
  else
    buf2 +=  sprite_tag( value )
  end
  ## note: add sprites (spans) inside label e.g. <label> HERE </label>
  buf += label_tag( buf2 + label, id: id )
else
  buf += label_tag( label, id: id )
end

buf += "</div>\n"
end


buf += "</fieldset>\n"
buf

end

