#!/usr/bin/perl -w
use v5.14;
use autodie;
use Modern::Perl;

use Data::Dump qw( dump );

use lib './lib/';
use configuration ':all';
use app;
use utf8;

if( @ARGV != 0 && @ARGV != 1 ) {
    say "usage : ./$0 [user]";
    exit 1;
}

my $login = qw/test/;
$login = $ARGV[0] if @ARGV == 1;

eval {
    my $app = app->new(get_cfg());
    $app->delete_user($login);
};

if( $@ ) {
    say q{Une erreur est survenue. } . $@;
}
