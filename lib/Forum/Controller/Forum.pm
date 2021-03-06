package forum::Controller::Forum;
use Moose;
use namespace::autoclean;
use 5.010;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::Forum - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect($c->uri_for('/forum/topic'));
}

sub topic :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(template => 'forum_topic.html');

    $c->stash(topics => $c->model('forum::Topic'));

    $c->stash(thread_num => $c->model('forum::Thread')->count);

    $c->stash(topic_num => $c->model('forum::Topic')->count);
    
    $c->stash(user_num => $c->model('forum::User')->count);
}

sub thread :Local :Args(2) {
    my ( $self, $c, $topic_id, $page ) = @_;
    my @forum_links;

    my $page_num = 1;
    my $thread_num = $c->model('forum::Thread')->search_rs({topic_id => $topic_id})->count;
    if($thread_num % 10 == 0){$page_num = $thread_num/10}
    else{$page_num = ($thread_num - $thread_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'forum', page_name => 'thread');

    $c->stash(parent_id => $topic_id);

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);
    

    $c->stash(topic_id => $topic_id, template => 'forum_thread.html');

    $c->stash(threads => $c->model('forum::Thread')->search_rs({
	topic_id => $topic_id
							},
							{
							    '+select' => [
								{count => 'thread_id', -as => 'answer'},
								{max => 'last_modifed', -as => 'last_modifed'}
								],
							    join => 'post',
							    group_by => [qw /thread_id/],
							    order_by => {-desc => [qw /last_modifed/]}
							}
	      )->page($page));
    
    $c->stash(posts => $c->model('forum::Post'));
    $c->stash(posts1 => $c->model('forum::Post'));

    $c->stash(users => $c->model('forum::User'));

    #get infomation for forum_link
    my %hash = (
	'title' => $c->model('forum::Topic')->search_rs({id => $topic_id})->first->title,
	'link' => $c->uri_for('/forum/thread/').$topic_id."/1"
	);
    push @forum_links, \%hash;
    $c->stash(forum_links => \@forum_links);

    #datetime
    my $dt = DateTime->now();
    $dt->set(day => $dt->day - 1);
    $c->stash(yesterday => $dt);
}

sub post :Local :Args(2) {
    my ( $self, $c, $thread_id, $page ) = @_;
    my @forum_links;
    
    my $page_num = 1;
    my $post_num = $c->model('forum::Post')->search_rs({thread_id => $thread_id},{order_by => 'id'})->count;
    if($post_num % 10 == 0){$page_num = $post_num/10}
    else{$page_num = ($post_num - $post_num % 10)/10 + 1}

    $c->stash(page_num => $page_num);

    $c->stash(page_site => 'forum', page_name => 'post');

    $c->stash(parent_id => $thread_id);

    if(!defined($page) || $page <= 0){$page = 1}
    if($page > $page_num){$page = $page_num}

    $c->stash(cur_page => $page);

    $c->stash(thread_id => $thread_id, template => 'forum_post.html');

    $c->stash(posts => $c->model('forum::Post')->search_rs({thread_id => $thread_id},{order_by => 'id'})->page($page));
    
    #get infomation for forum_link
    my $topic_id = $c->model('forum::Thread')->search_rs({id => $thread_id})->first->topic_id;
    my %hash = (
	'title' => $c->model('forum::Topic')->search_rs({id => $topic_id})->first->title,
	'link' => $c->uri_for('/forum/thread/').$topic_id."/1"
	);
    push @forum_links, \%hash;
    my %hash1 = (
	'title' => $c->model('forum::Thread')->search_rs({id => $thread_id})->first->title,
	'link' => $c->uri_for('/forum/post/').$thread_id."/1"
	);
    push @forum_links, \%hash1;
    $c->stash(forum_links => \@forum_links);

    #update view
    my $view = $c->model('forum::Thread')->search({id => $thread_id})->first->view;
    $view = $view + 1;
    $c->model('forum::Thread')->search({id => $thread_id})->update({
	view => $view
								   });
}

sub register :Local {
    my ( $self, $c ) = @_;

    $c->stash(template => 'forum_user_form.html');

    $c->stash(posts_rs => $c->model('forum::Post'));
}

=head1 AUTHOR

minhbkpro

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
