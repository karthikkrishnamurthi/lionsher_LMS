function change_paswrd()
  {
    var password_label_hide = document.getElementById('password_label_hide');
    var astriks = document.getElementById('astriks');
    var password_input = document.getElementById('password_input');
    var password_label_display = document.getElementById('password_label_display');
    var change_password_link= document.getElementById('change_password_link');
    var check_box= document.getElementById('check_box');
    var checkbox_label= document.getElementById('checkbox_label');
    password_label_hide.style.display = "none";
    astriks.style.display = "none";
    password_input.style.display = "block";
    password_input.style.border = "1px solid #cccccc";
    password_input.setAttribute('style','display:block;margin-bottom:8px;border:1px solid #cccccc;');
    password_label_display.style.display = "block";
    change_password_link.style.display = "none";
    check_box.style.display = "block";
    checkbox_label.style.display = "block";
  }
  function show_password()
  {
    var check_box = document.getElementById('check_box');
    var password_feild = document.getElementById('password_input');
    if(check_box.checked)
    {
      password_feild.type= "text";
    }else
    {
      password_feild.type= "password";
    }
  }