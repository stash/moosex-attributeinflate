package MooseX::AttributeInflate;
use warnings;
use strict;
use Moose ();
use Moose::Exporter ();

our $VERSION = '0.01';

Moose::Exporter->setup_import_methods(
    with_caller => ['has_inflated'],
    also => 'Moose',
);

sub has_inflated {
    my $caller = shift;
    my $name = shift;
    my %options = @_;
    $options{traits} ||= [];
    unshift @{$options{traits}}, 'Inflated';
    Class::MOP::Class->initialize($caller)->add_attribute($name, %options);
}

=head1 NAME

MooseX::AttributeInflate - Auto-inflate your Moose attribute objects

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Lazily constructs ("inflates") an object attribute, optionally using constant
parameters.

    package MyClass;
    use MooseX::AttributeInflate;

    has_inflated 'helper' => (
        is => 'ro', isa => 'MyHelper'
    );

    # OR, explicitly

    has 'helper' => (
        is => 'ro', isa => 'MyHelper',
        traits => [qw/Inflated/],
        inflate_args => [],
        inflate_method => 'new',
    );

    my $obj = MyClass->new();
    $obj->helper->help();

=head1 DESCRIPTION

Installs a C<default> for this accessor that calls the constructor for the
specified Object type.  Also turns on C<lazy>.

If a type that is not a sub-type of Object is specified, an exception is
thrown.

=head1 EXPORTS

=head2 has_inflated

Just like Moose's C<has>, but prepends the trait C<Inflated>.

Additional options:

=over 4

=item inflate_method

The name of the constructor to use. Defaults to 'new'.

=item inflate_args

The arguments to pass to the constructor.  Defaults to an empty list.

=back

=head1 AUTHOR

Stash <jstash+cpan@gmail.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-attrinflate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-AttributeInflate>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::AttributeInflate


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-AttributeInflate>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-AttributeInflate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-AttributeInflate>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-AttributeInflate>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Jeremy Stashewsky
Copyright 2009 Socialtext Inc., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

package MooseX::Meta::Attribute::Trait::Inflated;
use Moose::Role;
use Moose::Util::TypeConstraints ();

has 'inflate_args' => (is => 'rw', isa => 'ArrayRef', predicate => 'has_inflate_args' );
has 'inflate_method' => (is => 'rw', isa => 'Str', default => 'new');

sub inflate {
    my $self = shift;
    my $class = $self->type_constraint->name;
    my $ctor = $self->inflate_method;
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
    return ($self->$code(@_), 'inflate_args', 'inflate_method')
};


no Moose::Role;

package # happy PAUSE
    Moose::Meta::Attribute::Custom::Trait::Inflated;
sub register_implementation { 'MooseX::Meta::Attribute::Trait::Inflated' }


1;
