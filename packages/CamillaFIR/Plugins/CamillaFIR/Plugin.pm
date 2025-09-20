package Plugins::CamillaFIR::Plugin;

use strict;
use warnings;

use base qw(Slim::Plugin::Base);

sub initPlugin {
    my $class = shift;
    $class->SUPER::initPlugin(@_);
}

sub getDisplayName {
    return 'PLUGIN_CAMILLAFIR';
}

1;
