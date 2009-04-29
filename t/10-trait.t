#!perl
use warnings;
use strict;
use Test::More tests => 12;
use Test::Exception;

BEGIN { use_ok 'MooseX::AttributeInflate' }

{
    package MyClass::Document;
    use Moose;

    has 'text' => (is => 'ro', isa => 'Str', default => 'O Hai');

    package MyClass;
    use Moose;
    use MooseX::AttributeInflate;

    has 'document' => (
        is => 'ro', isa => 'MyClass::Document',
        traits => [qw/Inflated/],
    );
}

happy_path: {
    my $o = MyClass->new();
    my $doc;
    lives_ok {
        $doc = $o->document;
    } 'got doc';
    isa_ok $doc => 'MyClass::Document';
    is $doc->text, 'O Hai';
}

{
    package MyClass2;
    use Moose;
    use MooseX::AttributeInflate;
    extends 'MyClass';

    has '+document' => (
        inflate_args => [text => 'Yup']
    );
}

construct_args: {
    my $o = MyClass2->new;
    my $doc;
    lives_ok {
        $doc = $o->document;
    } 'got doc';
    isa_ok $doc => 'MyClass::Document';
    is $doc->text, 'Yup';
}

{
    package NonMoose;
    use strict;

    sub buildit {
        my $class = shift;
        return bless [@_], $class;
    }

    package MyClass3;
    use Moose;
    use MooseX::AttributeInflate;
    extends 'MyClass';

    has '+document' => (
        isa => 'NonMoose',
        inflate_ctor => 'buildit',
        inflate_args => [qw(here it is)]
    );
}

construct_method: {
    my $o = MyClass3->new;
    my $doc;
    lives_ok {
        $doc = $o->document;
    } 'got doc';
    isa_ok $doc => 'NonMoose';
    is_deeply $doc, [qw(here it is)];
}

non_object: throws_ok {
    package WTF;
    use Moose;
    use MooseX::AttributeInflate;

    has 'name' => (
        is => 'rw', isa => 'Str',
        traits => [qw/Inflated/],
    );
} qr/subtype of Object/, "can't inflate a non-Object";

is_object: throws_ok {
    package WTF;
    use Moose;
    use MooseX::AttributeInflate;

    has 'name' => (
        is => 'rw', isa => 'Object',
        traits => [qw/Inflated/],
    );
} qr/subtype of Object/, "can't inflate a direct Object";
