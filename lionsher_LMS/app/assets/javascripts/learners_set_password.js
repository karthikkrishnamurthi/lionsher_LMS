function validation() {
    if(document.getElementById('password').value.split(' ').join('') == ""){
        return false;
    } else {
        return true;
    }
}
function validate(ctr1,ctr2) {
    var div1 = document.getElementById(ctr1);
    var div2 = document.getElementById(ctr2);
    if(div1.value.split(' ').join('') == ""){
        div2.style.display = "block";
        div2.style.color = "red";
        div2.setAttribute("style", "display: block; color:red;margin: 0px 0px 0px 45px; font-size: 12px;");
        return false;
    } else {
        div2.style.display = "none";
        return true;
    }
}

function show_password()
{
    var check_box = document.getElementById('check_box');
    var password_feild = document.getElementById('password');
    if(check_box.checked)
    {
        password_feild.type= "text";
    }else
    {
        password_feild.type= "password";
    }
}

function default_uncheck()
{
    var check_box = document.getElementById('check_box');
    check_box.value= "false";
}