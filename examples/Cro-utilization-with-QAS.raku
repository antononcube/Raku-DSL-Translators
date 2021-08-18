#!/usr/bin/env perl6

=begin para
In this file we use both:
=item Raku DSL translation through grammars
=item Mathematica / Wolfram Language (WL) semantic parsing through a Question Answering System (QAS)
See the WL package: L<https://github.com/antononcube/MathematicaForPrediction/blob/master/Misc/ComputationalSpecCompletion.m>.
The original version of this file L<./Cro-utilization-example.raku>.
=end para

use Cro::HTTP::Router;
use Cro::HTTP::Server;

use lib './lib';
use lib '.';

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::ComprehensiveTranslation;
use Lingua::NumericWordForms;
use JSON::Marshal;

use Net::ZMQ4;
use Net::ZMQ4::Constants;


# To be used below.
my Str $url = 'tcp://127.0.0.1';
my Str $port = '5555';

#| Makes WL's ZeroMQ infinite loop program.
sub MakeWLCode( Str :$url = 'tcp://127.0.0.1', Str :$port = '5555', Str :$prepCode = '', Bool :$proclaim = False) {

    my Str $resCode =
            $prepCode ~
            "socket = SocketConnect[\"$url:$port\", \"ZMQ_REP\"]

While[True,
 message = SocketReadMessage[socket];
 message2 = ByteArrayToString[message];
 Print[\"[woflramscirpt] got request:\", message2];
 res = ToExpression[message2];
 Print[\"[woflramscirpt] evaluated:\", res];

 BinaryWrite[socket, StringToByteArray[ToString[res], \"UTF-8\"]]
]";

    if !$proclaim {
        $resCode = $resCode.subst( / ^^ \h* 'Print' .*? $$ /, ''):g
    }

    $resCode
};

# Prep code when experimenting with DSL translations by QAS.
my Str $prepCode = 'Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/Misc/ComputationalSpecCompletion.m"];';

# Launch wolframscript with ZMQ socket
my $proc = Proc::Async.new: 'wolframscript','-code', MakeWLCode(:$url, :$port, :$prepCode):!proclaim;
$proc.start;

# Socket to talk to clients
my Net::ZMQ4::Context $context .= new;
my Net::ZMQ4::Socket $reciever .= new($context, ZMQ_REQ);
$reciever.bind("$url:$port");

#| Translate commands by QAS
sub dsl-translate-by-qas( Str $commands, Str :$lang = 'WL') {

    my $spec = 'aRes = ComputationalSpecCompletion[ "' ~ $commands ~ '", "AssociationResult" -> True, "ProgrammingLanguage" -> "' ~ $lang ~ '"];';
    $spec ~= 'ExportString[Map[StringReplace[#, {"\[DoubleLongRightArrow]" -> "==>"}] &, aRes], "JSON"]';
    $reciever.send($spec);
    my $message = $reciever.receive();

    $message.data-str
}

# Cro application
my $application = route {

    get -> 'translate', 'qas', $commands {

        my Str $res = dsl-translate-by-qas( $commands, lang => 'WL' );

        content 'text/html', $res;
    }

    get -> 'translate', 'qas', $lang, $commands {

        my Str $res = dsl-translate-by-qas( $commands, :$lang );

        content 'text/html', $res;
    }

    get -> 'translate', $commands {

        my %res = dsl-translate( $commands, defaultTargetsSpec => 'WL');

        content 'text/html', marshal( %res );
    }

    get -> 'translate', $lang, $commands {

        my %res = dsl-translate( $commands, defaultTargetsSpec => $lang);

        content 'text/html', marshal( %res );
    }

    get -> 'translate', 'ast', $commands {

        my %res = dsl-translate( $commands, defaultTargetsSpec => 'WL'):ast;

        content 'text/html', marshal( %res );
    }

    get -> 'translate', 'foodprep', $commands {
        my Str $commands2 = $commands;
        $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1,*-1) !! $commands2;
        content 'text/html', ToDSLCode( $commands2, language => "English", format => 'json', :guessGrammar, defaultTargetsSpec => 'WL');
    }

    get -> 'translate', 'numeric', $commands {
        my Str $commands2 = $commands;
        $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1,*-1) !! $commands2;

        my $res =  ($commands2 ~~ / ^ [ ';' | \d ]* $ /) ?? to-numeric-word-form($commands2) !! from-numeric-word-form( $commands2, 'automatic', :p);

        content 'text/html', marshal($res);
    }
}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<localhost>, :port<10000>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $proc.kill;
    $proc.kill: SIGKILL;
    $service.stop;
    exit;
}