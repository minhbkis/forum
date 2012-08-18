package forum::Controller::Topic;
use Moose;
use namespace::autoclean;
use 5.010;
use DateTime;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::Topic - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


sub index :Path{
    my($self, $c, $index, $action, $topic_id) = @_;
    my $template = 'admin_topic.html';
    my $now = DateTime->now->ymd." ".DateTime->now->hms;
    my $params = $c->req->params;
    my @err;
    
    #check input params
    if(!$c->user_exists){#no user
	$c->response->redirect($c->uri_for('/admin'));
    }

    #check valid url
    if(!defined($action) || ($action ne 'new' && $action ne 'edit' && $action ne 'delete') || (($action eq 'edit' || $action eq 'delete') && (!defined($c->req->method) || lc $c->req->method ne 'post') && (!defined($topic_id) || $topic_id !~ /^([1-9]+[0-9]*,)*[1-9]+[0-9]*$/))){
	if($c->user->get('role') == 0){
	    $c->response->redirect($c->uri_for('/admin'));
	}else{
	    $c->response->redirect($c->uri_for('/forum'));
	}
    }
    else{
	if(defined($c->req->method) && lc $c->req->method eq 'post'){#form is submited
	    if($params->{title} eq ''){push @err, 'you must input title'}
	    if(!defined(@err) || @err == 0){
		if($action eq 'new' || $action eq 'edit'){
		    my %submited_topic = (
			user_id => $c->user->get('id'),
			title => $params->{title},
			description => $params->{description},
			created_date => $now,
			actived => $params->{actived}
			);
		    
		    #add new topic
		    if($action eq 'new'){
			$c->model('forum::Topic')->create(\%submited_topic);
			$c->response->redirect($c->uri_for('/admin/topic/1'));
		    }
		    
		    #edit user
		    if($action eq 'edit'){
			$c->model('forum::Topic')->search({id => $params->{id}})->update(\%submited_topic);
			$c->response->redirect($c->uri_for('/admin/topic/1'));
		    }
		}
	    }else{
		$c->stash(errs => \@err);
		$template = 'admin_topic_form.html';
	    }
	}else{#form is not submit : new topic first visit, edit topic first  or delete topic
	    $c->stash(page_name => 'topic', page_type => 'form');#set page type for display menu etc...
	    
	    $template = 'admin_topic_form.html';
	    if($action eq 'edit'){
		$c->stash(topic_edit => $c->model('forum::Topic')->search({id => $topic_id}));
	    }elsif($action eq 'delete'){#delete topic
		#$topic_id must be an string type 1,2,3,4
		my @delete_id_list = split /,/,$topic_id;
		foreach(@delete_id_list){
		    $c->model('forum::Topic')->search({id => $_})->delete();
		}
		$c->response->redirect($c->uri_for('/admin/topic/1'));
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
