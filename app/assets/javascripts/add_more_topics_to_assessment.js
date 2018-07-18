
function add_more_topic()
{
    var div_id = document.getElementById('topic_name');
    var hidden_button = document.getElementById('hidden_submit');
    var submit_button = document.getElementById('question_bank_submit');
    div_id.style.display = "block";
    hidden_button.style.display = "block";
    submit_button.style.display = "none";
}
function add_more_topic_from_edit_question()
{
    var div_id2 = document.getElementById('topic_name')
    var div_id = document.getElementById('button_and_cancel');
    var hidden_button = document.getElementById('hidden_submit');
    var submit_button = document.getElementById('question_bank_submit');
    if(div_id2.style.display == "block")
        {
        div_id2.style.display = "none";
        div_id.style.display = "none";
        }
    else
        {
         div_id2.style.display = "block"; 
         div_id.style.display = "block";
         hidden_button.style.display = "block";
         submit_button.style.display = "none";
        }
    
}
function show_prev_questions(val,previous_assessments_for_multiple)
{
    var previous_assessments_for_multiple = document.getElementById('previous_assessments_for_multiple');
    var upload_excel = document.getElementById('upload_excel');
    if(val.value == "previous_questions" )
    {
        previous_assessments_for_multiple.style.display = "block";
        upload_excel.style.display = "none";
    }
    else if(val.value == "excelsheet")
    {
        previous_assessments_for_multiple.style.display = "none";
        upload_excel.style.display = "block";
    }
    else
    {
        previous_assessments_for_multiple.style.display = "none";
        upload_excel.style.display = "none";
    }

}
function total_no_of_checks(j)
{
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