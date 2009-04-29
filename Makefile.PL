use inc::Module::Install;

name     'MooseX-AttrInflate';
all_from 'lib/MooseX/AttrInflate.pm';
author   'Stash <jstash@gmail.com>';

build_requires 'Test::More';
build_requires 'Test::Exception';

auto_install;

WriteAll;

