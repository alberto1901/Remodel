function toggle_visibility(id) {

//toggle visibility of div
    var e = document.getElementById(id);
    if(e.style.display == 'block')
          e.style.display = 'none';
    else
          e.style.display = 'block';

//toggle visibility of '>>>' div on menu
//    var bullet = id.concat('_showing');   
//    var f = document.getElementById(bullet);

//    if(f.style.display == 'block')
//       f.style.display = 'none';
//    else
//       f.style.display = 'block';              
} 

function setFilename(id) {

//alert(id);

    //save the obj and mtl file names in hidden fields to send with request to server
    var field = { 'objfile':'obj_file_name', 
                  'mtlfile':'mtl_file_name'};

    var e = document.getElementById(id);
    //clear any old values
    document.getElementById(field[id]).value = "";

    //ensure the correct type of files are being uploaded in the correct input fields.
    if (id.match(/objfile/) && !(e.value.match(/.obj/)))
        alert('Only *.obj files allowed to be uploaded here');
    else if (id.match(/mtlfile/) && !(e.value.match(/.mtl/)))
        alert('Only *.mtl files allowed to be uploaded here');
    else
      document.getElementById(field[id]).value = e.value;

    //if objfile has been added, display the mtl options
    if (id.match(/objfile/) && e.value.match(/.obj/))
      document.getElementById('mtl_div').style.display = 'block';
    else if (id.match(/objfile/))
      document.getElementById('mtl_div').style.display = 'none';
    
//    alert(e.value);
//    alert(document.getElementById(field[id]).value);
} 


