package forum::View::HTML;
use Moose;
use namespace::autoclean;
use utf8;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.html',
    render_die => 1,
    ENCODING => 'utf-8',
);

__PACKAGE__->config({
    ENCODING => 'utf-8',
		    });

=head1 NAME

forum::View::HTML - TT View for forum

=head1 DESCRIPTION

TT View for forum.

=head1 SEE ALSO

L<forum>

=head1 AUTHOR

minhbkpro

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
