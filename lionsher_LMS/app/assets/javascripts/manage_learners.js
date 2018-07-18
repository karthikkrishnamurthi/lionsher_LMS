var checked = 0;
function validate(checkbox)
{
    if(checkbox.checked){
        checked = 1;
    }
}

function validation() {   
    var div = document.getElementById('learner_div');
    if(checked == 0){
        if((document.getElementById('user_login').value.split(' ').join('') != "") &&
            (document.getElementById('user_email').value.split(' ').join('') != "")) {
            div.style.display = "none";
            return true;
        } else {
            div.style.display = "block";
            div.style.color = "green";
            return false;
        }
    } else if (checked == 1) {
        if((document.getElementById('user_login').value.split(' ').join('') == "") &&
            (document.getElementById('user_email').value.split(' ').join('') == "")){
            div.style.display = "none";
            return true;
        } else if((document.getElementById('user_login').value.split(' ').join('') == "") ||
            (document.getElementById('user_email').value.split(' ').join('') == "")) {
            div.style.display = "block";
            div.style.color = "green";
            return false;
        }
    }

}

function addElement() {
    var add_more_button = document.getElementById('assign_learners_more');
    add_more_button.style.display = "block";
    var add_new_button = document.getElementById('assign_learners_new');
    add_new_button.style.display = "none";
    var new_div = document.getElementById("myDiv");
    var learner_email = document.getElementById("learner_email");
    learner_email.style.display = "block";
    for(i=0; i<=4; i++){
        var hid_val = document.getElementById("theValue");
        var num = (document.getElementById("theValue").value -1)+ 2;
        hid_val.value = num;
        var new_label1 = document.createElement("label");
        var new_label2 = document.createElement("label");
        var new_login = document.createElement("input");
        var new_email = document.createElement("input");
        var new_table = document.createElement("table");
        var new_tr = document.createElement("tr");
        var new_td = document.createElement("td");
        new_label1.name = "login";
        new_label2.name = "email";
        new_login.id = "user_login";
        new_email.id = "user_email";

        //        new_label1.setAttribute("for", "login");
        //        new_label2.setAttribute("for", "email");
        //        new_login.setAttribute("id", "user_login");
        //        new_email.setAttribute("id", "user_email");
        var new_login_name = "user[login_"+num+"]";
        new_login.name = new_login_name;

        //        new_login.setAttribute("name", new_login_name);
        var new_email_name = "user[email_"+num+"]";
        new_email.name = new_email_name;

        //        new_email.setAttribute("name", new_email_name);
        new_login.size = 20;
        new_email.size = 20;
        new_login.type = "text";
        new_table.innerHTML = '';
        new_div.appendChild(new_table);

        new_table.appendChild(new_tr);

        new_tr.innerHTML = '';
        new_tr.appendChild(new_td);
        if (num <= 8) {
            new_label1.innerHTML = (num+1)+"&nbsp; &nbsp;";
        } else {
            new_label1.innerHTML = (num+1);
        }
        new_td.appendChild(new_label1);
        new_td.appendChild(new_login);

        new_tr.appendChild(new_td);
        new_label2.innerHTML = "&nbsp;&nbsp;";
        new_td.appendChild(new_label2);
        new_td.appendChild(new_email);
    }
}

function addElement_in_assign() {
    var add_more_button = document.getElementById('assign_learners_more');
    add_more_button.setAttribute("style","display:block;");
    var new_div = document.getElementById("myDiv");
    var learner_email = document.getElementById("learner_email");
    learner_email.setAttribute("style", "display : block;");
    for(i=0; i<=4; i++){
        var hid_val = document.getElementById("theValue");
        var num = (document.getElementById("theValue").value -1)+ 2;
        hid_val.value = num;
        var new_label1 = document.createElement("label");
        var new_label2 = document.createElement("label");
        var new_login = document.createElement("input");
        var new_email = document.createElement("input");
        var new_table = document.createElement("table");
        var new_tr = document.createElement("tr");
        var new_td = document.createElement("td");
        new_label1.setAttribute("for", "login");
        new_label2.setAttribute("for", "email");
        new_login.setAttribute("id", "user_login");
        new_email.setAttribute("id", "user_email");
        var new_login_name = "user[login_"+num+"]";
        new_login.setAttribute("name", new_login_name);
        var new_email_name = "user[email_"+num+"]";
        new_email.setAttribute("name", new_email_name);
        new_login.setAttribute("size", 20);
        new_email.setAttribute("size", 20);
        new_login.setAttribute("type", "text");
        new_table.innerHTML = '';
        new_div.appendChild(new_table);

        new_table.appendChild(new_tr);

        new_tr.innerHTML = '';
        new_tr.appendChild(new_td);
        if (num <= 8) {
            new_label1.innerHTML = (num+1)+"&nbsp; &nbsp;";
        } else {
            new_label1.innerHTML = (num+1);
        }
        new_td.appendChild(new_label1);
        new_td.appendChild(new_login);

        new_tr.appendChild(new_td);
        new_label2.innerHTML = "&nbsp;&nbsp;";
        new_td.appendChild(new_label2);
        new_td.appendChild(new_email);
    }
}

