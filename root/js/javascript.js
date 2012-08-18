/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
jQuery(document).ready(function($){
    $('#menu ul li').hover(function(){
        $(this).find('ul:first').css({visibility: "visible", display: "none"}).slideDown(500);
    }, function(){
        $(this).find('ul:first').css({visibility: "hidden", display: "none"});
    });

    //form submit
    $('.save a').click(function(){
	    $('form').submit();
	});
    
    //list delete item
    $('.trash a').click(function(){
	    if(confirm("are you sure !")){
		var delete_id_list = '';
		$('.table li:not(.title)').each(function(){
			var val = $(this).find(':checkbox:checked').val();
			if(val != undefined){
			    if(delete_id_list == '')delete_id_list = val;
			    else delete_id_list += ','+val;
			}
		    });
		var new_location = window.location + "";
		var base_url = new_location.split("/")[2];
		new_location = "http://" + base_url + "/"+ $(this).attr('href') +"/index/delete/" + delete_id_list;
		window.location.href = new_location;
	    }	    
	});
    
    //auto load avatar when select
    $('input.avatar').change(function(){
	    var input = $(this)[0];
	    var file = input.files[0];
	    // load file into preview pane
	    var reader = new FileReader();
	    reader.onload = function(e){
		$('img.avatar-image').css({'display':'block'});
		$('img.avatar-image').attr('src', e.target.result);
	    }
	    reader.readAsDataURL(file);
	});

    //reply button
    $('#reply a').toggle(function(){
	    $('#reply form').show();
	},function(){
	    $('#reply form').hide();	    
	});

    //reply form
    $('#reply form').submit(function(){
	    return confirm('返信の確認？');
	});

    //admin post search
    $('#topic-id').change(function(){
	    $('form input[type=submit]').click();
	});
    $('#admin_content .paging a').click(function(){
	    var arr = $('form').attr('action').split('/');
	    var page_site = arr[3];
	    var page_name = arr[4];
	    var page = $(this).attr('href').split('/')[5];

	    $('form').attr('action', 'http://localhost:3000/'+page_site+'/'+page_name+'/'+page);
	    
	    $('form input[type=submit]').click();
	    
	    return false;
	});

    //edit a click
    $('.edit a').click(function(){
	    alert("編集のために、ユーザ名またはタイトルを選択してください");
	    return false;
	});

    //delete post
    $('.delete').click(function(){
	    return confirm("ポスト削除の確認？");
	});
    });