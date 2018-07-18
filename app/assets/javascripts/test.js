function test(user_id,selected){
    request = new AjaxRequest();
    request.open('POST','/courses/save_selected?quarter='+selected+'&user_id='+user_id,false);
    request.send(null);
}
function AjaxRequest() {
    var request;

    // Opera 8.0+, Firefox, Safari
    try {
        request = new XMLHttpRequest();
    }

    // Internet Explorer Browsers
    catch (tryIE) {
        try {
            request = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (tryOlderIE) {
            try {
                request = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch (failed) {
                alert("Error creating XMLHttpRequest");
            }
        }
    }
    return request;
}

 function courses(form_id)
{
    var form = document.getElementById(form_id);
    var index = form.select.selectedIndex;    
    location = form.select.options[index].value;
}