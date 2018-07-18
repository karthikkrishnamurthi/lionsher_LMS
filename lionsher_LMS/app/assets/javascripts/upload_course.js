//Restricts form submit if fields are empty and contains improper file formats
function validation() {
    var validate_div = document.getElementById("validateupload");
    var course_name = document.getElementById('upload_coursefile').value.split(' ').join('');
    if(!(document.getElementById('upload_coursefile').value.split(' ').join('') == "")){
      var div = document.getElementById('loading');
      var div4 = document.getElementById('cancel');
      var progress_bar = document.getElementById('progress_bar');
      var div2 = document.getElementById('course_submit');
      var div3 = document.getElementById('upload_coursefile');
      var div5 = document.getElementById('div_upper_left');
      var div_type_of_course = document.getElementById('div_type_of_course');
      var label_upload_coursefile = document.getElementById('label_upload_coursefile');
      var hr = document.getElementById('hr');
      div.style.display = "inline";
      div.style.color = "gray";
      div.setAttribute("style", "display: inline;margin: 0px 0px 0px 20px;color:gray;");
      div4.style.display = "none";
      progress_bar.setAttribute("style", "display: block;margin:0px;padding:0px;");
      div2.style.display = "none";
      div3.style.display = "none";
      div5.style.display = "none";
      div_type_of_course.style.display = "none";
      label_upload_coursefile.style.display = "none";
      hr.style.display = "none";
      validate_div.style.display = "none";
      return true;
    } else {
      validate_div.setAttribute("style", "display: block; color: red; float:left;margin:60px 0px 0px 15px;");
      return false;
    }
  }