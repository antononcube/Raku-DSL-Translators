use v6.d;

use DSL::Shared::Utilities::ComprehensiveTranslation;

use JSON::Marshal;

use Test;

plan 4;

##-----------------------------------------------------------
## Setup
##-----------------------------------------------------------

my %defaultOpts = language => 'English', format => 'hash', :guessGrammar, defaultTargetsSpec => 'Python', degree => 1;

my $command0 = '
create from dfTitanic;
recommend by profile for male, 1st, and died;
join across with dfTitanic;
';

##-----------------------------------------------------------
## 1
##-----------------------------------------------------------

my $command1 = 'DSL MODULE RecommenderWorkflows;' ~ $command0;

my $expectedRes1 = '
obj = SparseMatrixRecommender().create_from_wide_form( data = dfTitanic).recommend_by_profile( profile = ["male", "1st", "died"]).join_across( data = dfTitanic )';

is-deeply ToDSLCode($command1, |%defaultOpts, format => 'code').subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "simple-Titanic-command";

##-----------------------------------------------------------
## 2
##-----------------------------------------------------------

my $command2 = '
DSL TARGET Python::SMRMon;
USER ID hhdf;
include setup code;' ~ $command1;
is-deeply ToDSLCode($command2, |%defaultOpts).keys.sort,
        <CODE COMMAND DSL DSLFUNCTION DSLTARGET SETUPCODE USERID>.sort,
        "simple-Titanic-command-with-MODULE-TARGET-USERID-SETUP-hash-keys";

##-----------------------------------------------------------
## 3
##-----------------------------------------------------------

is-deeply ToDSLCode($command2, |%defaultOpts)<CODE>.subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "simple-Titanic-command-with-MODULE-TARGET-USERID-SETUP-code";


##-----------------------------------------------------------
## 4
##-----------------------------------------------------------

my $expectedRes2 = '
from SparseMatrixRecommender import *
';

is-deeply ToDSLCode($command2, |%defaultOpts)<SETUPCODE>.subst(/ \s / , ''):g,
        $expectedRes2.subst( rx/ \s / , '' ):g,
        "simple-Titanic-command-with-MODULE-TARGET-USERID-SETUP-setup-code";

done-testing;

