function change_div()
{
    var values = document.myform.Field1;
    for(var i=0;i<values.length;i++){
        var div_id = document.getElementById(values[i].value);
        if(values[i].selected == true){
            div_id.style.display = "block";
        } else {
            div_id.style.display = "none";
        }
    }
}

function textCounter(field,cntfield,maxlimit) {
    if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
    // otherwise, update 'characters left' counter
    else
        cntfield.value = maxlimit - field.value.length;
}

function showDiv(div_id) {
    div = div_id;
    if (document.getElementById) { // DOM3 = IE5, NS6
        if (document.getElementById(div).style.display == 'block'){
            document.getElementById(div).style.display = 'none';
        }
        else{
            document.getElementById(div).style.display = 'block';
        }
    }
}


function set_answer(field,radio_field)
{
    var text_field = document.getElementById(field);
    var radio = document.getElementById(radio_field);
    radio.value = text_field.value;
}
  
function select_ddl()
{
    var selected_question_type = document.getElementById('selected_question_type').value;
    if(selected_question_type == "")
    {
        document.myform.question_type[0].selected = true;
        change_div();
    }
    else
    {
        for (var i = 0; i < document.myform.question_type.length; i++)
        {
            if(document.myform.question_type[i].value == selected_question_type)
            {
                document.myform.question_type[i].selected = true;
                change_div();
            }
        }
    }
}

function form_validation()
{
    var selected_question_type = document.myform.question_type.value;
    var return_value = true;
    if(selected_question_type == "MCQ")
    {
        var mcq_question_field =document.getElementById('mcq_question_field');
        if (mcq_question_field.value == "")
        {
            return_value = false;
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_mcq');
            textarea_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_mcq');
            textarea_blank_msg.style.display = "none";
        }

        var options = 5;
        var selected = 0;
        for(var i=1;i<=5;i++)
        {
            var mcq_field = document.getElementById('mcq_field'+i);
            if(mcq_field.value != "")
            {
                var mcq_radio_field = document.getElementById('mcq_radio_field'+i);

                if(mcq_radio_field.checked == true)
                {
                    selected = 1;
                }
            }
            if(mcq_field.value == "")
            {
                options = options - 1;
            }
            
        }
        if((options == 0) || ((options > 0) && (options <2)) )
        {
            return_value = false;
            var option_blank_msg = document.getElementById('option_blank_msg_for_mcq');
            option_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var option_blank_msg = document.getElementById('option_blank_msg_for_mcq');
            option_blank_msg.style.display = "none";
        }
        if(selected == 0)
        {
            return_value = false;
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_mcq');
            radio_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_mcq');
            radio_blank_msg.style.display = "none";
        }
    }

    if(selected_question_type == "MAQ")
    {
        var mcq_question_field =document.getElementById('maq_question_field');
        if (mcq_question_field.value == "")
        {
            return_value = false;
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_maq');
            textarea_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_maq');
            textarea_blank_msg.style.display = "none";
        }

        var options = 5;
        var selected = 0;
        for(var i=1;i<=5;i++)
        {
            var mcq_field = document.getElementById('maq_field'+i);
            if(mcq_field.value != "")
            {
                var mcq_radio_field = document.getElementById('maq_radio_field'+i);

                if(mcq_radio_field.checked == true)
                {
                    selected = 1;
                }
            }
            if(mcq_field.value == "")
            {
                options = options - 1;
            }

        }
        if((options == 0) || ((options > 0) && (options <2)) )
        {
            return_value = false;
            var option_blank_msg = document.getElementById('option_blank_msg_for_maq');
            option_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var option_blank_msg = document.getElementById('option_blank_msg_for_maq');
            option_blank_msg.style.display = "none";
        }
        if(selected == 0)
        {
            return_value = false;
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_maq');
            radio_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_maq');
            radio_blank_msg.style.display = "none";
        }
    }

    if(selected_question_type == "MTF")
    {
        var mcq_question_field =document.getElementById('mtf_question_field');

        var options = 5;
        var selected = 5;
        for(var i=1;i<=5;i++)
        {
            var mcq_field = document.getElementById('mtf_field'+i);
            var mcq_radio_field = document.getElementById('mtf_radio_field'+i);

            if(mcq_radio_field.value == "")
            {
                selected = selected - 1;
            }
            if(mcq_field.value == "")
            {
                options = options - 1;
            }

        }
        if((options == 0) || ((options > 0) && (options <2)) )
        {
            return_value = false;
            var option_blank_msg = document.getElementById('option_blank_msg_for_mtf');
            option_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var option_blank_msg = document.getElementById('option_blank_msg_for_mtf');
            option_blank_msg.style.display = "none";
        }
        if((selected == 0) || ((selected > 0) && (selected <2)) )
        {
            return_value = false;
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_mtf');
            radio_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var radio_blank_msg = document.getElementById('radio_blank_msg_for_mtf');
            radio_blank_msg.style.display = "none";
        }
    }
    
    if(selected_question_type == "FIB")
    {
        var mcq_question_field =document.getElementById('fib_question_field');
        if (mcq_question_field.value == "")
        {
            return_value = false;
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_fib');
            textarea_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_fib');
            textarea_blank_msg.style.display = "none";
        }

        var options = 1;
        
        var mcq_field = document.getElementById('fib_field');
            
        if(mcq_field.value == "")
        {
            options = options - 1;
        }

        if(options == 0)
        {
            return_value = false;
            var radio_blank_msg = document.getElementById('option_blank_msg_for_fib');
            radio_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var radio_blank_msg = document.getElementById('option_blank_msg_for_fib');
            radio_blank_msg.style.display = "none";
        }
    }

    if(selected_question_type == "SA")
    {
        var mcq_question_field =document.getElementById('sa_question_field');
        if (mcq_question_field.value == "")
        {
            return_value = false;
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_sa');
            textarea_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var textarea_blank_msg = document.getElementById('textarea_blank_msg_for_sa');
            textarea_blank_msg.style.display = "none";
        }

        var options = 1;

        var mcq_field = document.getElementById('sa_field');

        if(mcq_field.value == "")
        {
            options = options - 1;
        }

        if(options == 0)
        {
            return_value = false;
            var radio_blank_msg = document.getElementById('option_blank_msg_for_sa');
            radio_blank_msg.style.display = "block";
            return return_value;
        }
        else
        {
            var radio_blank_msg = document.getElementById('option_blank_msg_for_sa');
            radio_blank_msg.style.display = "none";
        }
    }
    return return_value;
}