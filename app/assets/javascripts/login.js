function validation() {
    if((document.getElementById('email').value.split(' ').join('') == "") &&
        (document.getElementById('password').value.split(' ').join('') == "") ||
        (validate_email() == false)){
        return false;
    } else {
        return true;
    }
}

function validate(ctr1,ctr2) {
    var flash_div = document.getElementById('learner_div');
    var div1 = document.getElementById(ctr1);
    var div2 = document.getElementById(ctr2);
    if((div1.value.split(' ').join('') == "") ||
        (div1.value.split(' ').join('') == "0")){
        div1.style.border = "1px red solid";
        div1.style.background = "#ffefef";
        div2.style.display = "block";
        div2.style.color = "red";
        div2.setAttribute("style", "display: block;color: red; margin:0px 0px 2px 10px;");
        flash_div.style.display = "none";
        return false;
    } else {
        div1.style.border = "#ccc 1px solid";
        div1.style.background = "#fff";
        div2.style.display = "none";
        flash_div.style.display = "none";
        return true;
    }
}
function validate_email() {
    var flash_div = document.getElementById('learner_div');
    var email_validate = document.getElementById('email_validate');
    var email_div = document.getElementById('email_div');
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    var email_address = document.getElementById('email');
    if(email_address.value.split(' ').join('') == ""){
        email_address.style.border = "1px red solid";
        email_address.style.background = "#ffefef";
        email_div.style.display = "block";
        email_div.style.color = "red";
        email_div.setAttribute("style", "display: block; color: red; float:left;margin:0px 0px 2px 10px;");
        email_validate.style.display = "none";
        flash_div.style.display = "none";
        return false;
    } else if(reg.test(email_address.value) == false){
        email_address.style.border = "1px red solid";
        email_address.style.background = "#ffefef";
        email_validate.style.display = "block";
        email_validate.style.color = "red";
        email_validate.setAttribute("style", "display: block; color: red; float:left;margin:0px 0px 2px 10px;");
        email_div.style.display = "none";
        flash_div.style.display = "none";
        return false;
    } else {
        email_address.style.border = "#ccc 1px solid";
        email_address.style.background = "#fff";
        email_div.style.display = "none";
        email_validate.style.display = "none";
        flash_div.style.display = "none";
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
