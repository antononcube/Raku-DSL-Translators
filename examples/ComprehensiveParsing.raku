use v6;

use lib './lib';
use lib '.';

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::ComprehensiveTranslation;

use JSON::Marshal;

my Str $format = 'Hash';

say "=" x 30;

#my @testCommands = (
#'DSL MODULE DSL::English::DataQueryWorkflows; DSL TARGET R-tidyverse; use dfTitanic; cross tabulate passengerSex and passengerClass',
#'DSL TARGET R-base; use dfTitanic; cross tabulate passengerSex and passengerClass',
#'use dfTitanic; cross tabulate passengerSex and passengerClass',
#'DSL SMRMon; use dfTitanic; create a recommender; recommend by profile male and 1st',
#'use dfTitanic; create a recommender; recommend by profile male and 1st',
#'DSL LSAMon; DSL TARGET R-LSAMon; create with aTexts; create document term matrix; extract 12 topics with method SVD',
#'create with aTexts; create document term matrix; extract 12 topics with method SVD',
#'USER IDENTIFIER 8989-jkko-9009-klkl; I want to eat a Chiese lunch',
#'USER IDENTIFIER NONE; I want to eat a Greek protein lunch',
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
'create from textHamplet; make document term matrix; extract 12 topics with method NNMF',
'create from textHamplet; make document term matrix; apply lsi functions idf, none, cosine; extract 12 topics with method NNMF; show thesaurus for king and queen',
'DSL MODULE DataQueryWorkflows; USER ID mimiMal233; use dfStarwars; select species, mass and height; cross tabulate species over mass;',
'DSL MODULE FoodPrep; I want to eat a Chinese lunch;',
'DSL MODULE DataAcquisition; I want to acquire categorical data;',
"generate a random dataset with 200 rows and column names 'kira' and 'sala' in long form with 20 number of values",
'create from dsFin;
show data summary;
compute quantile regression fit with 12 knots and interpolation order 3;
show date list plots;
show relative errors',
'load data dsFin;
make a decision tree classifier;
show accuracy, precision and recall;
show roc plots',
"DSL MODULE DataQueryWorkflows;
DSL TARGET Julia-DataFrames;
use dfFineliFood;
delete column FOODNAME;
inner join with dfFineliFoodName over FOODID;
delete column LANG;
inner join with dfFineliProcess over PROCESS=THSCODE;
group by PROCESS;
show counts",
"DSL TARGET Julia-DataFrames;
use data dfMeals;
inner join with dfFinelyFoodName over FOODID;
group by 'Cuisine';
find counts",
"create from textHamlet;
make document term matrix with stemming FALSE and automatic stop words;
apply LSI functions global weight function inverse document frequency, local term weight function none, normalizer function Cosine;
extract 12 topics using method SVD and max steps 12 and 2 min number of documents per term;
show topics table with 10 terms;
show thesaurus table for king, castle, denmark;"
);

@testCommands = (
"DSL TARGET WL-LSAMon;
USER ID dfdfd;
create textHamplet;
make document term matrix;
extract 12 topics using non ngative matrix factorization;
echo topics table;
echo statistical thesaurus for queen, king, and grave"
);

my $res = ToDSLCode(@testCommands[0], language => 'English', format => 'json', :guessGrammar, defaultTargetsSpec => 'R', degree => 1);
say $res;
say "-" x 30;
say marshal($res).raku;

#my $ast = ToDSLCode(@testCommands[0], language => 'English', format => 'object', :guessGrammar, defaultTargetsSpec => 'R', degree => 1):ast;
#say $ast<CODE>.WHAT;

say "=" x 30;
my $ast = ToDSLSyntaxTree(@testCommands[0], language => 'English', format => 'object', :guessGrammar, defaultTargetsSpec => 'R', degree => 1):as-hash;
say $ast;
say "-" x 30;
say marshal($ast).raku;

say "=" x 60;
say dsl-translate("
use finData;
echo data summary;
compute quantile regression with 20 knots and probabilities 0.5 and 0.7;
show date list plots;
show error plots
", defaultTargetsSpec => "WL").raku;

#use MONKEY-SEE-NO-EVAL;
#my $gram = EVAL($res<DSL> ~ '::Grammar');
#
#say $gram.parse(@testCommands[0], rule => 'workflow-commands-list');

#
#for (1..6) -> $degree {
#    for @testCommand s -> $c {
#        say "=" x 30;
#        say $c;
#        say '-' x 30;
#        my $start = now;
#        my $res = ToDSLCode($c, language => "English", :$format, :guessGrammar, defaultTargetsSpec => 'WL', :$degree);
#        say "degree: $degree, time: ", now - $start;
#        say $res;
#    }
#}

#my %dslTimings;
#my %dslTimingsPerDegree;
#
#for (1..6) -> $degree {
#    my $startDegree = now;
#    for @testCommands -> $c {
#        my $start = now;
#        my $res = ToDSLCode($c, language => "English", :$format, :guessGrammar, defaultTargetsSpec => 'WL', :$degree);
#        %dslTimings.append( $degree, now - $start)
#    }
#    %dslTimingsPerDegree.append($degree, now - $startDegree)
#}
#
#say %dslTimingsPerDegree.sort({ $_.key});
#
#say %dslTimings.sort({ $_.key});