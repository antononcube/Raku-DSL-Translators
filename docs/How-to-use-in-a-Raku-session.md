# How to use "DSL::Translations" in a Raku session

## Introduction

----------

## Setup

```perl6
use DSL::Translators;
use Data::Importers;
use Data::Reshapers;
use Data::Generators;
```
```
# (Any)
```

-------

## Data wrangling

Data wrangling command:

```perl6
my $cmd = "DSL TARGET Raku::Reshapers;
use data dfMeals;
inner join with dfFinelyFoodName over FOODID;
group by 'Cuisine';
find counts";

text-stats($cmd)
```
```
# (chars => 123 words => 17 lines => 5)
```

Using `ToDSLCode`:

```perl6
ToDSLCode($cmd);
```
```
# {CODE => $obj = dfMeals ;
# $obj = join-across( $obj, dfFinelyFoodName, ("FOODID"), join-spec=>"Inner") ;
# $obj = group-by($obj, "Cuisine") ;
# say "counts: ", $obj>>.elems, COMMAND => DSL TARGET Raku::Reshapers;
# use data dfMeals;
# inner join with dfFinelyFoodName over FOODID;
# group by 'Cuisine';
# find counts, DSL => DSL::English::DataQueryWorkflows, DSLFUNCTION => proto sub ToDataQueryWorkflowCode (Str $command, |) {*}, DSLTARGET => Raku::Reshapers, USERID => }
```

Using the "web ready" `dsl-translation`:

```perl6
$cmd ==> dsl-translation(language => 'English', :prepend-setup-code)
```
```
# {CODE => use Data::Reshapers;
# use Data::Summarizers;
# use Data::ExampleDatasets;
# 
# my $obj;
# 
# $obj = dfMeals ;
# $obj = join-across( $obj, dfFinelyFoodName, ("FOODID"), join-spec=>"Inner") ;
# $obj = group-by($obj, "Cuisine") ;
# say "counts: ", $obj>>.elems, COMMAND => DSL TARGET Raku::Reshapers;
# use data dfMeals;
# inner join with dfFinelyFoodName over FOODID;
# group by 'Cuisine';
# find counts, DSL => DSL::English::DataQueryWorkflows, DSLFUNCTION => proto sub ToDataQueryWorkflowCode (Str $command, |) {*}, DSLTARGET => Raku::Reshapers, SETUPCODE => use Data::Reshapers;
# use Data::Summarizers;
# use Data::ExampleDatasets;
# 
# my $obj;
# , STDERR => , USERID => }
```

-------

## Latent Semantic Analysis

Latent Semantic Analysis (LSA) command:

```perl6
my $cmd = q:to/END/;
create from aDocs;
create document term matrix with stemming;
show document term matrix statistics;
apply the term weight functions IDF, None, Cosine;
extract 60 topics with the method NNMF;
echo topics table;
show statistical thesaurus for interested, likely, want
END

text-stats($cmd)
```
```
# (chars => 266 words => 39 lines => 7)
```

Using `ToDSLCode`:

```perl6
ToDSLCode($cmd);
```
```
# {CODE => LSAMonUnit(aDocs) %>%
# LSAMonMakeDocumentTermMatrix( stemWordsQ = TRUE, stemRules = NULL) %>%
# LSAMonEchoDocumentTermMatrixStatistics(logBase=10) %>%
# LSAMonApplyTermWeightFunctions(globalWeightFunction = "IDF", localWeightFunction = "None", normalizerFunction = "Cosine") %>%
# LSAMonExtractTopics( numberOfTopics = 60, method = "NNMF") %>%
# LSAMonEchoTopicsTable() %>%
# LSAMonEchoStatisticalThesaurus(words = c("interested", "likely", "want")), COMMAND => create from aDocs;
# create document term matrix with stemming;
# show document term matrix statistics;
# apply the term weight functions IDF, None, Cosine;
# extract 60 topics with the method NNMF;
# echo topics table;
# show statistical thesaurus for interested, likely, want
# , DSL => DSL::English::LatentSemanticAnalysisWorkflows, DSLFUNCTION => proto sub ToLatentSemanticAnalysisWorkflowCode (Str $command, |) {*}, DSLTARGET => R-LSAMon, USERID => }
```

Using the "web ready" `dsl-translation`:

```perl6
$cmd ==> dsl-translation(lang => 'English', to => 'WL', :setup) ==> { $_<CODE> }()
```
```
# Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/MonadicProgramming/MonadicLatentSemanticAnalysis.m"];
# 
# LSAMonUnit[aDocs] \[DoubleLongRightArrow]
# LSAMonMakeDocumentTermMatrix[ "StemmingRules" -> Automatic] \[DoubleLongRightArrow]
# LSAMonEchoDocumentTermMatrixStatistics["LogBase"->10] \[DoubleLongRightArrow]
# LSAMonApplyTermWeightFunctions["GlobalWeightFunction" -> "IDF", "LocalWeightFunction" -> "None", "NormalizerFunction" -> "Cosine"] \[DoubleLongRightArrow]
# LSAMonExtractTopics["NumberOfTopics" -> 60, Method -> "NNMF"] \[DoubleLongRightArrow]
# LSAMonEchoTopicsTable[ ] \[DoubleLongRightArrow]
# LSAMonEchoStatisticalThesaurus["Words" -> {"interested", "likely", "want"}]
```

### Web service

```perl6
dsl-web-translation($cmd, to => 'Python')
```
```
# {
#   "USERID": "",
#   "STDERR": "",
#   "DSLFUNCTION": "proto sub ToLatentSemanticAnalysisWorkflowCode (Str $command, |) {*}",
#   "COMMAND": "create from aDocs;\ncreate document term matrix with stemming;\nshow document term matrix statistics;\napply the term weight functions IDF, None, Cosine;\nextract 60 topics with the method NNMF;\necho topics table;\nshow statistical thesaurus for interested, likely, want\n",
#   "DSL": "DSL::English::LatentSemanticAnalysisWorkflows",
#   "CODE": "LatentSemanticAnalyzer(aDocs).make_document_term_matrix( stemming_rules = None).echo_document_term_matrix_statistics().apply_term_weight_functions(global_weight_func = \"IDF\", local_weight_func = \"None\", normalizer_func = \"Cosine\").extract_topics(number_of_topics = 60, method = \"NNMF\").echo_topics_table( ).echo_statistical_thesaurus([\"interested\", \"likely\", \"want\"])",
#   "DSLTARGET": "Python-LSAMon"
# }
```