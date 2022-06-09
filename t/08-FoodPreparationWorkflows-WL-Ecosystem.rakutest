use v6.d;

use DSL::Shared::Utilities::ComprehensiveTranslation;

use JSON::Marshal;

use Test;

plan 4;

##-----------------------------------------------------------
## Setup
##-----------------------------------------------------------

my %defaultOpts = language => 'English', format => 'hash', :guessGrammar, defaultTargetsSpec => 'WL', degree => 1;

my $command0 = '
I want to eat protein and fat lunch;
';

##-----------------------------------------------------------
## 1
##-----------------------------------------------------------

my $command1 = 'DSL MODULE FoodPreparation;' ~ $command0;

my $expectedRes1 = '
smrSCS \[DoubleLongRightArrow]
SMRMonRecommendByProfile[ {"PeriodMeal:lunch", "Ingredient:protein", "Ingredient:fat"} ] \[DoubleLongRightArrow]
SMRMonJoinAcross["Warning"->False] \[DoubleLongRightArrow]
SMRMonTakeValue[]
';

is-deeply ToDSLCode($command1, |%defaultOpts, format => 'code').subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "simple-jobs-command";

##-----------------------------------------------------------
## 2
##-----------------------------------------------------------

my $command2 = '
DSL TARGET WL-Ecosystem;
USER ID hhdf;
include setup code;' ~ $command1;

my $expectedRes2 = '
smrSCS \[DoubleLongRightArrow]
SMRMonRecommendByProfile[ {"PeriodMeal:lunch", "Ingredient:protein", "Ingredient:fat", "UserID:hhdf"} ] \[DoubleLongRightArrow]
SMRMonJoinAcross["Warning"->False] \[DoubleLongRightArrow]
SMRMonTakeValue[]
';

is-deeply ToDSLCode($command2, |%defaultOpts).keys.sort,
        <CODE COMMAND DSL DSLFUNCTION DSLTARGET SETUPCODE USERID>.sort,
        "simple-lunch-command-with-MODULE-TARGET-USERID-SETUP-hash-keys";

##-----------------------------------------------------------
## 3
##-----------------------------------------------------------

is-deeply ToDSLCode($command2, |%defaultOpts)<CODE>.subst(/ \s / , ''):g,
        $expectedRes2.subst( rx/ \s / , '' ):g,
        "simple-lunch-command-with-MODULE-TARGET-USERID-SETUP-code";


##-----------------------------------------------------------
## 4
##-----------------------------------------------------------

my $expectedRes4 = '';

is-deeply ToDSLCode($command2, |%defaultOpts)<SETUPCODE>.subst(/ \s / , ''):g,
        $expectedRes4.subst( rx/ \s / , '' ):g,
        "simple-lunch-command-with-MODULE-TARGET-USERID-SETUP-setup-code";

done-testing;

