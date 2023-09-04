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
use DSL::Translators::ComprehensiveTranslation;
use Lingua::NumericWordForms;
use JSON::Fast;

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
 res = Check[ToExpression[message2], ExportString[<|\"Error\" -> \"\$Failed\"|>, \"JSON\", \"Compact\" -> True]];
 Print[\"[woflramscirpt] evaluated:\", res];

 BinaryWrite[socket, StringToByteArray[ToString[res], \"UTF-8\"]]
]";
# BinaryWrite[socket, StringToByteArray[ToString[res], \"UTF-8\"], \"Character32\"]
    if !$proclaim {
        $resCode = $resCode.subst( / ^^ \h* 'Print' .*? $$ /, ''):g
    }

    $resCode
};

# Prep code when experimenting with DSL translations by QAS.
my Str $prepCode = 'Import["https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Packages/WL/NLPTemplateEngine.m"];';

# Launch wolframscript with ZMQ socket
my $proc = Proc::Async.new: 'wolframscript','-code', MakeWLCode(:$url, :$port, :$prepCode):!proclaim;
$proc.start;

# Socket to talk to clients
my Net::ZMQ4::Context $context .= new;
my Net::ZMQ4::Socket $reciever .= new($context, ZMQ_REQ);
$reciever.bind("$url:$port");

#| Translate commands by QAS.
sub dsl-translation-by-qas( Str $commands, Str :$lang = 'WL') {

    # Build-up the WL code
    my $spec = 'aRes = Concretize[ "' ~ $commands ~ '", "AssociationResult" -> True, "TargetLanguage" -> "' ~ $lang ~ '"];';
    $spec ~= 'If[ TrueQ[aRes === $Failed], aRes = <|"Error" -> "$Failed"|>];';
    $spec ~= 'ExportString[aRes, "JSON", "Compact" -> True]';

    # The above line could be the following, but I think it is better to give working WL code.
    # ExportString[Map[StringReplace[#, {"\[DoubleLongRightArrow]" -> "==>"}] &, aRes], "JSON", "Compact" -> True]

    # Send code through ZMQ
    $reciever.send($spec);

    # Receive result from ZMQ
    my $message = $reciever.receive();

    # Return result
    $message.data-str
}

#| Get answers by WL's FindTextualAnswer.
sub find-textual-answer(Str $text, Str $question, Int :$nAnswers = 3, Str :$performanceGoal = 'Speed', Str :$properties = '') {

    # Process properties
    my Str @knownProps = <String Position Probability Sentence Paragraph Line Snippet>;
    my Str @props;

    if $properties.chars > 0 {

        @props = $properties.split(/',' | \h+ /).map({ $_.trim.tclc });

        @props = (@props (&) @knownProps).keys;

        @props = (@props (-) <Probability Position>).keys.sort;

        if @props.elems > 0 {
            @props = @props.map({ '"' ~ $_ ~ '"' });
        }
    }

    # Build-up the WL code
    my $spec = 'lsProps = {"Probability", "Position"' ~ ( @props.elems == 0 ?? '' !! ', ' ~ @props.join(', ') ) ~ '};';
    $spec ~= 'res = FindTextualAnswer[ "' ~ $text ~ '", "' ~ $question ~ '", ' ~ $nAnswers.Str ~ ', lsProps, "PerformanceGoal" -> "' ~ $performanceGoal ~ '"];';
    $spec ~= 'If[ TrueQ[res === $Failed],';
    $spec ~= '  aRes = <|"Error" -> "$Failed"|>,';
    $spec ~= '  aRes = Map[AssociationThread[lsProps, #] &, res]';
    $spec ~= '];';
    $spec ~= 'ExportString[aRes, "JSON", "Compact" -> True]';

    # Send code through ZMQ
    $reciever.send($spec);

    # Receive result from ZMQ
    my $message = $reciever.receive();

    # Return result
    $message.data-str
}

# Cro application
my $application = route {

    get -> 'translate', 'qas', $commands {

        my Str $res = dsl-translation-by-qas( $commands, lang => 'WL' );

        content 'text/html', $res;
    }

    get -> 'translate', 'qas', $lang, $commands {

        my Str $res = dsl-translation-by-qas( $commands, :$lang );

        content 'text/html', $res;
    }

    get -> 'translate', $commands {

        my %res = dsl-translation( $commands, defaultTargetsSpec => 'WL');

        content 'text/html', marshal( %res );
    }

    get -> 'translate', $lang, $commands {

        my %res = dsl-translation( $commands, defaultTargetsSpec => $lang);

        content 'text/html', marshal( %res );
    }

    get -> 'translate', 'ast', $commands {

        my %res = dsl-translation( $commands, defaultTargetsSpec => 'WL'):ast;

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

        my Bool $numberQ = so $commands2 ~~ / ^ [ ';' | \d ]* $ /;
        my $parserRes = $numberQ ?? to-numeric-word-form($commands2) !! from-numeric-word-form( $commands2, 'automatic', :p);

        my %res = %( CODE => $parserRes,
                     COMMAND => $commands2,
                     USERID => '',
                     DSL => 'Lingua::NumericWordForms',
                     DSLTARGET => 'Lingua::NumericWordForms',
                     DSLFUNCTION => $numberQ ?? &to-numeric-word-form !! &from-numeric-word-form );

        content 'text/html', marshal(%res);
    }

    get -> 'find-textual-answer', :$text!, :$question!, :$nAnswers = '3', :$performanceGoal = 'Speed', :$properties = '' {

        my Str $performanceGoal2 = $performanceGoal.Str.tclc eq 'Quality' ?? 'Quality' !! 'Speed';
        my Str $nAnswers2 = $nAnswers.Str;
        $nAnswers2 = ($nAnswers2 ~~ / \d+ /) ?? $nAnswers2 !! '3';

        my Str $res = find-textual-answer( $text, $question, nAnswers => $nAnswers2.Int, performanceGoal => $performanceGoal2, :$properties );

        content 'text/html', $res;
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