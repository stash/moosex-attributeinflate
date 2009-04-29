use inc::Module::Install;

name     'MooseX-AttrInflate';
all_from 'lib/MooseX/AttrInflate.pm';
author   'Stash <jstash@gmail.com>';

build_requires 'Test::More';

auto_install;

WriteAll;

