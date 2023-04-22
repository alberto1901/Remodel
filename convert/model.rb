
class Model
  def initialize(source, destination)
      @mdl_filename    = source
      @mdl_dest_file   = destination
      @mdl_source      = File.open(@mdl_filename, "r")
      @mdl_destination = File.open(@mdl_dest_file, "w")
      @mdl_faces       = Array.new
      @mdl_vertices    = Array.new
      @mdl_uv_coords   = Array.new
      @mdl_normals     = Array.new
      @mdl_groups      = Array.new
      @mdl_materials   = Hash.new
      @mdl_matlibs     = Array.new

      #svg specific variables - can these be defined in svg.rb?
      @mdl_scale_factor        = String.new
      @mdl_printable_x         = String.new
      @mdl_printable_y         = String.new
      @mdl_fill                = String.new
      @mdl_fill_opacity        = String.new
      @mdl_stroke              = String.new
      @mdl_stroke_opacity      = String.new
      @mdl_use_labels          = String.new

      require File.dirname($0) + '/convert/3d_formats/obj'
      require File.dirname($0) + '/convert/3d_formats/ac'
      require File.dirname($0) + '/convert/3d_formats/svg'

      if $log then
        $log.info "...creating internal representation of #{source}"
      else 
        puts "...creating internal representation of #{source}"
      end

      parse_obj()
  end #initialize

  attr_reader :mdl_source, :mdl_destination, :mdl_faces, :mdl_filename, :mdl_matlibs, :mdl_groups, :mdl_materials, :mdl_vertices, :mdl_uv_coords, :mdl_dest_file
  attr_writer :mdl_source, :mdl_destination, :mdl_faces, :mdl_filename, :mdl_matlibs, :mdl_groups, :mdl_materials, :mdl_vertices, :mdl_uv_coords, :mdl_dest_file

  #svg specific
  attr_reader :mdl_scale_factor, :mdl_printable_x, :mdl_printable_y, :mdl_fill, :mdl_fill_opacity, :mdl_stroke, :mdl_stroke_opacity, :mdl_use_labels
  attr_writer :mdl_scale_factor, :mdl_printable_x, :mdl_printable_y, :mdl_fill, :mdl_fill_opacity, :mdl_stroke, :mdl_stroke_opacity, :mdl_use_labels

  #used to verify parsing
  def view_src(model)
	i=0
	puts "VERTICES"
	model.mdl_vertices.each { |vert| puts "#{i=i+1}: ID: #{vert.v_id} X: #{vert.x} Y: #{vert.y} Z: #{vert.z}"}
	i=0
	puts "FACES"
	model.mdl_faces.each {|face| puts "#{i=i+1}: ID: #{face.f_id} GROUP: #{face.group} MATERIAL: #{face.material}"
		face.vertices.each {|v|
                 x = model.mdl_vertices[v.to_i]
			puts "#{v} ID: #{x.instance_eval {@v_id}} X: #{x.instance_eval {@x}} Y: #{x.instance_eval {@y}} Z: #{x.instance_eval {@z}}"
		}
	}
  end #view_src

  #used to convert/save file to requested format
  def save(model)
    if $log then
        $log.info "......groups:    #{model.mdl_groups.length}"
        $log.info "......faces:     #{model.mdl_faces.length}"
        $log.info "......vertices:  #{model.mdl_vertices.length}"
        $log.info "......uv coords: #{model.mdl_uv_coords.length}"
        $log.info "......materials: #{model.mdl_materials.length}"
        $log.info "...saving #{model.mdl_destination.path}"
    else
        puts "......groups:    #{model.mdl_groups.length}"
        puts "......faces:     #{model.mdl_faces.length}"
        puts "......vertices:  #{model.mdl_vertices.length}"
        puts "......uv coords: #{model.mdl_uv_coords.length}"
        puts "......materials: #{model.mdl_materials.length}"
        puts "...saving #{model.mdl_destination.path}"
    end

    case model.mdl_destination.path
      when /\.ac$/
	      save_ac(model, model.mdl_destination)
      when /\.obj$/
	      save_obj(model, model.mdl_destination)
      when /\.svg$/
        save_svg(model, model.mdl_destination)
     else
	     if $log then
             $log.info "Destination file (@mdl_destination) does not have .ac, .svg, or .obj extension"
         else
             puts "Destination file (@mdl_destination) does not have .ac, .svg, or .obj extension"
        end
    end #case

    if $log then
        $log.info "...done"
    else
        puts "...done"
    end

  end #save

end #class Model





class Material
  def initialize(name)
    @name          = name               #newmtl blinder_r_auv
    @shininess     = shininess.to_i     #Ns 100.000
    @transparency  = transparency.to_f  #d 1.00000
    @illumination  = illumination.to_f  #illum 2
    @diffuse_rgb   = diffuse_rgb.to_f   #Kd 1.00000 1.00000 1.00000		#diffuse
    @ambient_rgb   = ambient_rgb.to_f   #Ka 1.00000 1.00000 1.00000		#ambient
    @specular_rgb  = specular_rgb.to_f  #Ks 1.00000 1.00000 1.00000		#specular
    @emissive_rgb  = emissive_rgb.to_f  #Ke 0.00000e+0 0.00000e+0 0.00000e+0	#?
    @texture_file  = texture_file       #map_Kd verticals.png			#texture
  end
  attr_reader :name, :shininess, :transparency, :illumination, :diffuse_rgb, :ambient_rgb, :specular_rgb, :emissive_rgb, :texture_file
  attr_writer :name, :shininess, :transparency, :illumination, :diffuse_rgb, :ambient_rgb, :specular_rgb, :emissive_rgb, :texture_file

  def convert_file_format()
    if ARGV[2] =~ /-ext=(.+)\s*$/
        extension = $1
   else
        extension = "png"
    end

    return @texture_file.sub(/\..+$/, ".#{extension}")
  end

  def Material.named(name)

    return
  end

  def to_s
    "#{@name}"
  end
end #class Material



class Face
   def initialize(f_id, vertices, group=nil, material=nil, uv_coord_index=nil, normal_index=nil)
      @f_id       = f_id
      @vertices   = vertices
      @group      = group
      @material   = material
      @uv_coord_index  = uv_coord_index
      @normal_index    = normal_index
   end
   attr_reader :f_id, :vertices, :group, :material, :uv_coord_index, :normal_index
   attr_writer :f_id, :vertices, :group, :material, :uv_coord_index, :normal_index
end #class Face


class Vertex
   def initialize(v_id, x, y, z, u=nil, v=nil)
      @v_id = v_id
      @x  = x.to_f
      @y  = y.to_f
      @z  = z.to_f
      @u  = u.to_f
      @v  = v.to_f
   end
   attr_reader :x, :y, :z, :u, :v, :v_id
   attr_writer :x, :y, :z, :u, :v, :v_id
end #class Vertex


class Normal
   def initialize(n_id, x, y, z)
      @n_id = n_id
      @x  = x.to_f
      @y  = y.to_f
      @z  = z.to_f
   end
   attr_reader :x, :y, :z, :n_id
   attr_writer :x, :y, :z, :n_id
end #class Vertex_normal


class Uv_coord
   def initialize(uv_id, u, v)
      @uv_id = uv_id
      @u  = u.to_f
      @v  = v.to_f
   end
   attr_reader :u, :v, :uv_id
   attr_writer :u, :v, :uv_id
end #class Uv_coord
