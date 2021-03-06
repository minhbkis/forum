package forum::Controller::Thread;
use Moose;
use namespace::autoclean;
use 5.010;
use DateTime;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::Thread - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path{
    my($self, $c, $index, $action, $thread_id) = @_;
    my $template = 'forum_thread.html';
    my $now = DateTime->now->ymd." ".DateTime->now->hms;
    my $params = $c->req->params;
    my @err;
    
    #check input params
    if(!$c->user_exists){#no user
	$c->response->redirect($c->uri_for('/admin'));
    }

    #check valid url
    if(!defined($action) || ($action ne 'new' && $action ne 'edit' && $action ne 'delete') || (($action eq 'edit' || $action eq 'delete') && (!defined($c->req->method) || lc $c->req->method ne 'post') && (!defined($thread_id) || $thread_id !~ /^([1-9]+[0-9]*,)*[1-9]+[0-9]*$/))){
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
		    my $actived = 1;
		    my $created_thread;
		    if(!defined($params->{page_site}) || $params->{page_site} ne 'forum'){$actived = $params->{actived}}
		    my %submited_thread = (
			topic_id => $params->{topic_id},
			user_id => $c->user->get('id'),
			title => $params->{title},
			description => $params->{description},
			created_date => $now,
			actived => $actived
			);
		    
		    #add new thread
		    if($action eq 'new'){
			$created_thread = $c->model('forum::Thread')->create(\%submited_thread);
			
			#also add a post too
			my $user_id = 0;
			if($c->user_exists){$user_id = $c->user->get('id')}
			my %submited_post = (
			    thread_id => $created_thread->id,
			    user_id => $user_id,
			    title => $params->{title},
			    content => $params->{content},
			    last_modifed => $now,
			    );
			$c->model('forum::Post')->create(\%submited_post);

			if(!defined($params->{page_site}) || $params->{page_site} ne 'forum'){
			    $c->response->redirect($c->uri_for('/admin/thread/1'));
			}else{
			    $c->response->redirect($c->uri_for('/forum/thread/').$params->{topic_id})."/1";
			}
		    }
		    
		    #edit thread
		    if($action eq 'edit'){
			$c->model('forum::Thread')->search({id => $params->{id}})->update(\%submited_thread);
			$c->response->redirect($c->uri_for('/admin/thread/1'));
		    }
		}
	    }else{
		$c->stash(topic_id => $params->{topic_id}, errs => \@err);
		$template = 'forum_thread_form.html';
	    }
	}else{#form is not submit : new topic first visit, edit topic first  or delete topic

	    $c->stash(page_name => 'thread', page_type => 'form');#set page type for display menu etc...

	    if(!defined($thread_id)){$template = 'admin_thread_form.html'}
	    else{$template = 'forum_thread_form.html'}
	    
	    if($action eq 'new'){#if action is 'new' $thread_id is know as $topic_id
		$c->stash(topic_id => $thread_id);
		$c->stash(topics => $c->model('forum::Topic'));
	    }
	    elsif($action eq 'edit'){
		$c->stash(topics => $c->model('forum::Topic'));
		$c->stash(thread_edit => $c->model('forum::Thread')->search({id => $thread_id}));
	    }elsif($action eq 'delete'){#delete topic
		#$thread_id must be an string type 1,2,3,4
		my @delete_id_list = split /,/,$thread_id;
		foreach(@delete_id_list){
		    $c->model('forum::Thread')->search({id => $_})->delete();
		}
		$c->response->redirect($c->uri_for('/admin/thread/1'));
	    }
	}
    }
    $c->stash(template => $template);
}


=head1 AUTHOR

minhbkpro

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
