package forum::Controller::User;
use Moose;
use namespace::autoclean;
use 5.010;
use DateTime;
use Catalyst::Request::Upload;
use Email::Valid;
use utf8;
use Crypt::CBC;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path{
    my($self, $c, $index, $action, $user_id) = @_;
    my $template = 'admin_user.html';
    my $now = DateTime->now->ymd." ".DateTime->now->hms;
    my $params = $c->req->params;
    
    #check input params
    if(!$c->user_exists){#no user
	$c->response->redirect($c->uri_for('/admin'));
    }

    #check valid url
    if(!defined($action) || ($action ne 'new' && $action ne 'edit' && $action ne 'delete') || (($action eq 'edit' || $action eq 'delete') && (!defined($c->req->method) || lc $c->req->method ne 'post') && (!defined($user_id) || $user_id !~ /^([1-9]+[0-9]*,)*[1-9]+[0-9]*$/))){
	if($c->user->get('role') == 0){
	    $c->response->redirect($c->uri_for('/admin'));
	}else{
	    $c->response->redirect($c->uri_for('/forum'));
	}
    }
    else{
	if(defined($params) && defined($params->{username})){#form is submited
	    my @err = $self->user_validate($c, $action);
	    if(@err == 0){
		if($action eq 'new' || $action eq 'edit'){
		    #get avatar info
		    my $avatar = $c->request->upload('avatar');
		    my $avatar_name = '';
		    if($avatar){
			$avatar_name = $avatar->filename;
			my $target = $c->path_to('/root/avatar')."/".$avatar_name;
			$avatar->copy_to($target);
		    }
		    
		    #get form data
		    my $role;
		    my $actived;
		    if(defined($params->{role})){#is admin form, only admin form have role input
			$role = $params->{role};
			$actived = $params->{actived}
		    }else{
			$role = 1;
			$actived = 1;
		    }

		    my $cipher = new Crypt::CBC('minhbkpro');
		    $cipher->start('encrypting');
		    my $password = $cipher->encrypt($params->{password});
		    $cipher->finish();
		    
		    my %submited_user = (
			username => $params->{username},
			password => $password,
			full_name => $params->{full_name},
			email => $params->{email},
			avatar => $avatar_name,
			role => $role,
			created_date => $now,
			actived => $actived
			);
		    
		    #add new user
		    if($action eq 'new'){
			$c->model('forum::User')->create(\%submited_user);
			if(defined($params->{role})){#admin form
			    $c->response->redirect($c->uri_for('/admin/user/1'));
			}else{
			    $c->response->redirect($c->uri_for('/forum'));
			}
		    }
		    
		    #edit user
		    if($action eq 'edit'){
			$c->model('forum::User')->search({username => $params->{username}})->update(\%submited_user);
			$c->response->redirect($c->uri_for('/admin/user/1'));
		    }
		}
	    }else{
		$c->stash(errs => \@err);
		if(defined($params->{role})){
		    $template = 'admin_user_form.html';
		}else{
		    $template = 'forum_user_form.html';
		}
	    }
	}else{#form is not submit : new user first visit, edit user first  or delete user
	    $c->stash(page_name => 'user', page_type => 'form');#set page type for display menu etc...

	    if($c->user_exists){
		if($c->user->get('role') == 0){$template = 'admin_user_form.html'}
		else{$template = 'forum_user_form.html'}
	    }
	    if($action eq 'edit'){
		if($c->user->get('role') != 0){$user_id = $c->user->get('id');}
		$c->stash(user_edit => $c->model('forum::User')->search({id => $user_id}));
		my $cipher = new Crypt::CBC('minhbkpro');
		$cipher->start('decrypting');
		$c->stash(password => $cipher->decrypt($c->model('forum::User')->search({id => $user_id})->first->password));
		$cipher->finish();
	    }elsif($action eq 'delete'){#delete user
		#$user_id must be an string type 1,2,3,4
		my @delete_id_list = split /,/,$user_id;
		foreach(@delete_id_list){
		    $c->model('forum::User')->search({id => $_})->delete();
		}
		$c->response->redirect($c->uri_for('/admin/user/1'));
	    }
	}
    }
    $c->stash(template => $template);
}

sub user_validate {
    my ( $self, $c, $action ) = @_;
    my $params = $c->req->params;
    my @err;

    if(defined($params) && defined($params->{username})){#form is submited
	my $username = $params->{username};
	my $password = $params->{password};
	my $re_password = $params->{re_password};
	my $full_name = $params->{full_name};
	my $email = $params->{email};

	#check character
	if($username !~ /[0-9a-zA-Z]+/){
	    push @err,'username should have 3 characters or more and contain the following characters [0-9] [a-z] [A-Z].';
	}
	
	#check password
	if($password !~ /.{6,}/ || $re_password !~ /.{6,}/){
	    push @err,'password should have 6 characters or more';
	}
	if($password ne $re_password) {
	    push @err, 'password and re_password must be same';
	}
	
	#check email
	if($email ne '' && !Email::Valid->address($email)) {
	    push @err, 'Email is not valid';
	}
	
	#check exist username
	if(@err == 0 && $action ne 'edit'){
	    if($c->model('forum::User')->search({username => $username})->count() > 0){
		push @err, 'Username already exist! Please chose another username';
	    }
	}
	
	#return
	return @err;
    }
}

=head1 AUTHOR

minhbkpro

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
