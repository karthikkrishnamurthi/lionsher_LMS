function destroy(url,id) {
    var tag = document.getElementById('destroy_course');
    if (confirm('Are you sure?')) {
        tag.href = url;
        return true;
    } else {
        tag.href = id;
        return false;
    }
}

function validation(name,error_div_name)
{
    var topic_name = document.getElementById(name);
    var topic_name_msg = document.getElementById(error_div_name);
    if(topic_name.value.split(' ').join('') == "") {
        topic_name_msg.style.display = "block" ;
        topic_name_msg.style.color = "red";
        return false;
    } else {
        topic_name.disabled = false;
        return true;
    }
}

function scoring_validation()
{
    var correct_ans_points = document.getElementById("assessment_correct_ans_points");
    var wrong_ans_points = document.getElementById("assessment_wrong_ans_points");
    var correct_point_blank_msg = document.getElementById("correct_point_blank");
    var wrong_point_blank_msg = document.getElementById("wrong_point_blank");
    var pass_score = document.getElementById('assessment_pass_score');
    var pass_score_larger_div = document.getElementById("pass_score_larger_div");
    var total_marks_field = document.getElementById('total_marks');
    var total_selected_questions = document.getElementById("total_quest_result");
    var total_questions = document.getElementById("total_number_of_questions");
    var total_mark_multi_error_label = document.getElementById("total_mark_multi_error");
    var error_message_value = document.getElementById("total_mark_result_in_error");
    var total_mark_multi_zero_error = document.getElementById("total_mark_multi_zero_error");
    if(parseInt(pass_score.value) > parseInt(total_marks_field.value)) {
        pass_score_larger_div.style.display = "block";
        pass_score_larger_div.style.color = "red";
        correct_point_blank_msg.style.display = "none" ;
        wrong_point_blank_msg.style.display = "none" ;
        total_mark_multi_error_label.style.display = "none";
        return false;
    } else if(parseInt(total_selected_questions.value) > parseInt(total_questions.value)) {
        error_message_value.innerHTML = total_questions.value;
        total_mark_multi_error_label.style.display = "block";
        total_mark_multi_error_label.style.color = "red";
        correct_point_blank_msg.style.display = "none" ;
        pass_score_larger_div.style.display = "none";
        wrong_point_blank_msg.style.display = "none" ;
        return false;
    } else if(parseInt(total_selected_questions.value) == 0) {
        total_mark_multi_zero_error.style.display = "block";
        total_mark_multi_zero_error.style.color = "red";
        correct_point_blank_msg.style.display = "none" ;
        pass_score_larger_div.style.display = "none";
        wrong_point_blank_msg.style.display = "none" ;
        total_mark_multi_error_label.style.display = "none";
        return false;
    } else if(correct_ans_points.value.split(' ').join('') == "") {
        correct_point_blank_msg.style.display = "block" ;
        correct_point_blank_msg.style.color = "red";
        pass_score_larger_div.style.display = "none";
        wrong_point_blank_msg.style.display = "none" ;
        total_mark_multi_error_label.style.display = "none";
        return false;
    } else if(wrong_ans_points.value.split(' ').join('') == "") {
        wrong_point_blank_msg.style.display = "block" ;
        wrong_point_blank_msg.style.color = "red";
        pass_score_larger_div.style.display = "none";
        correct_point_blank_msg.style.display = "none" ;
        total_mark_multi_error_label.style.display = "none";
        return false;
    }else if((parseInt(pass_score.value) <= parseInt(total_marks_field.value)) &&
        (correct_ans_points.value.split(' ').join('') != "") &&
        (wrong_ans_points.value.split(' ').join('') != "")) {
        pass_score_larger_div.style.display = "none";
        correct_point_blank_msg.style.display = "none" ;
        wrong_point_blank_msg.style.display = "none" ;
        total_mark_multi_error_label.style.display = "none";
        return true;
    } else {
        return true;
    }
}

function schedule_validation()
{
    var duration_blank_div = document.getElementById("duration_blank_div");
    if((document.getElementById('duration_hour').value == 0) &&
        (document.getElementById('duration_min').value == 0))
        {
        duration_blank_div.style.display = "block";
        duration_blank_div.style.color = "red";
        return false;
    } else {
        return true;
    }
}

