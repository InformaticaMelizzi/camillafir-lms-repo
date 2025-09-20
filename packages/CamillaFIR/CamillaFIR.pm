package Plugins::CamillaFIR::Plugin;

use strict;
use base qw(Slim::Plugin::Base);

sub initPlugin {
    my $class = shift;
    $class->SUPER::initPlugin(@_);

    # registra pagina web
    Slim::Web::Pages->addPageFunction("camillafir", \&handleWeb);
}

sub handleWeb {
    my ($client, $params) = @_;
    return Slim::Web::HTTP::filltemplatefile("index.html", $params);
}

1;
