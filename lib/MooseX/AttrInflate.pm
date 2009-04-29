package MooseX::AttrInflate;
use warnings;
use strict;

=head1 NAME

MooseX::AttrInflate - Auto-inflate your attributes

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    package MyClass;
    use Moose;
    use MooseX::AttrInflate;

    has 'helper' => (
        is => 'ro', isa => 'MyHelper',
        traits => [qw/AttrInflate/],
        # inflate_args => [],
        # inflate_ctor => 'new',
    );

    my $obj = MyClass->new();
    $obj->helper->help();

=head1 AUTHOR

Stash, C<< <jstash at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-attrinflate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-AttrInflate>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::AttrInflate


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-AttrInflate>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-AttrInflate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-AttrInflate>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-AttrInflate>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Jeremy Stashewsky
Copyright 2009 Socialtext Inc., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

package MooseX::Meta::Attribute::Trait::AttrInflate;
use Moose::Role;
use Moose::Util::TypeConstraints ();

has 'inflate_args' => (is => 'rw', isa => 'ArrayRef', predicate => 'has_inflate_args' );
has 'inflate_ctor' => (is => 'rw', isa => 'Str', default => 'new');

sub inflate {
    my $self = shift;
    my $class = $self->type_constraint->name;
    my $ctor = $self->inflate_ctor;
    return $class->$ctor($self->has_inflate_args ? @{$self->inflate_args} : ());
}

around 'new' => sub {
    my $code = shift;

    my $class = shift;
    my $name = shift;
    my %options = @_;

    $options{lazy} = 1;
    $options{default} = sub { $_[0]->meta->get_attribute($name)->inflate() };

    my $self = $class->$code($name,%options);

    my $type = $self->type_constraint;
    confess "type constraint isn't a subtype of Object"
        unless $type->is_subtype_of('Object');

    return $self;
};

around 'legal_options_for_inheritance' => sub {
    my $code = shift;
    my $self = shift;
    return ($self->$code(@_), 'inflate_args', 'inflate_ctor')
};


no Moose::Role;

package # happy PAUSE
    Moose::Meta::Attribute::Custom::Trait::AttrInflate;
sub register_implementation { 'MooseX::Meta::Attribute::Trait::AttrInflate' }


1;
