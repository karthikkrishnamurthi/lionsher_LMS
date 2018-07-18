function css_browser_selector(u){
    var ua=u.toLowerCase(),is=function(t){
        return ua.indexOf(t)>-1
    },g='gecko',w='webkit',s='safari',o='opera',m='mobile',h=document.documentElement,b=[(!(/opera|webtv/i.test(ua))&&/msie\s(\d)/.test(ua))?('ie ie'+RegExp.$1):is('firefox/2')?g+' ff2':is('firefox/3.5')?g+' ff3 ff3_5':is('firefox/3.6')?g+' ff3 ff3_6':is('firefox/3')?g+' ff3':is('gecko/')?g:is('opera')?o+(/version\/(\d+)/.test(ua)?' '+o+RegExp.$1:(/opera(\s|\/)(\d+)/.test(ua)?' '+o+RegExp.$2:'')):is('konqueror')?'konqueror':is('blackberry')?m+' blackberry':is('android')?m+' android':is('chrome')?w+' chrome':is('iron')?w+' iron':is('applewebkit/')?w+' '+s+(/version\/(\d+)/.test(ua)?' '+s+RegExp.$1:''):is('mozilla/')?g:'',is('j2me')?m+' j2me':is('iphone')?m+' iphone':is('ipod')?m+' ipod':is('ipad')?m+' ipad':is('mac')?'mac':is('darwin')?'mac':is('webtv')?'webtv':is('win')?'win'+(is('windows nt 6.0')?' vista':''):is('freebsd')?'freebsd':(is('x11')||is('linux'))?'linux':'','js'];
    c = b.join(' ');
    h.className += ' '+c;
    return c;
};
css_browser_selector(navigator.userAgent);

function textCounter(field,cntfield,maxlimit) {
    if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
    // otherwise, update 'characters left' counter
    else
        cntfield.value = maxlimit - field.value.length;
}

function next_question(i,ques_type,button_type,skip_question)
{    
    var j,answer_id,k = 0,selected = 0,not_numeric=0;
    var error_message = document.getElementById("error_msg");
    var num_err_msg = document.getElementById("mtf_number_error_msg");
    var answers = new Array();
    var answer_list = document.getElementById('answer_list');
    for(j=1;j<=i;j++)
    {
        answer_id = document.getElementById('ans_'+j);
        switch(ques_type)
        {
            case "MCQ":
            {
                if(answer_id.checked==true)
                {
                    answers = answer_id.value;
                    selected = 1;
                    break;
                }
            }
            break;
            case "MAQ":
            {
                if(answer_id.checked == true)
                {
                    answers[k] = answer_id.value;
                    selected = 1;
                    k = k + 1;
                }
            }
            break;
            case "MTF":
            {
                if(answer_id.value.split(' ').join('') != "")
                {
                    var str = "[1-"+i+"]";
                    var exp1 = new RegExp(str);
                    if(answer_id.value.match(exp1)) {
                        selected = 1;
                        answers[k] = answer_id.value;
                        k = k + 1;
                    }
                    else {
                        selected = 1;
                        not_numeric = 1;
                    }
                }
                else
                {
                    selected = 0;
                    answers[k] = '';
                    k = k + 1;
                }
            }
            break;
            default:
            {
                if(answer_id.value.split(' ').join('') != "")
                {
                    answers = answer_id.value;
                    selected = 1;
                    break;
                }
            }
        }
    }
    if((button_type == "next" || button_type == "submit") && selected == 0)
    {
        if((button_type == "next" || button_type == "submit") && selected == 0 && skip_question == "true")
        {
            num_err_msg.style.display = "none";
            error_message.style.display = "none";
        } else if((button_type == "next" || button_type == "submit") && selected == 0 && skip_question == "false")
{
            num_err_msg.style.display = "none";
            error_message.style.display = "block";
        }
    }
    else if(selected == 1 && not_numeric == 1)
    {
        error_message.style.display = "none";
        num_err_msg.style.display = "block";
    }
    else
    {
        answer_list.value = answers;        
    }
    var disable_navigation_buttons = document.getElementById('navigation_buttons');
    disable_navigation_buttons.style.display="none";
}

function reset_radio_buttons(i)
{
    for(j=1;j<=i;j++)
    {
        answer_id = document.getElementById('ans_'+j);
        if(answer_id.checked == true)
            answer_id.checked = false;
    }
}

function exit_confirmation(url,msg)
{
    var tag = document.getElementById('exit_exam');
    if (confirm(msg))
    {
        tag.href = url;
        document.form_test_pattern.submit();
    }
//    tag.href = (confirm("Are you sure you want to exit the current test ?"))?url:"";
}

function validate_mark(max_mark)
{
    answer_id = document.getElementById('ans_id');
    if (parseInt(answer_id.value) <= parseInt(max_mark)){
        return true;
    } else{
        return false;
    }
}
