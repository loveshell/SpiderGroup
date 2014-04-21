// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require ckeditor/override
//= require ckeditor/init
//= require_tree .


function post_id(id, route, rawtext, oktext)
{
	$.post("/"+route, { id: id}, function(data) {
	  if (data.errmsg) 
	  {
	  	$(".alert").html(data.errmsg);
	  	$(".alert").show();
        $(".notice").hide();
	  }
	  else
	  {
	  	$(".notice").html(data.notice);
	  	$(".notice").show();
        $(".alert").hide();
	  	$cid = $("#"+route+"_"+id);
	  	if($cid[0].innerHTML == rawtext)
	  	{
	  		$cid.html(oktext);
	  	}
	  	else
	  	{
	  		$cid.html(rawtext);	
	  	}
	  }

	});
}

function publish(id)
{
	post_id(id, "publish", "发布", "取消发布")
}

function favorite(id)
{
	post_id(id, "favorite", "收藏", "取消收藏")
}

function like(id)
{
	post_id(id, "like", "赞", "取消赞")
}

