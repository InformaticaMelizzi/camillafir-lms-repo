package Plugins::CamillaFIR::Plugin;
use strict;
use warnings;
use Slim::Utils::Log;

my $log = Slim::Utils::Log->addLogCategory({
    category     => 'plugin.camillafir',
    defaultLevel => 'INFO',
    description  => 'CamillaFIR plugin',
});

sub initPlugin {
    $log->info("CamillaFIR plugin loaded");
}

sub getDisplayName { 
    return 'CamillaFIR';
}

1;
