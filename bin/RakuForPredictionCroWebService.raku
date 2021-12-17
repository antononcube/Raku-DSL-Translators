#!/usr/bin/env perl6

use Cro::HTTP::Router;
use Cro::HTTP::Server;

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::ComprehensiveTranslation;
use Lingua::NumericWordForms;
use JSON::Marshal;

use Net::ZMQ4;
use Net::ZMQ4::Constants;


#============================================================
# MAIN program
#============================================================
#| Start a Cro service for translation of DSLs into executable code.
sub MAIN(
        Str :$host = 'localhost', #= Host name
        Str :$port = '10000', #= Port
        Str :$wl-url = 'tcp://127.0.0.1', #= URL for the wolframscript connection
        Str :$wl-port = '5540', #= Port for the wolframscript connection
        Str :$wl-nlp-package-url = 'https://raw.githubusercontent.com/antononcube/NLP-Template-Engine/main/Packages/WL/NLPTemplateEngine.m', #| URL for NLP Template Engine package (to be loaded in WL)
         ) {

    # Empty result hash
    constant %emptyResult = %( CODE => '',
                               STDERR => '',
                               COMMAND => '',
                               USERID => '',
                               DSL => '',
                               DSLTARGET => '',
                               DSLFUNCTION => '');

    # Prep code when experimenting with DSL translations by QAS.
    my Str $prepCode = 'Import["' ~ $wl-nlp-package-url ~ '"];';

    # Launch wolframscript with ZMQ socket
    my $proc = Nil;
    my Net::ZMQ4::Socket $receiver = Nil;
    if $wl-url and $wl-port {

        warn 'Launching wolframscript with ZMQ socket...';

        # Launch wolframscript with ZMQ socket
        $proc = Proc::Async.new:
                'wolframscript',
                '-code',
                MakeWLCode(url => $wl-url, port => $wl-port, :$prepCode):!proclaim;

        $proc.start;

        # Socket to talk to clients
        my Net::ZMQ4::Context $context .= new;
        $receiver .= new($context, ZMQ_REQ);
        $receiver.bind("$wl-url:$wl-port");

        warn '...DONE';
    } else {
        warn 'Not activating QAS.'
    }

    # Cro application
    my $application = route {

        get -> 'translate', 'qas', $commands {

            if $receiver {

                my Str $res = dsl-translate-by-qas($receiver, $commands, lang => 'WL');

                content 'text/html', $res;

            } else {

                my %res = %emptyResult, { STDERR => 'QAS was not activated.', COMMAND => $commands };

                content 'text/html', marshal(%res);
            }
        }

        get -> 'translate', 'qas', $lang, $commands {

            if $receiver {

                my Str $res = dsl-translate-by-qas($receiver, $commands, :$lang);

                content 'text/html', $res;

            } else {

                my %res = %emptyResult, { STDERR => 'QAS was not activated.', COMMAND => $commands };

                content 'text/html', marshal(%res);

            }
        }

        get -> 'translate', $commands {

            my %res = dsl-translate($commands, defaultTargetsSpec => 'WL');

            content 'text/html', marshal(%res);
        }

        get -> 'translate', $lang, $commands {

            my %res = dsl-translate($commands, defaultTargetsSpec => $lang);

            content 'text/html', marshal(%res);
        }

        get -> 'translate', 'ast', $commands {

            my %res = dsl-translate($commands, defaultTargetsSpec => 'WL'):ast;

            content 'text/html', marshal(%res);
        }

        get -> 'translate', 'foodprep', $commands {
            my Str $commands2 = $commands;
            $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1, *- 1) !! $commands2;
            content 'text/html', ToDSLCode($commands2, language => "English", format => 'json', :guessGrammar,
                    defaultTargetsSpec => 'WL');
        }

        get -> 'translate', 'numeric', $commands {
            my Str $commands2 = $commands;
            $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1, *- 1) !! $commands2;

            my Bool $numberQ = so $commands2 ~~ / ^ [';' | \d]* $ /;
            my $parserRes = $numberQ ?? to-numeric-word-form($commands2) !! from-numeric-word-form($commands2,
                    'automatic',
                    :p);

            my %res = %( CODE => $parserRes,
                         COMMAND => $commands2,
                         USERID => '',
                         DSL => 'Lingua::NumericWordForms',
                         DSLTARGET => 'Lingua::NumericWordForms',
                         DSLFUNCTION => $numberQ ?? &to-numeric-word-form !! &from-numeric-word-form);

            content 'text/html', marshal(%res);
        }

        get -> 'find-textual-answer', :$text!, :$question!, :$nAnswers = '3', :$performanceGoal = 'Speed',
               :$properties = '' {

            my Str $performanceGoal2 = $performanceGoal.Str.tclc eq 'Quality' ?? 'Quality' !! 'Speed';
            my Str $nAnswers2 = $nAnswers.Str;
            $nAnswers2 = ($nAnswers2 ~~ / \d+ /) ?? $nAnswers2 !! '3';

            my Str $res = find-textual-answer($receiver, $text, $question, nAnswers => $nAnswers2.Int,
                    performanceGoal => $performanceGoal2, :$properties);

            content 'text/html', $res;
        }

    }

    # The Cro service
    my Cro::Service $service = Cro::HTTP::Server.new(:$host, port => $port.Int, :$application);

    $service.start;

    warn 'Started the Cro service.';

    react whenever signal(SIGINT) {
        if $proc {
            $proc.kill;
            $proc.kill: SIGKILL;
        }
        $service.stop;
        exit;
    }

}


