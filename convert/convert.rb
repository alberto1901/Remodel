#!/usr/local/bin/ruby

require File.dirname($0) + '/model.rb'

#check parameters
ARGV.each{|arg| 
    case arg
      when /-(h|help)$/ then puts "\nusage:\n  ruby convert.rb input_model.obj output_model.ac|obj [-ext=xxx]"; Kernel.exit
      when /-(o|option)/ then begin 
          puts "\noptions:"
          puts "  -h|help     prints usage"
          puts "  -o|options  prints options"
          puts "  -ext=xxx    sets texture file names to use xxx extension, defaults to .rgb\n\n"
          Kernel.exit
      end
      when /-ext=/ then puts "texture file names will use #{arg} extension"  
    end
}

#can only import obj files for now
unless Regexp.compile(/\.obj$/i).match(ARGV[0].to_s)
# $log.warn "input file must have .obj extension"; Kernel.exit 
    puts "input file must have .obj extension"; Kernel.exit 
end

#can only export svg, obj and ac files for now
unless Regexp.compile(/\.(obj|ac|svg)$/i).match(ARGV[1].to_s)
# $log.warn "output file must have .obj, .ac or .svg extension"; Kernel.exit 
    puts "output file must have .obj, .ac or .svg extension"; Kernel.exit 
end

@plane = Model.new(ARGV[0], ARGV[1]);

@plane.save(@plane);

