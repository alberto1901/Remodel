#!/usr/bin/env ruby

#AC3D format refers to materials by index numbers, not names, so we must store the order in which we write the material definitions
$material_order = Hash.new()


def save_ac(model, destination)

	destination.write"AC3Db\n"
	destination.write(ac3d_materials(model))
	destination.write"OBJECT world\n"
	destination.write"kids #{model.mdl_groups.length}\n"
	destination.write(ac3d_object(model))

end

#ac3d materials. Returns all the model materials in ac3d format
def ac3d_materials(model)
	materials = String.new()
	material_index = 0

        if @mdl_materials.length < 1
		#ac3d material format: MATERIAL "DefaultWhite" rgb 1 1 1  amb 1 1 1  emis 0 0 0  spec 0.5 0.5 0.5  shi 64  trans 0
		materials << "MATERIAL \"white\" rgb 1 1 1  amb 1 1 1  emis 0 0 0  spec 0.19 0.19 0.19  shi 64  trans 0\n"
	else
		model.mdl_materials.each { |key, value|
			$material_order[key] = material_index

			#handle missing material attributes
			unless value.diffuse_rgb.instance_of? Array then value.diffuse_rgb = [1.0, 1.0, 1.0] end
#			unless value.ambient_rgb.instance_of? Array then value.ambient_rgb = [1.0, 1.0, 1.0] end
              value.ambient_rgb = [1.0, 1.0, 1.0]
			unless value.emissive_rgb.instance_of? Array then value.emissive_rgb = [0.0, 0.0, 0.0] end
			unless value.specular_rgb.instance_of? Array then value.specular_rgb = [0.5, 0.5, 0.5] end
			unless value.shininess.instance_of? String then value.shininess = 64 end
			unless value.transparency.instance_of? String then value.transparency = 0 end

			#write the material record to the ac file
			material_index += 1
			materials << "MATERIAL \"#{key}\" rgb #{value.diffuse_rgb.join(' ')} amb #{value.ambient_rgb.join(' ')} emis #{value.emissive_rgb.join(' ')} spec #{value.specular_rgb.join(' ')} shi #{value.shininess.to_i} trans #{1 - value.transparency.to_f}\n"
		}
	end

	return materials
end


def ac3d_object(model)
	object = String.new()

	groups = Hash.new()

	#loop through the model faces and create data structures to hold the ac model attributes
	#note that a structure is indexed by object/group/part of the model
	model.mdl_faces.each {|face|
		groups[face.group]               = Hash.new()
		groups[face.group]['material']   = Array.new()
		groups[face.group]['vertices']   = Hash.new()
		groups[face.group]['surfaces']   = Hash.new()

		#we can populate the name and material here
		groups[face.group]['name']     = face.group
		groups[face.group]['material'].push(face.material)
	}

	#loop through the faces again populating the data structures of each group
	#note that each surface has vertex-x-y-z and u-v attributes
	model.mdl_faces.each {|face|
		#create the group/surface/face hash
		groups[face.group]['surfaces'][face.f_id.to_s]  = Hash.new()
		groups[face.group]['surfaces'][face.f_id.to_s]['vert_index']  = Array.new()
		groups[face.group]['surfaces'][face.f_id.to_s]['face_id']     = String.new(face.f_id.to_s)

		#add the vertex indices that define the face
		groups[face.group]['surfaces'][face.f_id.to_s]['vert_index']  = face.vertices #.push(face.vertices)

		#get the face uv coordinate indices
		groups[face.group]['surfaces'][face.f_id.to_s]['uv_index']    = face.uv_coord_index

		#get the x,y,z coordinates of each vertex in the group
		face.vertices.each { |v|
			xyz = model.mdl_vertices[v.to_i]
			groups[face.group]['vertices'][v.to_s]  = "#{xyz.instance_eval {@x}} #{xyz.instance_eval {@y}} #{xyz.instance_eval {@z}}"
		}
	}


	#loop through the groups and add ac3d format strings to the returned object string
	groups.each_key { |group|
		object << "OBJECT poly\nname \"#{groups[group]['name']}\"\ncrease 85\n"

		#the surface may or may not have an assigned material
		#and even if it has a material, the material may have no associated texture
		if @mdl_materials.length > 0 and model.mdl_materials[groups[group]['material'][0].to_s].texture_file != nil then
			object << "texture \"" << model.mdl_materials[groups[group]['material'][0].to_s].convert_file_format() << "\"\n"
		end

		#the number of vertices which define the group
		object << "numvert " << groups[group]['vertices'].length.to_s << "\n"

		#the vertices themselves (as defined by their x,y,z coordinates)
		#in ac format, each vertex is indexed per group so a hash is
		#created relating each vertex group index to the @Model object vertex index

		local_vertex_index = Hash.new()
		local_vertex_count = 0

		groups[group]['vertices'].each_key { |vert_index|
			object << groups[group]['vertices'][vert_index] << "\n"
			local_vertex_index[vert_index.to_s] = (local_vertex_count)
                        local_vertex_count += 1
		}

		#add the number of surfaces in the group to the output object
		object << "numsurf " << groups[group]['surfaces'].length.to_s << "\n"

		#now loop through the surfaces and add the surface strings to the output object
		groups[group]['surfaces'].each_key {|surface|
			#add smoothing
			object << "SURF 0x10\n"
			#add material reference if they exist
			if @mdl_materials.length > 0
                   #         object << "mat " << $material_order[groups[group]['material'].to_s].to_s << "\n"
                  object << "mat " << $material_order[model.mdl_materials[groups[group]['material'][0].to_s].name].to_s << "\n"
			else
			    object << "mat 0\n"
            end
			#add refs tag
			object << "refs " << groups[group]['surfaces'][surface]['vert_index'].length.to_s << "\n"

			#this index is used to coordinate local vertices to @Model uv coords
			uv_idx = 0

			#loop though the vertices of the surface adding the group index vertex index and uv coordinates (if they exist)
			groups[group]['surfaces'][surface]['vert_index'].each { |face_vert|
				#add the locally adjusted surface vertex index
				object << local_vertex_index[face_vert.to_s].to_s

				#with model uv coords to the returned object
				u = model.mdl_uv_coords[groups[group]['surfaces'][surface]['uv_index'][uv_idx]].instance_variable_get(:@u)
				v = model.mdl_uv_coords[groups[group]['surfaces'][surface]['uv_index'][uv_idx]].instance_variable_get(:@v)

				#if uv coords do not exist substitute "0.0 0.0"
                                if u and v
                                  object << " " << u.to_s << " " << v.to_s
                                else
                                  object << " 0.0 0.0"
                                end
				object << "\n"

				#increment the uv index
				uv_idx = uv_idx + 1
			}
		}
		#finish off the group with the "kids 0" string (this may need expanded if some models do have kids!)
		object << "kids 0\n"
	}

	#return the object string
	return object

end #ac3d_object

#exampld of object/group code from an ac3d model
#OBJECT poly
#name "wing_bottom_wing_bo"
#texture "wings2.rgb"
#data 19
#wing_bottom_wing_bo
#crease 30
#numvert 33
#-0.578737 -0.613598 4.654664
#-0.276953 -0.628819 4.654664
#numsurf 37
#... surface definitions
#kids 0
