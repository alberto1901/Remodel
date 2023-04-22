#! /usr/bin/ruby

require 'rubygems'
require 'webrick'
require 'logger'
#require 'sqlite3'
require File.dirname($0) + '/convert/model.rb'
require File.dirname($0) + '/gui/template'

$log = Logger.new('./model_cache/remodel.log')
$log.level = Logger::INFO  #DEBUG,INFO, WARN, ERROR, FATAL

##################################################################
#ShowGui
#Primary interface
#
##################################################################
class ShowGui < WEBrick::HTTPServlet::AbstractServlet

  #prepare class for either get or post requests
  def do_GET(request, response)
    status, content_type, body = print_gui(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

 def do_POST(request, response)
    status, content_type, body = print_gui(request)
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end



  #print listing method
  def print_gui(request)
    $log.info "...serving gui"

    welcome_text = %Q~<h1>Welcome to Remodel!</h1>
<p>Remodel is a Ruby script for converting *.obj models to *.ac format or for extracting UV coordinates and creating an *.svg of the shapes.</p>
<p><ul>
  <li>Browse for a *.obj or *.ac model</li>
  <li>If extracting UVs, select stroke and fill options.</li>
  <li>Select your conversion option and click 'Do it!'</li>
  <li>Download the converted file to your download location.</li>
  <li>Remodel will cache the original and converted models. Click 'clear cache' to delete the cached versions.</li>
</ul>
</p>
<h2>Remember to exit Remodel using the button in the upper right corner. If you close the browser first, Remodel will continue to run in the background.</h2>
<p>To use Remodel from the command line: 'ruby convert.rb input_file output_file'</p>
<p>You can also use convert2.rb if you need to change the texture locations in the *.ac file to another directory (typically the Livery directory in a FlightGear aircraft director).</p>
<p>An sample *.sh file is provided if you want need to repeatedly convert a model (common when developing the model and you want to view it in FlightGear).
    ~


    html = gui(welcome_text,'')

    return 200, "text/html", html
  end #print_gui
end # Class ShowGui




##################################################################
# UPLOAD
#
##################################################################
class UpLoad < WEBrick::HTTPServlet::AbstractServlet

  #prepare class for either get or post requests
  def do_GET(request, response)
    status, content_type, body = upload(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

 def do_POST(request, response)
    status, content_type, body = upload(request)
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

   #handle uploads and respond to user.
  def upload(request)

    $log.info "...uploading file"
    #where the working files will be saved
    cache_dir = "model_cache"

    #prepare the uploaded obj file
    #Chrome, Opera (and I presume IE) prepend a fake path to uploaded file names. Remove it as it causes problems when trying to download the svg file
    request.query['obj_file_name'].gsub!(/^c:\\fakepath\\/i, '')

    #ensure a obj file has been uploaded
    unless request.query['obj_file_name'].to_s.match(/\.obj$/) then
      return 200, "text/html", "<html><body><p>Click the back button and try again. No *.obj file uploaded</p></body></html>"
    end

    #define the path/name of the working files in model cache
    obj_file = File.join(cache_dir, request.query['obj_file_name'])

    #insert the contents of the uploaded files into the working files
    #do this in a new thread, wait until finished and then join the main thread in order to avoid creating incomplete svg
    save_obj = Thread.new do
      $log.info "Writing uploaded obj file to cache directory"
      File.open(obj_file, 'w') { |file| file.write(request.query['objfile']) }
    end
    save_obj.join

    #there may or may not be a mtl file, if there is, prepare it in the same way
    if request.query['mtl_file_name'] && request.query['mtl_file_name'] != '' then
       request.query['mtl_file_name'].gsub!(/^c:\\fakepath\\/i, '')
       mtl_file = File.join(cache_dir, request.query['mtl_file_name'])

       save_mtl = Thread.new do
         $log.info "Writing uploaded mtl file to cache directory"
         File.open(mtl_file, 'w') { |file| file.write(request.query['mtlfile']) }
       end
       save_mtl.join
    end

if request.query['action'] == 'ac' then #create an AC file

    #define the path/name of the to-be-created ac file
    ac_file = File.join(cache_dir, request.query['obj_file_name'].gsub(/\.obj/, '.ac'))

    #create the internal model, convert it to ac
    @model = Model.new(obj_file, ac_file);

    #save the ac version of the model
    @model.save(@model)

   #return a web page allowing the user to download the generated ac file
    main_content = %Q~
    <h2>Download the *.ac file to your preferred directory:</h2>
     <p><a href="#{ac_file}" >#{File.basename(ac_file)}</a></p>
     <h2>Remember to exit Remodel using the button in the upper right corner. If you close the browser first, Remodel will continue to run in the background.</h2>
    ~
elsif request.query['action'] == 'obj' then #create an OBJ file

    #define the path/name of the to-be-created obj file
    obj_file = File.join(cache_dir, request.query['obj_file_name'].gsub(/\.obj/, '.obj'))

    #create the internal model, convert it to obj
    @model = Model.new(obj_file, obj_file);

    #save the obj version of the model
    @model.save(@model)

   #return a web page allowing the user to download the generated ac file
    main_content = %Q~
    <h2>Download the *.obj file to your preferred directory:</h2>
     <p><a href="#{obj_file}" >#{File.basename(obj_file)}</a></p>
     <h2>Remember to exit Remodel using the button in the upper right corner. If you close the browser first, Remodel will continue to run in the background.</h2>
    ~

elsif request.query['action'] == 'svg' then #creating an svg file

#create a svg file
    #define the path/name of the to-be-created svg file
    svg_file = File.join(cache_dir, request.query['obj_file_name'].gsub(/\.obj/, '.svg'))

    #create the internal model, convert it to svg
    @model = Model.new(obj_file, svg_file);

    #get user set svg parameters
    @model.mdl_scale_factor        = request.query['scale_factor']
    @model.mdl_printable_x         = request.query['printable_x']
    @model.mdl_printable_y         = request.query['printable_y']
    @model.mdl_fill                = request.query['fill']
    @model.mdl_fill_opacity        = request.query['fill_opacity']
    @model.mdl_stroke              = request.query['stroke']
    @model.mdl_stroke_opacity      = request.query['stroke_opacity']
    @model.mdl_use_labels          = request.query['use_labels']

    #save the svg version of the model
    @model.save(@model)



   #return a web page allowing the user to download the generated svg file
main_content = %Q~
  <h2>Download the *.svg file to your preferred directory:</h2>
  <p><a href="#{svg_file}" >#{File.basename(svg_file)}</a></p>
  <h2>Remember to exit Remodel using the button in the upper right corner. If you close the browser first, Remodel will continue to run in the background.</h2>
  ~
end #of create ac or svg file


status_content = %Q~
</strong>Submitted</strong>
<table id="parameters" style="width:100%;"><tr>
  <td><strong>obj file name:</strong> #{request.query['obj_file_name']}</td>
  <td><strong>mtl file name:</strong> #{request.query['mtl_file_name']}</td>
</tr><tr>
  <td><strong>print x:</strong> #{@model.mdl_printable_x}</td>
  <td><strong>print y:</strong> #{@model.mdl_printable_y}</td>
</tr><tr>
  <td><strong>fill:</strong> #{@model.mdl_fill}</td>
  <td><strong>fill opacity:</strong> #{@model.mdl_fill_opacity}</td>
</tr><tr>
  <td><strong>stroke:</strong> #{@model.mdl_stroke}</td>
  <td><strong>stroke opacity:</strong> #{@model.mdl_stroke_opacity}</td>
</tr><tr>
  <td><strong>scale factor:</strong> #{@model.mdl_scale_factor}</td>
  <td><strong>use labels:</strong> #{request.query['use_labels']}</td>
</tr>
  </table>
~

  #provide the log data to the user
  if File.exist?('./model_cache/remodel.log') then

     status_content << %Q~<p><a href="javascript:toggle_visibility('log')">view log</a></p><div id="log" name="log" style="display:none;" > <pre>~

     File.open( './model_cache/remodel.log' ).each do |line|
       if line.match("\##{$$}") then
         line.gsub!(/^.* -- : /,'')
         status_content << line
       end
    end
    status_content << "</pre></div>"
  end

  html = gui(main_content, status_content)

  return 200, "text/html", html

  end #upload

end #class UpLoad



##################################################################
# CLEAR CACHE
# Removes the working copies of *.obj, *.mtl and the generated
# *.svg file. User should download the *.svg BEFORE clearing the
# cache because it will not be availible afterwards.
##################################################################
class ClearCache < WEBrick::HTTPServlet::AbstractServlet

  #prepare class for either get or post requests
  def do_GET(request, response)
    status, content_type, body = clear_cache(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

  def do_POST(request, response)
    status, content_type, body = clear_cache(request)
    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

   #clears cache of temporary *.log *.obj, *.mt. and *.svg files. Respond to user.
  def clear_cache(request)

    cleared_files = Array.new()
    Dir.glob('./model_cache/*.{obj,mtl,svg,ac}') do |filename|
      cleared_files.push( File.basename(filename))
      File.delete(filename)
    end

    #clear the log file in case user converts more models in this same process -- File.open('/tmp/file', 'w') {}
    File.open("./model_cache/remodel.log", "w") {}

    #response
    main_content = %Q~<h2>You have cleared the log and removed the following files from Remodel cache:</h2>#{cleared_files.sort.join('</br>')}~

    html = gui(main_content, '')

    return 200, "text/html", html
  end #clear_cache

end #class ClearCache





##################################################################
# EXIT
#
##################################################################
class Quit < WEBrick::HTTPServlet::AbstractServlet

 def do_GET(request, response)
    $log.info "shutting down webrick, pid: #{$$}"
    Process.kill 'INT', $$

    response.status = 200
    response['Content-Type'] = "text/html"

#web page
response.body = %Q~<html>
<head>
<link rel="stylesheet" type="text/css" href="../gui/css/gui.css" />
</head>
<body>
<div id="menu">
</div>
<div id="content">
<div class="book"></div>
  <h2>Remodel has closed. You may close this browser window.</h2>
</div>
</body></html>~

  end

end #class Quit





##################################################################
# Dispatcher
#
#
##################################################################

if $0 == __FILE__ then

  #mount servlets for various pages/commands
  server = WEBrick::HTTPServer.new(:Port => 8000,:DocumentRoot => Dir::pwd)
  server.mount "/show_gui", ShowGui
  server.mount "/upload", UpLoad
  server.mount "/clear_cache", ClearCache
  server.mount "/quit", Quit

  #open the default browser and load books page
  link = "http://localhost:8000/show_gui"
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ then
    system("start #{link}")
  elsif RbConfig::CONFIG['host_os'] =~ /darwin/ then
    system("open #{link}")
  elsif RbConfig::CONFIG['host_os'] =~ /linux/ then
    system("xdg-open #{link}")
  end

  #allow cntl-c to shut down the server
  trap "INT" do server.shutdown end

  #start the web server
  server.start

end
