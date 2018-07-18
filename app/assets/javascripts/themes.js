//TODO : Ajax for cross browsers

function change_color(color,text_color) {

    var head_div = document.getElementById("div_head");
    var org_div = document.getElementById("org");
    if(color == "ff9999") {
        head_div.style.backgroundColor = "#ff9999"; // shade of gray
        org_div.style.color = '#990000';
    } else if(color == "990033") {
        head_div.style.backgroundColor = "#990033"; // shade of blue
        org_div.style.color = '#ff9933';
    } else if(color == "99cc33") {
        head_div.style.backgroundColor = "#99cc33"; // shade of pink
        org_div.style.color = '#666633';
    } else if(color == "003300") {
        head_div.style.backgroundColor = "#003300"; // shade of green
        org_div.style.color = '#ffffff';
    } else if(color == "66ccff") {
        head_div.style.backgroundColor = "#66ccff"; // shade of purple
        org_div.style.color = '#000000';
    } else if(color == "000066") {
        head_div.style.backgroundColor = "#000066"; // shade of blue
        org_div.style.color = '#ffffff';
    }else if(color == "fff79a") {
        head_div.style.backgroundColor = "#fff79a"; // shade of blue
        org_div.style.color = '#000000';
    }else if(color == "ffcc33") {
        head_div.style.backgroundColor = "#ffcc33"; // shade of yellow
        org_div.style.color = '#000000';
    }else if(color == "ff9933") {
        head_div.style.backgroundColor = "#ff9933"; // shade of yellow
        org_div.style.color = '#663300';
    }else if(color == "ff6600") {
        head_div.style.backgroundColor = "#ff6600"; // shade of orange
        org_div.style.color = '#330000';
    }else if(color == "990066") {
        head_div.style.backgroundColor = "#990066"; // shade of orange
        org_div.style.color = '#ffffff';
    }else if(color == "330066") {
        head_div.style.backgroundColor = "#330066"; // shade of pink
        org_div.style.color = '#ffffff';
    }else if(color == "999999") {
        head_div.style.backgroundColor = "#999999"; // shade of pink
        org_div.style.color = '#000000';
    }else if(color == "000000") {
        head_div.style.backgroundColor = "#000000"; // shade of pink
        org_div.style.color = '#ffffff';
    }

    request = new AjaxRequest();
    request.open('POST','/courses/set_theme?text_color='+text_color+'&color='+color,false);
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