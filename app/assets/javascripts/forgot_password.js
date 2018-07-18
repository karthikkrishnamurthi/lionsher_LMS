function validation() {
    if((document.getElementById('user_email').value.split(' ').join('') == "") ||
        (validate_email() == false)){
        return false;
    } else {
        return true;
    }
}

function validate_email() {

    var email = document.getElementById('email_validate');
    var email_div = document.getElementById('email_div');
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    var address = document.getElementById('user_email').value;
    if(address.split(' ').join('') == ""){
        email_div.style.display = "block";
        email_div.style.color = "red";
        email_div.setAttribute("style", "display: block; color: red;margin: 0px 0px 0px 325px; font-size: 12px;");
    }else {
        email_div.style.display = "none";
    }

    if((reg.test(address) == false) && (address.split(' ').join('') != "")){
        email.style.display = "block";
        email.style.color = "red";
        email.setAttribute("style", "display: block; color: red; margin: 0px 0px 0px 325px; font-size: 12px;");
        return false;
    } else {
        email.style.display = "none";
        return true;
    }
}