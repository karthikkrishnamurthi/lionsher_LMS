//TODO : Ajax for cross browsers

function give_feedback(val) {
    request = new AjaxRequest();
    request.open('POST','/courses/set_feedback?feedback='+val,false);
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

function textCounter(field,cntfield,maxlimit) {
    if (field.value.length > maxlimit) // if too long...trim it!
        field.value = field.value.substring(0, maxlimit);
    // otherwise, update 'characters left' counter
    else
        cntfield.value = maxlimit - field.value.length;
}

function star_click(n)
{
    var image_star_1= document.getElementById('image_star_1');
    var image_star_2= document.getElementById('image_star_2');
    var image_star_3= document.getElementById('image_star_3');
    var image_star_4= document.getElementById('image_star_4');
    var image_star_5= document.getElementById('image_star_5');
    var star_1 = document.getElementById('star_1');
    var star_2 = document.getElementById('star_2');
    var star_3 = document.getElementById('star_3');
    var star_4 = document.getElementById('star_4');
    var star_5 = document.getElementById('star_5');
    var feedback_rating= document.getElementById("feedback_rating");
    if(n=='1')
    {
//        image_star_1.style.background = "url('/../images/star_fill.png') no-repeat";
         image_star_1.src = "../../assets/star_fill.png";
        image_star_2.src = "../../assets/star_unfill.png";
        image_star_3.src = "../../assets/star_unfill.png";
        image_star_4.src = "../../assets/star_unfill.png";
        image_star_5.src = "../../assets/star_unfill.png";
        feedback_rating.value='1';
        star_1.style.color = "black";
        star_2.style.color = "gray";
        star_3.style.color = "gray";
        star_4.style.color = "gray";
        star_5.style.color = "gray";
    }
    if(n=='2')
    {
        image_star_1.src = "../../assets/star_fill.png";
        image_star_2.src = "../../assets/star_fill.png";
        image_star_3.src = "../../assets/star_unfill.png";
        image_star_4.src = "../../assets/star_unfill.png";
        image_star_5.src = "../../assets/star_unfill.png";
        feedback_rating.value='2';
        star_1.style.color = "gray";
        star_2.style.color = "black";
        star_3.style.color = "gray";
        star_4.style.color = "gray";
        star_5.style.color = "gray";
    }
    else if(n=='3')
    {
        image_star_1.src = "../../assets/star_fill.png";
        image_star_2.src = "../../assets/star_fill.png";
        image_star_3.src = "../../assets/star_fill.png";
        image_star_4.src = "../../assets/star_unfill.png";
        image_star_5.src = "../../assets/star_unfill.png";
        feedback_rating.value='3';
        star_1.style.color = "gray";
        star_2.style.color = "gray";
        star_3.style.color = "black";
        star_4.style.color = "gray";
        star_5.style.color = "gray";
    }
    else if(n=='4')
    {
        image_star_1.src = "../../assets/star_fill.png";
        image_star_2.src = "../../assets/star_fill.png";
        image_star_3.src = "../../assets/star_fill.png";
        image_star_4.src = "../../assets/star_fill.png";
        image_star_5.src = "../../assets/star_unfill.png";
        feedback_rating.value='4';
        star_1.style.color = "gray";
        star_2.style.color = "gray";
        star_3.style.color = "gray";
        star_4.style.color = "black";
        star_5.style.color = "gray";
    }

    else if(n=='5')
    {
        image_star_1.src = "../../assets/star_fill.png";
        image_star_2.src = "../../assets/star_fill.png";
        image_star_3.src = "../../assets/star_fill.png";
        image_star_4.src = "../../assets/star_fill.png";
        image_star_5.src = "../../assets/star_fill.png";
        feedback_rating.value='5';
        star_1.style.color = "gray";
        star_2.style.color = "gray";
        star_3.style.color = "gray";
        star_4.style.color = "gray";
        star_5.style.color = "black";
    }
}

function validation() {
    var image_type_div = document.getElementById('image_type_div');
    image_type_div.style.display = "none";
    return true;
}