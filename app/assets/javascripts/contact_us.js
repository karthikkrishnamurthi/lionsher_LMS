function validation()
{
var name=document.forms["contactusForm"]["home[name]"].value;
if (name==null || name=="")
  {
  alert("First name must be filled out");
  return false;
  }
var email_address=document.forms["contactusForm"]["home[email]"].value;
var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
if (email_address==null || email_address=="")
{
 alert("enter email address");
 return false;
}
else if(reg.test(email_address)== false)
  {
    alert("Enter valid email address");
    return false;
  }
 var comment=document.forms["contactusForm"]["home[comment]"].value;
if (comment==null || comment=="")
  {
  alert("Enter message");
  return false;
  }
}