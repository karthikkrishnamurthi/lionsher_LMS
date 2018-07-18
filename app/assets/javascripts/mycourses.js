function save_to_database(course_id)
{
    var SCOInstanceID = course_id;
    if (window.XMLHttpRequest)     // Object of the current windows
    {
        request = new XMLHttpRequest();     // Firefox, Safari, ...
    }
    else if (window.ActiveXObject)   // ActiveX version
    {
        request = new ActiveXObject("Microsoft.XMLHTTP");  // Internet Explorer
    }
    request.open('POST','/scorm/swf_save_to_db?SCOInstanceID='+SCOInstanceID,false);
    request.send(null);
}
