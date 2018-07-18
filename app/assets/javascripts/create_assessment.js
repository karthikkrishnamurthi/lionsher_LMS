function validation()
{
    var assessment_name = document.getElementById("question_bank_name");
    var name_msg = document.getElementById("name_msg");
    var topic_name = document.getElementById("topic");
    var topic_name_msg = document.getElementById("topic_name_msg");
    var single_type = document.getElementById("single_type");
    var multiple_type = document.getElementById("multiple_type");
    var radio_manual = document.getElementById("manual_type");
    var radio_excel = document.getElementById("excel_type");
    var radio_prev = document.getElementById("previous_type");
    var radio_check_msg = document.getElementById("radio_check_msg");
    var single_prev_assessments = document.getElementsByName("radio_check");
    var multiple_prev_assessments = document.getElementsByName("checkbox_check");
    var checked = 0;
    if (assessment_name.value.split(' ').join('') == "") {
        topic_name_msg.style.display = "none";
        name_msg.style.display = "block";
        name_msg.style.color = "red";
        return false;
    }
    else if(radio_prev.checked == true) {
        if(single_type != null && single_type.checked == true){
            for(var i=1;i<=single_prev_assessments.length;i++){
                var single_radio = document.getElementById("single_"+i);
                if(single_radio.checked == true){
                    checked = 1;
                    break;
                }
            }
        } else if(multiple_type != null && multiple_type.checked == true){
            for(var j=1;j<=multiple_prev_assessments.length;j++){
                var multiple_checkbox = document.getElementById("checkbox_check_"+j);
                if(multiple_checkbox.checked == true){
                    checked = 1;
                    break;
                }
            }
        }
        if(checked == 0){
            return false;
        } else {
            assessment_name.disabled = false;
            topic_name.disabled = false;
            return true;
        }
    }
    else if(radio_manual.checked == false && radio_excel.checked == false && radio_prev.checked == false) {
        name_msg.style.display = "none";
        topic_name_msg.style.display = "none";
        radio_check_msg.style.display = "block";
        return false;
    }
    else if(multiple_type.checked == true && radio_prev.checked == false && topic_name.value.split(' ').join('') == "") {
        name_msg.style.display = "none";
        topic_name_msg.style.display = "block";
        topic_name_msg.style.color = "red";
        return false;
    }  
    else {
        topic_name_msg.style.display = "none";
        name_msg.style.display = "none";
        radio_check_msg.style.display = "none";
        assessment_name.disabled = false;
        topic_name.disabled = false;
        return true;
    //        return false;
    }
}

function textCounter(field,cntfield,maxlimit) {
    if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
    // otherwise, update 'characters left' counter
    else
        cntfield.value = maxlimit - field.value.length;
}

function take_topic_name()
{
    var single_type = document.getElementById("single_type");
    var multiple_type = document.getElementById("multiple_type");
    var radio_prev = document.getElementById("previous_type");
    var field = document.getElementById("topic_name");
    if(multiple_type.checked == true)
    {
        if(radio_prev.checked == true) {
            show_previous_assmts("previous_questions")
        } else {
            field.style.display = "block";
        }                
    }
    if(single_type.checked == true)
    {
        if(radio_prev.checked == true) {
            show_previous_assmts("previous_questions")
        }
        field.style.display = "none";
    }    
}

function total_no_of_checks(j)
{
    upload_bar = document.getElementById("progress_bar");
    upload_bar.style.display = "block";
    var total_prev_qb_checked = document.getElementById('total_prev_qb_checked');
    for(var i=1;i<=j;i++)
    {
        var chk_box = document.getElementById('checkbox_check_'+i);
        if(chk_box.checked == true)
        {
            total_prev_qb_checked.value = total_prev_qb_checked.value + "," + chk_box.value;
        }
    }

}
function show_previous_assmts(val)
{
    var single_type = document.getElementById("single_type");
    var multiple_type = document.getElementById("multiple_type");
    var topic = document.getElementById("topic");
    var previous_assessments_for_single = document.getElementById('previous_assessments_for_single');
    var previous_assessments_for_multiple = document.getElementById('previous_assessments_for_multiple');
    var field = document.getElementById("topic_name");
    var upload_excel = document.getElementById('upload_excel');
    if(val == "previous_questions" && single_type != null && single_type.checked == true)
    {
        field.style.display = "none";
        previous_assessments_for_single.style.display = "block";
        previous_assessments_for_multiple.style.display = "none";
        upload_excel.style.display = "none";
    }
    else if(val == "previous_questions" && multiple_type != null && multiple_type.checked == true)
    {
        field.style.display = "none";
        previous_assessments_for_multiple.style.display = "block";
        previous_assessments_for_single.style.display = "none";
        topic.disabled = true;
        topic.style.color = "gray";
        upload_excel.style.display = "none";
    }
    else if(val == "excelsheet")
    {
        upload_excel.style.display = "block";
        previous_assessments_for_multiple.style.display = "none";
        previous_assessments_for_single.style.display = "none";
    }
    else if(val == "manual" && single_type != null && single_type.checked == true)
    {
        field.style.display = "none";
        upload_excel.style.display = "none";
        previous_assessments_for_multiple.style.display = "none";
        previous_assessments_for_single.style.display = "none";
    }
    else
    {
        field.style.display = "block";
        previous_assessments_for_single.style.display = "none";
        previous_assessments_for_multiple.style.display = "none";
        topic.disabled = false;
        upload_excel.style.display = "none";
    }
}

function show_browse(val,div)
{
    var div = document.getElementById(div);
    if(val.checked == true && val.value=="excelsheet")
    {
        div.style.display = "block";
    }
    else
    {
        div.style.display = "none";
        remove_add.style.display = "block";
    }
}

function none_checked()
{
    var  myoption = -1;
    var i;
    for (i=document.myform.assessment_type.length-1; i > -1; i--)
    {
        if (document.myform.assessment_type[i].checked)
        {
            myoption = i;
            i = -1;
        }
    }
    if (myoption == -1)
    {
        return false;
    }
    return true;

}
function form_validate()
{
    if(document.getElementById('question_bank_name').value.split(' ').join('') == "")
    {
        document.getElementById('question_bank_name_error').style.display="block";

        return false;
    }
    else if(document.getElementById('multiple_type').checked == true)
    {
        if(document.getElementById('topic').value.split(' ').join('') == "")
        {
            document.getElementById('topic_error').style.display="block";
            return false;
        }

    }
    else if(none_checked() == false)
    {
        return false;
    }
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
        (document.getElementById(ctr1).value.split(' ').join('') == "0"))
        {
        document.getElementById(ctr2).style.display = "block";
        return false;
    } else {
        document.getElementById(ctr2).style.display = "none";
        return true;
    }
}