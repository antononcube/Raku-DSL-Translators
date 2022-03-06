use v6.d;

use DSL::Shared::Utilities::ComprehensiveTranslation;

use JSON::Marshal;

use Test;

plan 4;

##-----------------------------------------------------------
## Setup
##-----------------------------------------------------------

my %defaultOpts = language => 'English', format => 'hash', :guessGrammar, defaultTargetsSpec => 'R', degree => 1;

my $command0 = '
create with SEI2HR;
assign 100000 to total population;
set infected normally symptomatic population to be 0;
set infected severely symptomatic population to be 1;
assign 0.56 to contact rate of infected normally symptomatic population;
assign 0.58 to contact rate of infected severely symptomatic population;
assign 0.1 to contact rate of the hospitalized population;
simulate for 240 days;
plot results;
';

##-----------------------------------------------------------
## 1
##-----------------------------------------------------------

my $command1 = 'DSL MODULE EpidemiologyModelingWorkflows;' ~ $command0;

my $expectedRes1 = '
ECMMonUnit( model = SEI2HRModel()) %>%
ECMMonAssignInitialConditions( initConds = c(TPt = 100000) ) %>%
ECMMonAssignInitialConditions( initConds = c(INSPt = 0) ) %>%
ECMMonAssignInitialConditions( initConds = c(ISSPt = 1) ) %>%
ECMMonAssignRateValues( rateValues = c(contactRateINSP = 0.56) ) %>%
ECMMonAssignRateValues( rateValues = c(contactRateISSP = 0.58) ) %>%
ECMMonAssignRateValues( rateValues = c(contactRateHP = 0.1) ) %>%
ECMMonSimulate(maxTime = 240) %>%
ECMMonPlotSolutions()
';

is-deeply ToDSLCode($command1, |%defaultOpts, format => 'code').subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "SEI2HR-command";

##-----------------------------------------------------------
## 2
##-----------------------------------------------------------

my $command2 = '
DSL TARGET R-ECMMon;
USER ID hhdf;
include setup code;' ~ $command1;
is-deeply ToDSLCode($command2, |%defaultOpts).keys.sort,
        <CODE COMMAND DSL DSLFUNCTION DSLTARGET SETUPCODE USERID>.sort,
        "SEI2HR-command-with-MODULE-TARGET-USERID-SETUP-hash-keys";

##-----------------------------------------------------------
## 3
##-----------------------------------------------------------

is-deeply ToDSLCode($command2, |%defaultOpts)<CODE>.subst(/ \s / , ''):g,
        $expectedRes1.subst( rx/ \s / , '' ):g,
        "SEI2HR-command-with-MODULE-TARGET-USERID-SETUP-code";


##-----------------------------------------------------------
## 4
##-----------------------------------------------------------

my $expectedRes2 = '
#devtools::install_github(repo = "antononcube/ECMMon-R")

library(magrittr)
library(deSolve)
library(ECMMon)
';

is-deeply ToDSLCode($command2, |%defaultOpts)<SETUPCODE>.subst(/ \s / , ''):g,
        $expectedRes2.subst( rx/ \s / , '' ):g,
        "SEI2HR-command-with-MODULE-TARGET-USERID-SETUP-setup-code";

done-testing;

