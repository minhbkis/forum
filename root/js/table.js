jQuery(document).ready(function($){
    $.each($('.post li'), function(){
        var li_height = $(this).height();
        $(this).find('.col1 input,.col3 p,.col4 img').css({
            'display':'block',
            'position':'absolute',
            'top':li_height/2 - 7+'px',
            'left':'14px'
        });
        $(this).find('> div').css({
            'height':li_height+'px',
		'border-right':'1px solid white',
		'line-height' : li_height+'px'
        });
    });

    //border
    //    $('.table li').find('div:last').css({'border':'none'});

    //Ðánh màu cho các hàng xem k?
    $('.table li:odd').css({'background':'white'});
});