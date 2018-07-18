// Author : Aarthi

window.onload = function() {
    if(document.getElementsByTagName) {
        var inputs = document.getElementsByTagName('input');
        for(var i in inputs) {
            var input = inputs[i];
            if(input.type == 'password' && input.id == 'password') {
                toggle_control = document.createElement('label');
                toggle_control.innerHTML = "<div id=\"password_div\">"+""
                toggle_control.innerHTML = "<div id=\"div_show_password\"><input  style=\"margin-left:0px;\" type=\"checkbox\" onclick=\"toggle_password('"+ input.id+"',this.checked) \" />"+"Show Password</div>";

//                var div_pswrd = document.getElementById('div_show_password');
//                div_pswrd.setAttribute('style', 'background-color:red;')
                input.parentNode.insertBefore(toggle_control, input.nextSibling);
            }
        }
    }
}

function toggle_password(element_id, show_text) {
    if(document.getElementById) {
        var password_input = document.getElementById(element_id);
        var new_input      = document.createElement('input');
        with(new_input) {
            id        = password_input.id;
            name      = password_input.name;
            value     = password_input.value;
            size      = password_input.size;
            className = password_input.className;
            type      = show_text ? 'text' : 'password';
            }
        password_input.parentNode.replaceChild(new_input,
            password_input);
    }
}

