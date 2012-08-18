package forum::Controller::Post;
use Moose;
use namespace::autoclean;
use 5.010;
use DateTime;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path{
    my($self, $c, $index, $action, $post_id, $page_site, $page) = @_;
    my $template = 'forum_post.html';
    my $now = DateTime->now->ymd." ".DateTime->now->hms;
    my $params = $c->req->params;
    my @err;
    
    #check input params
    if(!$c->user_exists){#no user
	$c->response->redirect($c->uri_for('/admin'));
    }

    #check valid url
    if(!defined($action) || ($action ne 'new' && $action ne 'edit' && $action ne 'delete') || (($action eq 'edit' || $action eq 'delete') && (!defined($c->req->method) || lc $c->req->method ne 'post') && (!defined($post_id) || $post_id !~ /^([1-9]+[0-9]*,)*[1-9]+[0-9]*$/))){
	if($c->user->get('role') == 0){
	    $c->response->redirect($c->uri_for('/admin'));
	}else{
	    $c->response->redirect($c->uri_for('/forum'));
	}
    }
    else{
	if(defined($c->req->method) && lc $c->req->method eq 'post'){#form is submited
	    if($params->{title} eq ''){push @err, 'you must input title'}
	    if($params->{content} eq ''){push @err, 'you must input content'}
	    if(!defined(@err) || @err == 0){
		if($action eq 'new' || $action eq 'edit'){
		    my $user_id = 0;
		    if($c->user_exists){$user_id = $c->user->get('id')}

		    #execute content
		    my $content = $params->{content};
		    $content =~ s/<.+?>//g;
		    $content =~ s/(\bhttps?.+\b\/?)/<a href="$1">$1<\/a>/g;
		    $content =~ s/(\b\w+@\w+\.\w+\b)/<a href="mailto:$1">$1<\/a>/g;
		    
		    my %submited_post = (
			thread_id => $params->{thread_id},
			user_id => $user_id,
			title => $params->{title},
			content => $content,
			last_modifed => $now,
			);
		    if($action eq 'new'){$submited_post{'created_date'} = $now;}
		    
		    #add new post
		    if($action eq 'new'){
			$c->model('forum::Post')->create(\%submited_post);
			if(!defined($params->{page_site})){
			    $c->response->redirect($c->uri_for('/admin/post/1'));
			}else{
			    $c->response->redirect($c->uri_for('/forum/post/').$params->{thread_id}."/1");
			}
		    }
		    
		    #edit post
		    if($action eq 'edit'){
			$c->model('forum::Post')->search({id => $params->{id}})->update(\%submited_post);
			if(!defined($params->{page_site}) || $params->{page_stie} eq 'admin'){
			    $c->response->redirect($c->uri_for('/admin/post/1'));
			}else{
			    $c->response->redirect($c->uri_for('/forum/post/').$params->{thread_id}."/".$page);
			}
		    }
		}
	    }else{
		$c->stash(thread_id => $params->{thread_id}, errs => \@err);
		$c->stash(threads => $c->model('forum::Thread'));
		$template = 'admin_post_form.html';
	    }
	}else{#form is not submit : new post first visit, edit post first  or delete post
	    $c->stash(page_name => 'post', page_type => 'form');#set page type for display menu etc...

	    if(!defined($page_site) && $page_site eq 'admin'){$template = 'admin_post_form.html'}
	    else{$template = 'forum_post_form.html'}
	    
	    if($action eq 'new'){#if action is 'new' $thread_id is know as $topic_id
		$c->stash(threads => $c->model('forum::Thread'));
	    }
	    elsif($action eq 'edit'){
		$c->stash(threads => $c->model('forum::Thread'));
		$c->stash(post_edit => $c->model('forum::Post')->search({id => $post_id}));
	    }elsif($action eq 'delete'){#delete topic
		#$post_id must be an string type 1,2,3,4
		my @delete_id_list = split /,/,$post_id;
		my $thread_id = 0;
		foreach(@delete_id_list){
		    $thread_id = $c->model('forum::Post')->search({id => $_})->first->thread_id;
		    $c->model('forum::Post')->search({id => $_})->delete();
		}
		if(!defined($page_site) || $page_site eq 'admin'){
		    $c->response->redirect($c->uri_for('/admin/post/1'));
		}else{
		    $c->response->redirect($c->uri_for('/forum/post/').$thread_id."/".$page);
		}
	    }
	}
    }
    $c->stash(template => $template);
}

__PACKAGE__->meta->make_immutable;

1;
