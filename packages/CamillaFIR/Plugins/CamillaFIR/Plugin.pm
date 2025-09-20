package Plugins::CamillaFIR::Plugin;

use strict;
use warnings;

use Slim::Utils::Log;

my $log = logger('plugin.camillafir');

sub initPlugin {
    $log->info("CamillaFIR plugin initialized OK");
}

sub shutdownPlugin {
    $log->info("CamillaFIR plugin stopped");
}

1;