function add_to_learner_list(user_login,user_email,mytable,course_id)
{
    var login = document.getElementById(user_login);
    var new_email = document.getElementById(user_email);
    var email = new_email.value.split(' ').join('');
    var admin_buyer = document.getElementById('admin_buyer');
    var learner_limit_exceed = document.getElementById('learner_limit_exceeds');
    var learner_already_exists = document.getElementById('learner_already_exists');
    var new_table = document.getElementById(mytable);
    var hid_val = document.getElementById('hid_val');
    var k;
    k = hid_val.value;
    hid_val.value = parseInt(hid_val.value) + 1;
    var learner;
    var req = new AjaxRequest();
    if(login.value.split(' ').join('') != "" && email.split(' ').join('') != "" && valid_email(email))
    {

        req.open('POST','/users/add_to_list?course_id='+course_id+'&login='+login.value+'&email='+email,false);
        req.send(null);
        var arr_learners_ids = req.responseText.split(',');
        if(arr_learners_ids == 0)
        {
            learner_already_exists.style.display = "block";
        }
        else if(arr_learners_ids == 1)
        {
            learner_limit_exceed.style.display = "block";
        }
        else
        {
            for(var i=0;i<arr_learners_ids.length-1;i++)

            {
                    learner = arr_learners_ids[i];
                    var new_label = document.createElement("label");
                    var new_input = document.createElement("input");
                    var text = document.createTextNode(learner);

                    new_label.appendChild(text);
                    new_label.id = "email_"+i;

                    new_input.id = "chk"+k;
                    new_input.type = "checkbox";
                    new_input.checked = true;
                    new_input.name = "email-"+k;
                    new_input.value = email;

                    var new_tr = document.createElement("tr");
                    var new_td = document.createElement("td");

                    new_table.appendChild(new_tr);

                    new_tr.appendChild(new_td);

                    new_td.appendChild(new_input);
                    new_td.appendChild(new_label);
                    if (admin_buyer.value == "buyer")
                    {
                        countChecked();
                    }
                }
        }
        login.value = "";
        new_email.value = "";
        login.focus();
    }
    else
    {
        alert("Enter correct details");
    }
}

function valid_email(email)
{
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    if (reg.test(email) == false)
    {
        return false;
    }
    else
    {
        return true;
    }
}
function select_group(length,p)
{
    for (j= length,i = p; j > 0 ; i++,j--)
    {
        var chk = document.getElementById('chk'+i);
        chk.checked =true;
    }
}
function unselect_group(length,p)
{
    for (j= length,i = p; j > 0 ; i++,j--)
    {
        var chk = document.getElementById('chk'+i);
        chk.checked =false;
    }
}
function select_all_groups(length,ele_id)
{
    for (i = 1; i <= length ; i++)
    {
        var chk = document.getElementById(ele_id+i);
        chk.checked =true;
    }
}
function unselect_all_groups(length,ele_id)
{
    for (i = 1; i <= length ; i++)
    {
        var chk = document.getElementById(ele_id+i);
        chk.checked =false;
    }
}
function select_all_learners(var_length,ele_id)
{
    var length = document.getElementById(var_length).value;
    for (i = 1; i <= length ; i++)
    {
        var chk = document.getElementById(ele_id+i);
        chk.checked =true;
    }
}
function unselect_all_learners(var_length,ele_id)
{
    var length = document.getElementById(var_length).value;
    for (i = 1; i <= length ; i++)
    {
        var chk = document.getElementById(ele_id+i);
        chk.checked =false;
    }
}

function toggle() {
    var ele = document.getElementById("toggleText");
    if(ele.style.display == "block") {
        ele.style.display = "none";
    }
    else {
        ele.style.display = "block";
    }
}
function rjs_add_to_learner_list(user_login,user_email,group_id,course_id)
{
    var login = document.getElementById(user_login);
    var admin_buyer = document.getElementById('admin_buyer');
    var new_email = document.getElementById(user_email);
    var email = new_email.value.split(' ').join('');
    var hid_val = document.getElementById('hid_val');
    var k;
    k = hid_val.value;
    hid_val.value = parseInt(hid_val.value) + 1;
    if(login.value.split(' ').join('') != "" && email.split(' ').join('') != "" && valid_email(email))
    {
        new Ajax.Request('/users/rjs_add_individual_learner/'+course_id+'?login='+login.value+'&email='+email+'&group_id='+group_id+'&i='+k,
        {
            asynchronous:true,
            evalScripts:true,
            method:'get'
        });
        if (admin_buyer.value == "buyer")
        {
            countChecked();
        }
        login.value = "";
        new_email.value = "";
        login.focus();
    }
    else
    {
        alert("Enter correct details");
    }
}

function clicked_done(user_login,user_email,group_id,course_id)
{alert("in clicked");
    login = document.getElementById(user_login);
    alert("login "+login);
    email = document.getElementById(user_email);
    alert("email "+email);
    if(login.value.split(' ').join('') != "" && email.split(' ').join('') != "" && valid_email(email))
        {
            alert("calling rjs");
            rjs_add_to_learner_list(user_login,user_email,group_id,course_id);
            alert("called rjs");
        }
}
function learner_validation()
{
    login = document.getElementById('user_login');
    email = document.getElementById('user_email');
    learner = document.getElementById('learner_validation');
    if(login.value.split(' ').join('') != "" || email.value.split(' ').join('') != ""){
        learner.style.display = "block";
        learner.style.color = "red";
        return false;
    }
   return true;
}