function assessment_details_validation()
{
    var duration_blank_div = document.getElementById("duration_blank_div");
    var assessment_blank_div = document.getElementById("assessment_blank_div");
    var blank_check_div = document.getElementById("blank_check_div");
    var pass_score = document.getElementById('assessment_pass_score');
    var pass_score_larger_div = document.getElementById("pass_score_larger_div");
    var total_marks_field = document.getElementById('total_marks');
    if(!(document.getElementById('assessment_name').value.split(' ').join('') == "") &&
        (parseInt(pass_score.value) <= parseInt(total_marks_field.value)) && schedule_validation())
        {
        duration_blank_div.style.display = "none";
        assessment_blank_div.style.display = "none";
        pass_score_larger_div.style.display = "none";
        blank_check_div.style.display = "none";
        return true;
    } else if(parseInt(pass_score.value) > parseInt(total_marks_field.value)){
        duration_blank_div.style.display = "none";
        blank_check_div.style.display = "none";
        assessment_blank_div.style.display = "none";
        pass_score_larger_div.style.display = "block";
        pass_score_larger_div.style.color = "red";
        return false;
    } else if(document.getElementById('assessment_name').value.split(' ').join('') == ""){
        duration_blank_div.style.display = "none";
        pass_score_larger_div.style.display = "none";
        blank_check_div.style.display = "none";
        assessment_blank_div.style.display = "block";
        assessment_blank_div.style.color = "red";
        return false;
    } else if(!schedule_validation()) {
        pass_score_larger_div.style.display = "none";
        blank_check_div.style.display = "none";
        assessment_blank_div.style.display = "none";
        duration_blank_div.style.display = "block";
        duration_blank_div.style.color = "red";
        return false;
    } else {
        pass_score_larger_div.style.display = "none";
        blank_check_div.style.display = "none";
        assessment_blank_div.style.display = "none";
        duration_blank_div.style.display = "none";
        return true;
    }
}

function calculate_total_mark(total_question) {
    var correct_ans_poins = document.getElementById('assessment_correct_ans_points').value.split(' ').join('');
    var no_of_questions = document.getElementById('assessment_no_of_questions').value.split(' ').join('');
    var total_marks_field = document.getElementById('total_marks');
    if(correct_ans_poins != "" && no_of_questions != "") {
        var total_mark = parseInt(correct_ans_poins) * parseInt(no_of_questions);
        total_marks_field.value = total_mark;
    } else if(correct_ans_poins != "" && no_of_questions == "") {
        total_marks_field.value = parseInt(correct_ans_poins) * total_question;
    } else {
        total_marks_field.value = total_question;
    }
}

function textCounter(field,cntfield,maxlimit) {
    if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
    // otherwise, update 'characters left' counter
    else
        cntfield.value = maxlimit - field.value.length;
}

function number_check(input_id,div_id,value) {
    var exp1 = /^[0-9]+$/;
    var div = document.getElementById(div_id);
    var assessment_div = document.getElementById(input_id);
    var length_div = document.getElementById("length_check_div");
    if(assessment_div.value > value){
        div.style.display = "none";
        length_div.style.display = "block";
        length_div.style.color = "red";
        length_div.setAttribute("style", "display: block;color: red;margin:0px 0px 0px 0px;");
        return false;
    }
    if ((assessment_div.value.match(exp1)) ||
        (assessment_div.value.split(' ').join('') == "")) {
        length_div.style.display = "none";
        div.style.display = "none";
        calculate_total_mark(value);
        return true;
    } else {
        length_div.style.display = "none";
        div.style.display = "block";
        div.style.color = "red";
        div.setAttribute("style", "display: block;color: red;margin:0px 0px 0px 0px;");
        return false;
    }
}

function display_demographic_list(checkbox){
    var demographics_list_div = document.getElementById("demographics_list");
    if(checkbox.checked){
        demographics_list_div.style.display = "block";
    } else {
        demographics_list_div.style.display = "none";
    }
    
}

function display_pass_score(checkbox){
    var pass_score_div = document.getElementById("pass_score");
    if(checkbox.checked){
        pass_score_div.style.display = "block";
    } else {
        pass_score_div.style.display = "none";
    }

}

function destroy(url,id) {
    var tag = document.getElementById('destroy_course');
    if (confirm('Are you sure?')) {
        tag.href = url;
        return true;
    } else {
        tag.href = id;
        return false;
    }
}

function ena(object)
{
    var obj = document.getElementById(object);
    obj.disabled = false;
}

function disa(object)
{
    var obj = document.getElementById(object);
    obj.disabled = true;
}

function show_div(object,div_id)
{
    var div = document.getElementById(div_id);
    if(object.checked == true) {
        div.style.display = "block";
    } else {
        div.style.display = "none";
    }
}

function ShowPopup(hoveritem)
{
    hp = document.getElementById("hoverpopup");
    // Set position of hover-over popup
    hp.style.top = hoveritem.offsetTop + 18;
    hp.style.left = hoveritem.offsetLeft + 0;
    // Set popup to visible
    hp.style.visibility = "Visible";
}
function HidePopup()
{
    hp = document.getElementById("hoverpopup");
    hp.style.visibility = "Hidden";
}