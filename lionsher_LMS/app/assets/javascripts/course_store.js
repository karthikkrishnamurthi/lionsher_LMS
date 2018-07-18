function validation()
{    
    var name_field = document.getElementById("name").value.split(' ').join('');
    var email_field = document.getElementById("email").value.split(' ').join('');
    var err_msg_field = document.getElementById("error_message");
    var email_err_msg_field = document.getElementById("email_error_message");
    if(name_field == "" || email_field == "") {
        err_msg_field.style.display = "block";
        err_msg_field.style.color = "red";
        email_err_msg_field.style.display = "none";
        return false;
    }else if(name_field != "" && email_field != ""
        && char_number_email_check(email_field)) {
        err_msg_field.style.display = "none";
        email_err_msg_field.style.display = "none";
        return true;
    } else if(char_number_email_check(email_field) == false) {
        err_msg_field.style.display = "none";
        email_err_msg_field.style.display = "block";
        email_err_msg_field.style.color = "red";
        return false;
    } else {
        err_msg_field.style.display = "block";
        err_msg_field.style.color = "red";
        email_err_msg_field.style.display = "none";
        return false;
    }
}

function field_validation()
{
    var no_of_license_field = document.getElementById("no_of_license");
    var terms_checkbox = document.getElementById("check_terms");
    var error_msg = document.getElementById("blank_error");
    var checkbox_error_msg = document.getElementById("check_error");
    if((calculate_price() == true) && (terms_checkbox.checked == true)) {
        error_msg.style.display = "none";
        checkbox_error_msg.style.display = "none";
        return true;
    } else if((no_of_license_field.value.split(' ').join('') == "" || no_of_license_field.value.split(' ').join('') == 0)
               && (terms_checkbox.checked == false)) {
        error_msg.style.display = "block";
        error_msg.style.color = "red";
        checkbox_error_msg.style.display = "block";
        checkbox_error_msg.style.color = "red";
        return false;
    } else if(terms_checkbox.checked == false) {
        checkbox_error_msg.style.display = "block";
        checkbox_error_msg.style.color = "red";
        error_msg.style.display = "none";
        return false;
    } else if((no_of_license_field.value.split(' ').join('') == "" || no_of_license_field.value.split(' ').join('') == 0)) {
        error_msg.style.display = "block";
        error_msg.style.color = "red";
        checkbox_error_msg.style.display = "none";
        return false;
    } else {
        error_msg.style.display = "block";
        error_msg.style.color = "red";
        checkbox_error_msg.style.display = "block";
        checkbox_error_msg.style.color = "red";
        return false;
    }
}

function char_number_email_check(field)
{
    var email_expr = /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i;
    if(field.match(email_expr)) {
        return true;
    } else {
        return false;
    }
}

function calculate_price()
{alert("here");
    var exp1 = /^[0-9]+$/;
    var no_of_license = document.getElementById("no_of_license").value.split(' ').join('');
    var course_price = document.getElementById("course_price").value.split(' ').join('');
    var error_msg = document.getElementById("number_error");
    var total_price = document.getElementById("total_price");
    if(no_of_license != "" && no_of_license.match(exp1)){
        total_price.value = parseInt(no_of_license) * parseFloat(course_price);
        error_msg.style.display = "none";
        return true;
    } else {
        error_msg.style.display = "block";
        error_msg.style.color = "red";
        return false;
    }
}

function price_form_validation()
{
    var no_licenses = document.getElementById("no_of_license").value;
    if(no_licenses != "" && no_licenses != "0") {
        return true;
    }
    else {
        return false;
    }
}