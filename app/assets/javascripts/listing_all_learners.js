function check_all(inactivated_users)
{
    for (i = 1 ; i <= inactivated_users ; i++)
    {
        var chk = document.getElementById('inactive_'+i);
        chk.checked =true;
    }
}

function uncheck_all(inactivated_users)
{
    for (i = 1 ; i <= inactivated_users ; i++)
    {
        var chk = document.getElementById('inactive_'+i);
        chk.checked =false;
    }
}
function validate(hidden_length,text_box_id)
{
    var inputs = document.getElementsByTagName("input");
    var length = document.getElementById(hidden_length).value;
    var text_box_ele = document.getElementById(text_box_id);
    var count = 0
    if (text_box_ele.value.split(' ').join('') == "")
    {
        return false;
    }
    else
    {
        for(var i=0;i<inputs.length;i++)
        {
            if((inputs[i].type == "checkbox") && (inputs[i].checked == true))
            {
                count = 1;
            }
        //            if (document.getElementByName(chklist[i]).checked == true)
        //            {
        //                count = 1;
        //            }
        }
        if (count == 1 )
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}