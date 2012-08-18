package forum::Controller::Login;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

forum::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path  {
    my ( $self, $c, $index, $cur_site ) = @_;
    my $template = 'admin_login.html';

     # Get the username and password from form
    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};
 
    # If the username and password values were found in form
    if ($username && $password) {
        # Attempt to log the user in
        if (!$c->authenticate({ username => $username,
				password => $password  } )) {            
	    $c->stash(error_msg => "Bad username or password.");
            return;
        }
    } else {	
        # Set an error message
        $c->stash(error_msg => "Empty username or password.")
            unless ($c->user_exists);
    }

    if($c->user_exists){
	$c->response->redirect($c->uri_for("/".$cur_site));
    }
 
    # If either of above don't work out, send to the login page
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
