//Validation for blank text fields and email.
//Restricts user from submitting form without required fields.
function validation() {
    if(document.getElementById('user_login').value.split(' ').join('') == ""){
        set_style('login_div','email_div','email_validate','org_div','contact_number','custom_message');
        return false;
    } else if(document.getElementById('user_email').value.split(' ').join('') == ""){
        set_style('email_div','login_div','email_validate','org_div','contact_number','custom_message');
        return false;
    }else if(validate_email() == false){
        set_style('email_validate','email_div','login_div','org_div','contact_number','custom_message');
        return false;
    } else if(document.getElementById('organization').value.split(' ').join('') == ""){
        set_style('org_div','email_validate','email_div','login_div','contact_number','custom_message');
        return false;
    } else if(document.getElementById('user_phone').value.split(' ').join('') == ""){
        set_style('contact_number','org_div','email_validate','email_div','login_div','custom_message');
        return false;
    } else if(document.getElementById('custom_link').value.split(' ').join('') == ""){        
        set_style('custom_message','org_div','email_validate','email_div','login_div');
        return false;
    } else {
        add_value();
        return true;
    }
    return false;
}

function set_style(set,set_none1,set_none2,set_none3,set_none4){
    var set_div = document.getElementById(set);
    var set_none1_div = document.getElementById(set_none1);
    var set_none2_div = document.getElementById(set_none2);
    var set_none3_div = document.getElementById(set_none3);
    var set_none4_div = document.getElementById(set_none4);
    set_div.style.display="block";
    set_div.style.color="red";
    set_div.setAttribute("style", "display: block; color: red; margin:5px 0px 0px 10px;float:left; font-size: 12px;");
    set_none1_div.style.display="none";
    set_none2_div.style.display="none";
    set_none3_div.style.display="none";
    set_none4_div.style.display="none";
}

//Displays messages on validation
function validate(ctr1,ctr2) {
    if((document.getElementById(ctr1).value.split(' ').join('') == "") ||
        (document.getElementById(ctr1).value.split(' ').join('') == "0")){
        var div = document.getElementById(ctr2);
        div.style.display="block";
        div.style.color="red";
        div.setAttribute("style", "display:block; color:red; float:left;margin:5px 0px 0px 10px; font-size:12px;");
        return false;
    } else {
        document.getElementById(ctr2).style.display = "none";
        return true;
    }
}

//Validation for email pattern.
function validate_email() {
    var email_validate = document.getElementById('email_validate');
    var email_div = document.getElementById('email_div');
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    var address = document.getElementById('user_email').value;
    if(address.split(' ').join('') == ""){
        email_div.style.display="block";
        email_div.style.color="red";
        email_validate.style.display = "none";
        email_div.setAttribute("style", "display:block; color:red; margin:5px 0px 0px 10px;float:left; font-size:12px;");
        email_validate.setAttribute("style", "display:none;");
        return false;
    }else if(reg.test(address) == false){
        email_div.style.display="none";
        email_validate.style.display = "block";
        email_validate.style.color = "red";
        email_div.setAttribute("style", "display: none;");
        email_validate.setAttribute("style", "display:block; color:red; margin:5px 0px 0px 10px;float:left; font-size:12px;");
        return false;
    } else {
        email_div.style.display="none";
        email_validate.style.display = "none";
        email_validate.setAttribute("style", "display: none;");
        email_div.setAttribute("style", "display: none;");        
        return true;
    }
}

//Creates custom link from organization name by removing special characters and spaces.
function add_value() {
    var org_id = document.getElementById('organization').value.split(' ').join('');
    var link_id = document.getElementById('custom_link');
    org_id = org_id.replace(/[^a-zA-Z 0-9]+/g,'');
    link_id.value = org_id.toLowerCase();
}