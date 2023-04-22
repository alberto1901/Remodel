


  def parse_obj
      v_cnt, f_cnt, n_cnt, t_cnt = 0, 0, 0, 0

      current_material = String.new
      current_group    = String.new

      @mdl_source.each { |line|
          line = line.strip

         case line
            when /^mtllib\s+(.+)/
               @mdl_matlibs.push $1
               parse_obj_materials($1)
            when /^usemtl\s+(.+)/
#               @mdl_materials.push Material.new($1)
               current_material = @mdl_materials[$1]
            when /^g\s+(.+)$/
               @mdl_groups.push $1
               current_group = $1
	    when /^vt\s+(.+)\s+(.+)/        #create a new texture coordinate
	       @mdl_uv_coords.push Uv_coord.new(t_cnt, $1, $2)
	       t_cnt = t_cnt + 1
	    when /^vn\s+(.+)\s+(.+)\s+(.+)/   #create a new face normal
	       @mdl_normals.push Normal.new(n_cnt, $1, $2, $3)
	       n_cnt = n_cnt + 1
	    when /^v\s+(.+)\s+(.+)\s+(.+)/     #create a new vertex
	       @mdl_vertices.push Vertex.new(v_cnt, $1, $2, $3)
	       v_cnt = v_cnt + 1
	    when /^f\s+(.+)$/              #create a new face
	       face_vertices       = Array.new
	       face_uv_indices     = Array.new
	       face_normal_indices = Array.new
	       verts = $1
              #some models will have Vertex/UV_coord/Normal info
#	       if verts =~ /[^\d\s]/
         temp = verts.split(/\s+/)
         temp.each{ |v|
              (vert, uv, norm) = v.split("/")
			        face_vertices.push(vert.to_i - 1)     #obj uses 1-based lists. Our format is 0-based, thus the -1 on indices for V, UV and N
				#puts "VERT: #{vert}"
			        face_uv_indices.push(uv.to_i - 1)
				#puts "UV: #{uv}"
              face_normal_indices.push(norm.to_i - 1)
				#puts "NORM: #{norm}\n\n"
         } #if
               #create the face object
         @mdl_faces.push Face.new(f_cnt,                #index of face within object
                                  face_vertices,        #array of vert indices
                                  current_group,        #name of current group
                                  current_material,     #name of current material
                                  face_uv_indices,      #array of uv indices
                                  face_normal_indices   #array of normal indices
                                 )
	       f_cnt = f_cnt + 1
	 end #case      

     }	 
  end #parse_obj

  def parse_obj_materials(matlib)
       @material_library = matlib

  
   if File.exists?(File.dirname(@mdl_filename) +"/"+ @material_library)
       @material_source = File.open(File.dirname(@mdl_filename) +"/"+ @material_library, "r")
   else
       return
   end
#puts "opening: #{matlib}"
       #The following are likely to be found in an obj.mtl file. There are other attributes not listed here.
       #newmtl blinder_r_auv
       #Ns 100.000                            --shininess ? to ?
       #d 1.00000                             --transparency 0 (transparent) to 1 (not-transparent)
       #Tr 1.00000                            --transparency 0 (transparent) to 1 (not-transparent)
       #illum 2                               --illumination 1 indicates a flat material with no specular highlights, so the value of Ks is not used. illum = 2 denotes the presence of specular highlights, and so a specification for Ks is required.
       #Kd 1.00000 1.00000 1.00000            --diffuse rgb
       #Ka 1.00000 1.00000 1.00000            --ambient rgb
       #Ks 1.00000 1.00000 1.00000            --specular rgb
       #Ke 0.00000e+0 0.00000e+0 0.00000e+0   --emissive rgb
       #map_Kd verticals.png                  --texture name
       #Tf 1.0 1.0 1.0                        --yet another transparency but using floats 
       #sharpness = 0.0
       #map_Ka
       #map_Kd
       #map_Ks
       #map_Ke
       #map_Ns
       #map_d
       #map_Bump
       #density = 1.0 

       material_name = String.new
       @material_source.each { |line|
          line = line.strip
          case line

             when /^newmtl (.+)/
                     material_name = $1
                     @mdl_materials[material_name] = Material.new($1)
             when /^Ns (.+)/
                     @mdl_materials[material_name].shininess = $1
             when /^[d|Tr] (.+)/
                     @mdl_materials[material_name].transparency = $1
             when /^illum (.+)/
                     @mdl_materials[material_name].illumination = $1
             when /^Kd (.+) (.+) (.+)/
                     @mdl_materials[material_name].diffuse_rgb = Array[$1, $2, $3]
             when /^Ka (.+) (.+) (.+)/
                     @mdl_materials[material_name].ambient_rgb = Array[$1, $2, $3]
             when /^Ks (.+) (.+) (.+)/
                     @mdl_materials[material_name].specular_rgb = Array[$1, $2, $3]
             when /^Ke (.+) (.+) (.+)/
                     @mdl_materials[material_name].emissive_rgb = Array[$1, $2, $3]
             when /^map_Kd (.+)/
                     @mdl_materials[material_name].texture_file = $1
          end #case
       } #end of each line

  end #material_attributes




  def save_obj(model, destination)

	destination.write"#Exported from obj2ac.rb\n"
	@mdl_matlibs.each{|matlib|
			  destination.write"mtllib #{matlib}\n"
	}
	
	@mdl_vertices.each{|vertex|
			   destination.write"v #{vertex.x} #{vertex.y} #{vertex.z}\n"
	}

	@mdl_uv_coords.each{|uv_coord|
			   destination.write"vt #{uv_coord.u} #{uv_coord.v}\n"
	}

	@mdl_normals.each{|normal|
			   destination.write"vn #{normal.x} #{normal.y}  #{normal.z}\n"
	}

	current_group = String.new
	current_material = String.new

	model.mdl_faces.each {|face|

			if face.group != current_group
				destination.write"g #{face.group}\n"
				current_group = face.group
			end

			if face.material != current_material
				destination.write"usemtl #{face.material}\n"
				current_material = face.material
			end

                        v_cnt = 0
			destination.write"f "
			face.vertices.each {|vertex|
				destination.write"#{vertex.to_i + 1}/"
				 if face.uv_coord_index[v_cnt] != nil then destination.write"#{face.uv_coord_index[v_cnt].to_i + 1}" end
				destination.write"/"
				 if face.normal_index[v_cnt] != nil then destination.write"#{face.normal_index[v_cnt].to_i + 1}" end
				destination.write" "
                        	v_cnt = v_cnt + 1
			}
			destination.write"\n"
	}
  end #end of save_obj method



