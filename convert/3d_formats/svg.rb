
#exports UV coordinates to SVG document
  def save_svg(model, destination)
    $log.info "Converting model to SVG"
    svg_contents = String.new

#svg variables 
#      @mdl_scale_factor
#      @mdl_printable_x 
#      @mdl_printable_y 
#      @mdl_fill        
#      @mdl_fill_opacity
#      @mdl_stroke           
#      @mdl_stroke_opacity
  $log.info "...validating user request values"
  #set default page size to in if not already set in svg acceptable units
    if !( @mdl_printable_x.match(/[em|ex|px|pt|pc|cm|mm|in]$/i) ) then
      @mdl_printable_x << 'in'
    end
    if !( @mdl_printable_y.match(/[em|ex|px|pt|pc|cm|mm|in]$/i) ) then
      @mdl_printable_y << 'in'
    end
    if !( @mdl_scale_factor.match(/^[0-9\.]+$/) ) then
      @mdl_scale_factor = 629.4
    end
    if !( @mdl_fill_opacity.match(/^[0-9\.]+$/) ) then
      @mdl_fill_opacity = 1
    end
    if !( @mdl_stroke_opacity.match(/^[0-9\.]+$/) ) then
      @mdl_stroke_opacity = 1
    end
#    if !( @mdl_fill.match(/^[none|diffuse|specular|black]$/) ) then
#      @mdl_fill = 'none'
#    end
#    if !( @mdl_stroke.match(/^[none|diffuse|specular|black]$/) ) then
#      @mdl_stroke = 'diffuse'
#    end

  #define the SVG document size
  #UV coordinates are from 0.0 to 1.0. They must be scaled to a page size. Use 500 for now until sizing issues are addressed
#  (width, length, scale_factor) = ["8.5in", "11in", 629.4]  #629.4 generates SVG sizes equal to Wings units, eg, a 2 sized cube in Wings generates 2 inch squares in SVG.

  #open the SVG document
  $log.info "...beginning SVG content"

	svg_contents << %Q~<?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <svg xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  width="#{@mdl_printable_x}"
  height="#{@mdl_printable_y}">\n\n~

  #write out the document properties
  $log.info "...writing SVG metadata"
  svg_contents << svg_metadata(model)

  #convert OBJ materials to SVG styles and write out the styles to SVG doc 
  $log.info "...writing SVG styles"
  svg_contents << svg_styles(model)
	

	current_group    = String.new  #groups define the objects in the model file
  current_class    = String.new  #classes are used to apply model materials (color) to SVG polygons
  group_listing    = Hash.new    #used to create an index of all model objects written out as SVG groups
  screen_resolution = 90         #moving svg groups to bottom of viewable page depends upon viewer's screen resolution. This is a best guess when using inch page sizes.

  $log.info "...parsing model faces"
  f_cnt, g_cnt = 0, 0
  label_x = String.new
  label_y = String.new
  label_text = String.new
  max_x, min_x, max_y, min_y = nil, nil, nil, nil

	model.mdl_faces.each {|face|

    f_cnt = f_cnt + 1

      #weed out any polygons with 'ignore' material applied
      if face.material.to_s.match(/ignore/i) then 
        $log.warn ".........ignoring face with ignore material"
        next 
      end

			if face.group != current_group then

        #end the previous group element
        if current_group.to_s != '' then 
          $log.info ".........parsing #{current_group} faces"
          g_cnt = g_cnt + 1

          #add the group name label at the center of the group if user has requested it
          if @mdl_use_labels.to_s.match(/use_labels/) then
            svg_contents << label(current_group, max_x, min_x, max_y, min_y)
            max_x, min_x, max_y, min_y = nil, nil, nil, nil
          end
         
          svg_contents << "</g>\n" 
        end

        #start the new group element
        $log.info "......found a new group:#{face.group}"

				svg_contents << %Q~<g id="#{face.group}" transform="translate(0,#{ @mdl_printable_y.gsub(/[^0-9\.]/,'').to_f * screen_resolution} )"~
				current_group = face.group
        
        
        #is there a material assigned to the group?
			  if face.material.to_s != '' then current_class = "class=\"#{face.material}\""
          else  current_class = "class=\"default\""
			  end
        svg_contents << ">"

        #add the group name to the group listing hash with the current class as the value
        group_listing[current_group] = current_class

      end  #end new face group

      #write out the face UV coordinates as an SVG polygon
      v_cnt = 0

      if defined? @mdl_uv_coords[face.uv_coord_index[v_cnt].to_i].u then
        $log.debug "......new polygon defined"
        #begin the polygon element
			  svg_contents << "<polygon id=\"#{face.group}-#{f_cnt}\" class=\"#{face.material}\" points=\""

        #loop through each vertex in the face.
        #if the vertex has UV coordinates, 
        #scale the coord by the scale factor, 
        #flip the V coordinate -- (* -1) -- UV origin is lower left and goes up, SVG origin is upper left and goes down 
        #write the pair of UV coords to the SVG document as a point in the current polygon 
        $log.debug "......parsing face vertices"
			  face.vertices.each {|vertex|
				  if face.uv_coord_index[v_cnt] != nil then # and @mdl_uv_coords[face.uv_coord_index[v_cnt]] != nil then 
            v_x = @mdl_scale_factor.to_f * @mdl_uv_coords[face.uv_coord_index[v_cnt].to_i].u
            v_y = @mdl_scale_factor.to_f * @mdl_uv_coords[face.uv_coord_index[v_cnt].to_i].v * -1
            svg_contents << "#{v_x},#{v_y} " 

            #find maximum x and minimum x for location of group label
            max_x = v_x if max_x.nil? or v_x > max_x
            min_x = v_x if min_x.nil? or v_x < min_x

            max_y = v_y if max_y.nil? or v_y > max_y
            min_y = v_y if min_y.nil? or v_y < min_y

          end #index != nil

     	    v_cnt = v_cnt + 1
       } #end vertices.each

       #close the polygon element
			 svg_contents << "\" />\n"
      end #if defined
  } #end faces.each

  if f_cnt > 0 then
    #add the last group name label at the center of the group if user has requested it
    if @mdl_use_labels.to_s.match(/use_labels/) then
      svg_contents << label(current_group, max_x, min_x, max_y, min_y)
    end
    #close the last group
  else
    $log.warn "......NO UV COORDINATES IN THIS MODEL"
    svg_contents << %Q~<g><text>No faces with UV coordinates found in this model</text>~
  end

    svg_contents << "</g>"
  $log.info "...Finished processing faces"
  $log.info "...#{f_cnt} faces in #{g_cnt + 1} groups"
  $log.info "...Writing the list of groups"

  #write the group listing to use as a part index in the SVG document
  svg_contents << "<g id=\"part listing\"><text><tspan x=\"20px\" y=\"20px\" style=\"font-size:14pt;text-weight:bold;text-decoration:underline;\">Inventory of #{File.basename(@mdl_destination)}</tspan>"
  y = 35         #vertical position of text line
  x = 30         #horizontal position of text line
  Hash[group_listing.sort].each {|key, value| 
    svg_contents << "<tspan x=\"#{x}px\" y=\"#{y = y.to_i + 15}px\" #{value}>#{key}</tspan>\n"
  }
  svg_contents << "</text></g>"

  $log.info "...Closing the svg element"
  #close the svg document
  svg_contents << "</svg>\n"

  $log.info "Saving to the svg file"
  destination.write(svg_contents)
  end #end of save_svg method



  def label(label_text, max_x, min_x, max_y, min_y, *id)
    
      #if an id is not passed in use the text as id
      id[0] = label_text if id[0].nil?

      #print the name of the face group 
      label_x = (max_x.to_f + min_x.to_f)/2 
           
      label_y = (max_y.to_f + min_y.to_f)/2 

      $log.info "......creating label for #{id[0]} at #{label_x}, #{label_y}"
          
      #return group name label at the center of the group
      label = %Q~<text id="label_#{id[0]}" x="#{label_x}" y="#{label_y}" alignment-baseline="middle" text-anchor="middle">#{label_text}</text>~
      
      return label
  end #label




