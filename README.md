# Comprehensive Translation

This Raku package provides comprehensive multi-DSL translations.

To install DSL::Shared::Utilities::ComprehensiveTranslation certain DSL Raku modules have to be installed.

Here is installation code:

```shell
zef install https://github.com/antononcube/Raku-DSL-Shared.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-FoodPreparationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-SearchEngineQueries.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation --force-install --force-test
```

(The modules listed above are under development, that is why the installation commands have `--force-test`.)

Here is an example of automatic determination of the DSL grammar with the command:

```raku
say ToDSLCode('
    use dfTitanic;
    select the columns name, species, mass and height;
    cross tabulate species over mass', format => 'JSON');
```

that produces the following output (in JSON):

```raku
{
  "DSLTARGET": "R-tidyverse",
  "Code": "dfTitanic %>%\ndplyr::select(name, species, mass, height) %>%\n(function(x) as.data.frame(xtabs( formula = mass ~ species, data = x ), stringsAsFactors=FALSE ))",
  "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, Str $target = \"tidyverse\") {*}",
  "DSL": "DSL::English::DataQueryWorkflows"
}
```

In the example above the function `ToDSLCode` figured out that this sequence of commands specifies are data transformation workflow.