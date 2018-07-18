function display_c(start){
    window.start = parseFloat(start);
    var end = 0 // change this to stop the counter at a higher value
    var refresh=1000; // Refresh rate in milli seconds
    if(window.start >= end ){
        mytime=setTimeout('display_ct()',refresh)
    }else {
        alert("Time Over ");
        document.form_assessment.submit();
    }
}
 
function format_number(number, length) {
    var str = '' + number;
    while (str.length < length) {
        str = '0' + str;
    }
    return str;
}

function display_ct() {
    // Calculate the number of days left
    var days=Math.floor(window.start / 86400);
    // After deducting the days calculate the number of hours left
    var hours = Math.floor((window.start - (days * 86400 ))/3600)
    // After days and hours , how many minutes are left
    var minutes = Math.floor((window.start - (days * 86400 ) - (hours *3600 ))/60)
    // Finally how many seconds left after removing days, hours and minutes.
    var secs = Math.floor((window.start - (days * 86400 ) - (hours *3600 ) - (minutes*60)))

    //var x = window.start + "(" + days + " Days " + hours + " Hours " + minutes + " Minutes and " + secs + " Secondes " + ")";
    var x = format_number(hours,2) + ":" + format_number(minutes,2) + ":" + format_number(secs,2);


    document.getElementById('ct').innerHTML = x;
    window.start= window.start- 1;

    check(minutes,secs);

    tt=display_c(window.start);
}

function check(minutes,secs)
{
    if(minutes==5 && secs==0)
        alert("You have only five minutes remaining");
    else if(minutes==1 && secs==0)
    {
        alert("You have only one minutes remaining");
    }
}