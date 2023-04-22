
def gui(main_content, status_content)

html = %Q~<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" type="text/css" href="../gui/css/gui.css" />
  <script src="../gui/javascript/gui.js"></script>
</head>

<body>

<div id="menu">
  <form style='float:right;' method='GET' action='/quit'><input type='submit' value='exit and close server' /></form><br style='clear:both;' />
  <form style='float:right;' method='GET' action='/clear_cache'><input type='submit' value='clear cache' /></form><br style='clear:both;' />

<br style='clear:both;' />
<form name="upload_files" action="/upload" method="POST" enctype="multipart/form-data" >
  <p><span class="title">select *.obj file</span></br>
    <input type="file" accept=".obj" id="objfile" name="objfile" onchange="setFilename(this.id)" />
    <input type="hidden" id="obj_file_name" name="obj_file_name" value="" />
    <tspan style="padding-left:40px";>
      <input type="text" id="scale_factor" name="scale_factor" size="10" value='629.4' style='color:#999999;background-color:#E9E4B3;'/> scale factor
    </tspan>
  </p>

  <div id="mtl_div" name="mtl_dive" style="display:none;">
  <p><span class="title">select *.mtl file</span> (optional)<br />
    <input type="file" accept=".mtl" id="mtlfile" name="mtlfile" onchange="setFilename(this.id)" />
    <input type="hidden" id="mtl_file_name" name="mtl_file_name" value="" />
  </p>
  <p style="border-width:1px;border-style:solid;margin:10px;padding:5px;">
    <span style="font-size:14px;">stroke</span><br />
      <input type="radio" name="stroke" id="stroke" value="black" checked="checked">black |
      <input type="radio" name="stroke" id="stroke" value="none">none |
      <input type="radio" name="stroke" id="stroke" value="diffuse">use diffuse |
      <input type="radio" name="stroke" id="stroke" value="specular">use specular |
      <select name="stroke_opacity" id="stroke_opacity">
        <option value="1.00">100%</option>
        <option value="0.90">90%</option>
        <option value="0.80">80%</option>
        <option value="0.70">70%</option>
        <option value="0.60">60%</option>
        <option value="0.50">50%</option>
        <option value="0.40">40%</option>
        <option value="0.30">30%</option>
        <option value="0.20">20%</option>
        <option value="0.10">10%</option>
        <option value="0">0%</option>
     </select> opacity
  </p>
  <p style="border-width:1px;border-style:solid;margin:10px;padding:5px;">
    <span style="font-size:14px;">fill</span><br />
      <input type="radio" name="fill" id="fill" value="black">black |
      <input type="radio" name="fill" id="fill" value="none" checked="checked" >none |
      <input type="radio" name="fill" id="fill" value="diffuse">use diffuse |
      <input type="radio" name="fill" id="fill" value="specular">use specular |
      <select name="fill_opacity" id="fill_opacity">
        <option value="1.00">100%</option>
        <option value="0.90">90%</option>
        <option value="0.80">80%</option>
        <option value="0.70">70%</option>
        <option value="0.60">60%</option>
        <option value="0.50">50%</option>
        <option value="0.40">40%</option>
        <option value="0.30">30%</option>
        <option value="0.20">20%</option>
        <option value="0.10">10%</option>
        <option value="0">0%</option>
      </select> opacity
  </p>
  </div> <!-- end of material panel -->

  <p style="border-width:1px;border-style:solid;margin:10px;padding:5px;">
    <span style="font-size:14px;">define printable area</span><br />
      <input type="text" id="printable_x" name="printable_x" size="5" value='7in' style='color:#999999;background-color:#E9E4B3;'/> wide x
      <input type="text" id="printable_y" name="printable_y" size="5" value='10in' style='color:#999999;background-color:#E9E4B3;'/> high
      <span style='float:right;'><input type="checkbox" id="use_labels" name="use_labels" value="use_labels" checked="checked" /><label for="labels"> show group names</label></span>
  </p>

<p> select action<br />
   <select name="action" id="action">
     <option value="ac">convert to *.ac</option>
     <option value="obj">convert to *.obj</option>
     <option value="svg">convert to *.svg</option>
   </select>
</p>
  <p><input type="submit" id="submitAction>" name="submitAction" value="Do it!" /></p>
</form>

#{status_content}

</div>

<div id="content">
    <p>#{main_content}</p>
</div>

</body></html>~

return html


end #gui
