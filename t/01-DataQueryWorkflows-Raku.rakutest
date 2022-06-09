use v6.d;

use DSL::Shared::Utilities::ComprehensiveTranslation;

use JSON::Marshal;

use Test;

plan 4;

##-----------------------------------------------------------
## Setup
##-----------------------------------------------------------

my %defaultOpts = language => 'English', format => 'hash', :guessGrammar, defaultTargetsSpec => 'Raku', degree => 1;

my $command0 = '
load dataset / iris $ /;
group by Species;
show counts
';

##-----------------------------------------------------------
## 1
##-----------------------------------------------------------

my $command1 = 'DSL MODULE DataQuery;' ~ $command0;

my $expectedRes1 = '
my $obj = example-dataset(rx/ iris $ /) ;
$obj = group-by( $obj, "Species") ;
say "counts: ", $obj>>.elems';

is-deeply ToDSLCode($command1, |%defaultOpts, format => 'code').subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "simple-iris-command";

##-----------------------------------------------------------
## 2
##-----------------------------------------------------------

my $command2 = '
DSL TARGET Raku::Reshapers;
USER ID hhdf;
include setup code;' ~ $command1;
is-deeply ToDSLCode($command2, |%defaultOpts).keys.sort,
        <CODE COMMAND DSL DSLFUNCTION DSLTARGET SETUPCODE USERID>.sort,
        "simple-iris-command-with-MODULE-TARGET-USERID-SETUP-hash-keys";

##-----------------------------------------------------------
## 3
##-----------------------------------------------------------

is-deeply ToDSLCode($command2, |%defaultOpts)<CODE>.subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "simple-iris-command-with-MODULE-TARGET-USERID-SETUP-code";


##-----------------------------------------------------------
## 4
##-----------------------------------------------------------

my $expectedRes2 = '
use Data::Reshapers;
use Data::Summarizers;
use Data::ExampleDatasets;
';

is-deeply ToDSLCode($command2, |%defaultOpts)<SETUPCODE>.subst(/ \s / , ''):g,
        $expectedRes2.subst( rx/ \s / , '' ):g,
        "simple-iris-command-with-MODULE-TARGET-USERID-SETUP-setup-code";

done-testing;

