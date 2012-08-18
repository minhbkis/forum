use utf8;
package Forum::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Forum::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 full_name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 avatar

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 role

  data_type: 'integer'
  is_nullable: 0

=head2 created_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 actived

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "full_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "avatar",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "role",
  { data_type => "integer", is_nullable => 0 },
  "created_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "actived",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-06 21:46:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:k9wTL1DpCQcOIYlmvKMcYQ

__PACKAGE__->has_many(
    "post",
    "Forum::Schema::Result::Post",
    { "foreign.user_id" => "self.id" },
    );

__PACKAGE__->has_many(
    "topic",
    "Forum::Schema::Result::Topic",
    { "foreign.user_id" => "self.id" },
    );

__PACKAGE__->has_many(
    "thread",
    "Forum::Schema::Result::Thread",
    { "foreign.user_id" => "self.id" },
    );

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
