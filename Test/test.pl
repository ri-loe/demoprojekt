#!/Users/c5261164/perl5/perlbrew/perls/perl-5.24.0/bin/perl
use strict;
use warnings FATAL => 'all';

use Test::More;
use_ok('HTML::Template');
use HTML::Template;
use lib "/Users/c5261164/dev/demo";
use_ok('Services::ResultResponse');
use Services::ResultResponse;


my $template = HTML::Template->new(filename => '/Users/c5261164/dev/demo/Templates/storage_edit.tmpl');
my $rr = ResultResponse->new('storage', $template, 'edit', 1);

ok( defined $rr , 'new() returned something.');
isa_ok($rr, 'ResultResponse');
can_ok($rr, 'print_result_message');


done_testing();