#############################################################
# STYLES

  #svg styles. Returns all the model materials in as svg style tag
  def svg_styles(model)
    
    materials = String.new()
    materials << "<style type=\"text/css\" >\n<![CDATA[\nsvg{background-color:white;}\ntext{font-family:Verdana;font-size:18;fill:black;}"

    if @mdl_materials.to_s != ''
			model.mdl_materials.each { |key, value|
			#@@material_order[key] = material_index
      
      $log.info "......creating style: #{key}"

      #polygon styles based on diffuse|specular|none|black selected by user in web interface
      materials << "\npolygon.#{key}{fill-opacity:#{@mdl_fill_opacity};fill:"
      if key.match(/ignore/i) then   #ANY material named 'ignore' should show up in red as a warning
        materials << "red"
      elsif @mdl_fill.to_s.match(/diffuse/i) then
         materials << "rgb("
         value.diffuse_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");"
      elsif @mdl_fill.to_s.match(/specular/i) then
         materials << "rgb("
         value.specular_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");"
      elsif @mdl_fill.to_s.match(/black/i) then
        materials << 'black;'
      else 
        materials << 'none;'
      end

      #add the stroke styling
      materials << "stroke-width:0.5px;stroke-opacity:#{@mdl_stroke_opacity};stroke:"
      if @mdl_stroke.to_s.match(/diffuse/i) then
         materials << "rgb("
         value.diffuse_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");}"
      elsif @mdl_stroke.to_s.match(/specular/i) then
         materials << "rgb("
         value.specular_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");}"
      elsif @mdl_stroke.to_s.match(/black/i) then
         materials << "black;}"
      else 
        materials << "none;}\n\n"
      end
      materials.gsub!(', )',')')

      #matching text styles for index listing
      materials << "\ntspan.#{key}{font-size:12;stroke:black;stroke-width:0.3px;fill:"
      if @mdl_fill.to_s.match(/diffuse/i) then
         materials << "rgb("
         value.diffuse_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");}"
      elsif @mdl_fill.to_s.match(/specular/i) then
         materials << "rgb("
         value.specular_rgb.each{ |v| materials << "#{v.to_f * 100}\%, "}
         materials << ");}"
      else 
        materials << "black;}\n\n"
      end
      materials.gsub!(', )',')')
		}
	end

  materials << "]]>\n</style>\n\n"
	return materials
end #of svg_styles



def svg_metadata(model)
require 'etc' #used to retrieve username

return %Q~<title
     id="title4229">#{model.mdl_dest_file}</title>
  <metadata
     id="metadata100">
    <rdf:RDF>
      <dc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title>#{model.mdl_dest_file}</dc:title>
        <dc:date>#{Time.now}</dc:date>
        <dc:creator>
          <dc:Agent>
            <dc:title>#{Etc.getlogin}</dc:title>
          </dc:Agent>
        </dc:creator>
        <dc:source>#{model.mdl_filename}</dc:source>
        <dc:description>This SVG document was created by extracting the UV coordinates from #{model.mdl_filename} and converting them to SVG. The conversion software was written by Jeffery S. Koppe.</dc:description>
      </dc:Work>
    </rdf:RDF>
  </metadata>
~
end #metadata

