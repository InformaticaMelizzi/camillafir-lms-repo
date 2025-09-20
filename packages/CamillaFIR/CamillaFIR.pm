package Plugins::CamillaFIR::Plugin;

use strict;
use base qw(Slim::Plugin::Base);
use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Web::HTTP;
use File::Basename;
use File::Spec::Functions qw(catfile);

my $log = Slim::Utils::Log->addLogCategory({
    category     => 'plugin.camillafir',
    defaultLevel => 'INFO',
    description  => 'CamillaFIR Plugin',
});

my $prefs = preferences('plugin.camillafir');

my $pluginDir = Slim::Utils::Prefs::preferences('server')->get('cachedir') . "/CamillaFIR";
mkdir $pluginDir unless -d $pluginDir;
mkdir "$pluginDir/filters" unless -d "$pluginDir/filters";

sub initPlugin {
    my $class = shift;
    $class->SUPER::initPlugin(@_);

    Slim::Web::Pages->addPageFunction("camillafir", \&handleWeb);
    Slim::Web::Pages->addUploadHandler("camillafir_upload", \&handleUpload);
}

sub handleWeb {
    my ($client, $params) = @_;

    if ($params->{action} && $params->{action} eq 'generate') {
        generateConfig($params);
    }
    elsif ($params->{action} && $params->{action} eq 'start') {
        startCamilla();
    }
    elsif ($params->{action} && $params->{action} eq 'stop') {
        stopCamilla();
    }

    my $status = $prefs->get('status') || 'stopped';

    return Slim::Web::HTTP::filltemplatefile('index.html', {
        status => $status,
    });
}

sub handleUpload {
    my ($httpClient, $response) = @_;
    my $upload = $response->request->content;
    my $filename = $response->request->header('Filename') || 'unknown.wav';
    my $path = catfile("$pluginDir/filters", basename($filename));
    open my $fh, '>', $path or do {
        $log->error("Impossibile scrivere $path");
        return;
    };
    binmode $fh;
    print $fh $upload;
    close $fh;
    $log->info("File caricato: $path");
}

sub generateConfig {
    my ($params) = @_;

    my $dither    = $params->{dither}    || 'none';
    my $bits      = $params->{bits}      || '24';
    my $format    = $params->{format}    || 'wav';
    my $precision = $params->{precision} || 'S24LE';
    my $rate      = $params->{rate}      || '44100';

    my $configFile = "$pluginDir/config.yml";

    open my $fh, '>', $configFile or do {
        $log->error("Impossibile scrivere $configFile");
        return;
    };

    print $fh <<"CFG";
capture:
  type: File
  channels: 2
  filename: input.wav

filters:
  L:
    type: Conv
    parameters:
      filename: $pluginDir/filters/L.wav
      channel: 0
  R:
    type: Conv
    parameters:
      filename: $pluginDir/filters/R.wav
      channel: 1

mixers:
  stereo:
    channels:
      - [ { filter: L, gain: 1.0 } ]
      - [ { filter: R, gain: 1.0 } ]

pipeline:
  - type: Mixer
    name: stereo

playback:
  type: File
  format: $format
  dither: $dither
  bits: $bits
  sampleformat: $precision
  rate: $rate
  filename: $pluginDir/output.$format
CFG

    close $fh;
    $log->info("Generato config.yml con format=$format, bits=$bits, dither=$dither, precision=$precision, rate=$rate");
}

sub startCamilla {
    my $config = "$pluginDir/config.yml";
    my $bin = Slim::Utils::Misc::findbin("camilladsp");
    my $cmd = "$bin -p 12345 -o $pluginDir/log.txt $config &";
    system($cmd);
    $prefs->set('status', 'running');
}

sub stopCamilla {
    system("pkill -f camilladsp");
    $prefs->set('status', 'stopped');
}

1;
