//    Validates password and logo fields. Restricts page from being submitted upon violation
function validation() {
    var logo_div = document.getElementById('logo_div');
    var logo_type = document.getElementById('logo_type');
    var password_div = document.getElementById('passwd_div');
    if(document.getElementById('password').value.split(' ').join('') == ""){
        logo_div.style.display = "none";
        logo_type.style.display = "none";
        password_div.style.display = "block";
        password_div.style.color = "red";
        password_div.setAttribute("style", "display: block;color: red; float:left; margin: 10px 0px 0px 10px; font-size: 12px;");
        return false;
    } else if(document.getElementById('logo').value.split(' ').join('') == "") {
        password_div.style.display = "none";
        logo_type.style.display = "none";
        logo_div.style.display = "block";
        logo_div.style.color = "red";
        logo_div.setAttribute("style", "display: block;color: red; float:left; margin:10px 0px 0px 250px;  font-size: 12px;");
        return false;
    } else {
        logo_div.style.display = "none";
        password_div.style.display = "none";
        logo_type.style.display = "none";
        return true;
    }
}
//    Show validation messages for corresponding fields
function validate(ctr1,ctr2) {
    var div1 = document.getElementById(ctr1);
    var div2 = document.getElementById(ctr2);
    if((div1.value.split(' ').join('') == "") ||
        (div1.value.split(' ').join('') == "0")){
        div2.style.display = "block";
        div2.style.color = "red";
        div2.setAttribute("style", "display: block; color: red; float:left; font-size: 12px;margin: 10px 0px 0px 45px;");
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