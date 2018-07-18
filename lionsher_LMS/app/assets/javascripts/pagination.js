$(function () {
    // alert('DOM has loaded from pagination.');
    $(function () {
        $('.pagination a').live("click", function () {
            $('.pagination').html('Results are loading...');
            $.get(this.href, null, null, 'script');
            return false;
        });
    });
});  

function page_redirect(form_id)
{
    var form = document.getElementById(form_id);
    var index = form.select.selectedIndex;
    location = form.select.options[index].value;
}