use strict;
use warnings;
use utf8;
use Test::More;
use t::TestFlavor;
use t::Util;
use Test::Requires +{
	'Teng'                            => '0.18',
	'DBD::SQLite'                     => '1.33',
    'DBI'                             => 0,
    'Plack::Session'                  => '0.14',
    'Module::Functions'               => '0',
    'HTML::FillInForm::Lite'          => 0,
};

test_flavor(sub {
    ok(-f 'Build.PL', 'Build.PL');
	like(slurp('cpanfile'), qr{Plack::Session});
	for my $env (qw(development production test)) {
		ok(-f "config/${env}.pl");
		my $conf = do "config/${env}.pl";
		is(ref($conf), 'HASH');
	}
    ok(-f 'lib/My/App.pm', 'lib/My/App.pm exists');
    ok((do 'lib/My/App.pm'), 'lib/My/App.pm is valid') or do {
        diag $@;
        diag do {
            open my $fh, '<', 'lib/My/App.pm' or die;
            local $/; <$fh>;
        };
    };
    is( scalar( my @files = glob('static/js/jquery-*.js') ), 1 );
    like slurp('tmpl/include/layout.tx'), qr{ng-app="myApp"};
    like slurp('tmpl/include/layout.tx'), qr{json2.js}, 'loaded json2.js';
	like(slurp('cpanfile'), qr{'Teng'\s*,\s*'[0-9.]+'});
}, 'Basic');

done_testing;

