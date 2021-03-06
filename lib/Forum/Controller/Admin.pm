package forum::Controller::Admin;
use Moose;
use namespace::autoclean;
use 5.010;
use DateTime;
use Catalyst::Request::Upload;
use Email::Valid;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub author_check :Private {
    my ($self, $c) = @_;
    
    if(!$c->user_exists){
	$c->response->redirect($c->uri_for('/admin'));
    }
    elsif($c->user->get('role') != 0){
	$c->response->redirect($c->uri_for('/forum'));
    }
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    if($c->user_exists){
	if($c->user->get('role') == 0){$c->response->redirect($c->uri_for('/admin/user/1'))}
	else{$c->response->redirect($c->uri_for('/forum'))}
    }
    
    $c->stash(template => 'admin_login.html');
}

sub user :Local :Args(1){
    my($self, $c, $page) = @_;
    my $params = $c->req->params;
    my $users = $c->model('forum::User');

    $self->author_check($c);

    $c->stash(page_name => 'user', page_type => 'list');    
    
    $c->stash(template => 'admin_user.html');

    #get params from search
    if(defined($c->req->method) && lc $c->req->method eq 'post'){
	if($params->{username} ne ''){
	    $users = $users->search_like({username => '%'.$params->{username}.'%'});
	    $c->stash(username => $params->{username});
	}
	if($params->{user_type} != -1){
	    $users = $users->search({role => $params->{user_type}});
	    $c->stash(user_type => $params->{user_type});
	}
    }

    #render info for paging
    my $page_num = 1;
    my $user_num = $users->count;
    if($user_num % 10 == 0){$page_num = $user_num/10}
    else{$page_num = ($user_num - $user_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'admin', page_name => 'user');

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);

    $c->stash(users => $users->page($page));
}

sub topic :Local :Args(1){
    my($self, $c, $page) = @_;
    my $params = $c->req->params;
    my $topics = $c->model('forum::Topic');
    
    $self->author_check($c);
    
    $c->stash(page_name => 'topic', page_type => 'list');    
    
    $c->stash(template => 'admin_topic.html');

    #get params from search
    if(defined($c->req->method) && lc $c->req->method eq 'post'){
	if($params->{title} ne ''){
	    $topics = $topics->search_like({title => '%'.$params->{title}.'%'});
	    $c->stash(title => $params->{title});
	}
	if($params->{description} ne ''){
	    $topics = $topics->search_like({description => '%'.$params->{description}.'%'});
	    $c->stash(description => $params->{description});
	}
	if($params->{user_id} != 0){
	    $topics = $topics->search({user_id => $params->{user_id}});
	    $c->stash(user_id => $params->{user_id});
	}
    }

    my $page_num = 1;
    my $topic_num = $topics->count;
    if($topic_num % 10 == 0){$page_num = $topic_num/10}
    else{$page_num = ($topic_num - $topic_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'admin', page_name => 'topic');

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);

    $c->stash(topics => $topics->page($page));

    $c->stash(users => $c->model('forum::User'));
}

sub thread :Local :Args(1){
    my($self, $c, $page) = @_;
    my $params = $c->req->params;
    my $threads = $c->model('forum::Thread');
    
    $self->author_check($c);
    
    $c->stash(page_name => 'thread', page_type => 'list');
    
    $c->stash(template => 'admin_thread.html');

    #get params from search
    if(defined($c->req->method) && lc $c->req->method eq 'post'){
	if($params->{title} ne ''){
	    $threads = $threads->search_like({title => '%'.$params->{title}.'%'});
	    $c->stash(title => $params->{title});
	}
	if($params->{description} ne ''){
	    $threads = $threads->search_like({description => '%'.$params->{description}.'%'});
	    $c->stash(description => $params->{description});
	}
	if($params->{user_id} != 0){
	    $threads = $threads->search({user_id => $params->{user_id}});
	    $c->stash(user_id => $params->{user_id});
	}
	if($params->{topic_id} != 0){
	    $threads = $threads->search({topic_id => $params->{topic_id}});
	    $c->stash(topic_id => $params->{topic_id});
	}
    }

    my $page_num = 1;
    my $thread_num = $threads->count;
    if($thread_num % 10 == 0){$page_num = $thread_num/10}
    else{$page_num = ($thread_num - $thread_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'admin', page_name => 'thread');

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);

    $c->stash(threads => $threads->page($page));

    $c->stash(topics => $c->model('forum::Topic'));
    
    $c->stash(users => $c->model('forum::User'));
}

sub post :Local {
    my($self, $c, $page) = @_;
    my $params = $c->req->params;
    my $posts = $c->model('forum::Post');
    
    $self->author_check($c);
    
    $c->stash(page_name => 'post', page_type => 'list');
    
    $c->stash(template => 'admin_post.html');

    #get params from search
    if(defined($c->req->method) && lc $c->req->method eq 'post'){
	if($params->{title} ne ''){
	    $posts = $posts->search_like({title => '%'.$params->{title}.'%'});
	    $c->stash(title => $params->{title});
	}
	if($params->{content} ne ''){
	    $posts = $posts->search_like({content => '%'.$params->{content}.'%'});
	    $c->stash(content => $params->{content});
	}
	if($params->{user_id} != -1){
	    $posts = $posts->search({user_id => $params->{user_id}});
	    $c->stash(user_id => $params->{user_id});
	}
	if($params->{topic_id} != 0){
	    $c->stash(threads => $c->model('forum::Thread')->search_rs({topic_id => $params->{topic_id}}));
	    $c->stash(topic_id => $params->{topic_id});
	}
	if($params->{thread_id} != 0){
	    $posts = $posts->search({thread_id => $params->{thread_id}});
	    $c->stash(thread_id => $params->{thread_id});
	}
    }

    my $page_num = 1;
    my $post_num = $posts->count;
    if($post_num % 10 == 0){$page_num = $post_num/10}
    else{$page_num = ($post_num - $post_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'admin', page_name => 'post');

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);

    $c->stash(posts => $posts->page($page));
    
    $c->stash(topics => $c->model('forum::Topic'));
	
    $c->stash(users => $c->model('forum::User'));
}

=head1 AUTHOR

minhbkpro

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
