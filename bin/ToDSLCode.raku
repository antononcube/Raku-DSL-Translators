#!/usr/bin/env perl6

use DSL::Shared::Utilities::ComprehensiveTranslation;

sub MAIN(Str $command, Str :$language = 'English', Str :$format = 'raku', Bool :$guessGrammar = True, Str :$defaultTargetsSpec = 'R') {
    say ToDSLCode($command, :$language, :$format, :$guessGrammar , :$defaultTargetsSpec);
}