#============================================================
# MakeWLCode
#============================================================

#| Makes WL's ZeroMQ infinite loop program.
sub MakeWLCode(Str :$url = 'tcp://127.0.0.1', Str :$port = '5555', Str :$prepCode = '', Bool :$proclaim = False) {

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
        $resCode = $resCode.subst(/ ^^ \h* 'Print' .*? $$ /, ''):g
    }

    $resCode
};


#============================================================
# QAS
#============================================================

#| Translate commands by QAS.
sub dsl-translate-by-qas($receiver, Str $commands, Str :$lang = 'WL') {

    # Build-up the WL code
    my $spec = 'aRes = Concretize[ "' ~ $commands ~ '", "AssociationResult" -> True, "TargetLanguage" -> "' ~ $lang ~
            '"];';
    $spec ~= 'If[ TrueQ[aRes === $Failed], aRes = <|"Error" -> "$Failed"|>];';
    $spec ~= 'ExportString[aRes, "JSON", "Compact" -> True]';

    # The above line could be the following, but I think it is better to give working WL code.
    # ExportString[Map[StringReplace[#, {"\[DoubleLongRightArrow]" -> "==>"}] &, aRes], "JSON", "Compact" -> True]

    # Send code through ZMQ
    $receiver.send($spec);

    # Receive result from ZMQ
    my $message = $receiver.receive();

    # Return result
    $message.data-str
}

#| Get answers by WL's FindTextualAnswer.
sub find-textual-answer($receiver,
                        Str $text, Str $question, Int :$nAnswers = 3, Str :$performanceGoal = 'Speed',
                        Str :$properties = '') {

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
    my $spec = 'lsProps = {"Probability", "Position"' ~ (@props.elems == 0 ?? '' !! ', ' ~ @props.join(', ')) ~ '};';
    $spec ~= 'res = FindTextualAnswer[ "' ~ $text ~ '", "' ~ $question ~ '", ' ~
            $nAnswers.Str ~ ', lsProps, "PerformanceGoal" -> "' ~ $performanceGoal ~ '"];';
    $spec ~= 'If[ TrueQ[res === $Failed],';
    $spec ~= '  aRes = <|"Error" -> "$Failed"|>,';
    $spec ~= '  aRes = Map[AssociationThread[lsProps, #] &, res]';
    $spec ~= '];';
    $spec ~= 'ExportString[aRes, "JSON", "Compact" -> True]';

    # Send code through ZMQ
    $receiver.send($spec);

    # Receive result from ZMQ
    my $message = $receiver.receive();

    # Return result
    $message.data-str
}

