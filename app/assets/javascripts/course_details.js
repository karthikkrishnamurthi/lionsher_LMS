function validation() {
    var course_name_div = document.getElementById('display_course_name');
    var duration_div = document.getElementById('duration_blank_div');
    if(!(document.getElementById('course_course_name').value.split(' ').join('') == "") &&
        duration_check()){
        course_name_div.style.display = "none";
        duration_div.style.display = "none";
        return true;
    } else if(document.getElementById('course_course_name').value.split(' ').join('') == "") {
        duration_div.style.display = "none";
        course_name_div.style.display = "block";
        course_name_div.style.color = "red";
        course_name_div.setAttribute("style", "display: block; color: red; float:left;margin:0px 0px 0px 50px;");
        return false;
    } else if(!duration_check()) {
        course_name_div.style.display = "none";
        duration_div.style.display = "block";
        duration_div.style.color = "red";
        duration_div.setAttribute("style", "display: block; color: red; float:right;margin:5px 480px 0px 0px;");
        return false;
    }
}
function validate(ctr1,ctr2) {
    var div1 = document.getElementById(ctr1);
    var div2 = document.getElementById(ctr2);
    if((div1.value.split(' ').join('') == "") ||
        (div1.value.split(' ').join('') == "0")){
        div1.style.border = "1px red solid";
        div1.style.background = "#ffefef";
        div2.style.display = "block";
        div2.style.color = "red";
        div2.setAttribute("style", "display: block;color: red; float:left;margin:0px 0px 0px 50px;");
        return false;
    } else {
        div1.style.border = "#ccc 1px solid";
        div1.style.background = "#fff";
        div2.style.display = "none";
        return true;
    }
}

function duration_check() {
    var duration_blank_div = document.getElementById("duration_blank_div");
    if((document.getElementById('duration_hour').value == 0) &&
        (document.getElementById('duration_min').value == 0))
        {
        duration_blank_div.style.display = "block";
        duration_blank_div.style.color = "red";
        return false;
    } else {
        return true;
    }
}

function textCounter(field,cntfield,maxlimit) {
if (field.value.length > maxlimit) // if too long...trim it!
field.value = field.value.substring(0, maxlimit);
// otherwise, update 'characters left' counter
else
cntfield.value = maxlimit - field.value.length;
}