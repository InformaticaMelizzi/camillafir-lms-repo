package Plugins::CamillaFIR::Plugin;

use strict;
use warnings;

use Slim::Utils::Log;

my $log = logger('plugin.camillafir');

sub initPlugin {
    my $class = shift;
    $log->info("CamillaFIR plugin initialized");
}

sub shutdownPlugin {
    $log->info("CamillaFIR plugin stopped");
}

1;
