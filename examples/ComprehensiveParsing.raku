use v6;

use lib './lib';
use lib '.';

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::ComprehensiveTranslation;

my Str $format = 'raku';

say "=" x 30;

#my @testCommands = (
#'DSL MODULE DSL::English::DataQueryWorkflows; DSL TARGET R-tidyverse; use dfTitanic; cross tabulate passengerSex and passengerClass',
#'DSL TARGET R-base; use dfTitanic; cross tabulate passengerSex and passengerClass',
#'use dfTitanic; cross tabulate passengerSex and passengerClass',
#'DSL SMRMon; use dfTitanic; create a recommender; recommend by profile male and 1st',
#'use dfTitanic; create a recommender; recommend by profile male and 1st',
#'DSL LSAMon; DSL TARGET R-LSAMon; create with aTexts; create document term matrix; extract 12 topics with method SVD',
#'create with aTexts; create document term matrix; extract 12 topics with method SVD',
#'create with aTexts; create document term matrix; extract 12 topics with method SVD',
#'create recommender with dfTitanic; recommend by profile male; echo value',
#'use dfTitanic;
#select the columns name, species, mass and height;
#cross tabulate species over mass'
#);
#
my @testCommands = (
'create recommender with dfTitanic; recommend by profile male; echo value',
'DSL TARGET WL-SMRMon; create recommender with dfTitanic; recommend by profile male; echo value',
'DSL MODULE SMRMon; create recommender with dfTitanic; recommend by profile male; echo value',
'use dfTitanic; select the columns name, species, mass and height; cross tabulate species over mass',
'use dfStarwars; select species, mass and height; cross tabulate species over mass;',
'DSL MODULE DataQueryWorkflows; USER ID mimiMal233; use dfStarwars; select species, mass and height; cross tabulate species over mass;',
'USER IDENTIFIER 8989-jkko-9009-klkl; I want to eat a Chiese lunch',
'USER IDENTIFIER NONE; I want to eat a Greek protein lunch',
'DSL MODULE FoodPrep; I want to eat a Chinese lunch;'
);



for @testCommands -> $c {
    say "=" x 30;
    say $c;
    say '-' x 30;
    my $start = now;
    my $res = ToDSLCode($c, language => "English", :$format, :guessGrammar, defaultTargetsSpec => 'WL');
    say "time:", now - $start;
    say $res;
};


