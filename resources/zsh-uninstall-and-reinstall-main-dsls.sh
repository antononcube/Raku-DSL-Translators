#! /bin/zsh

## Uninstall
zef uninstall DSL::English::ClassificationWorkflows
zef uninstall DSL::English::DataQueryWorkflows
zef uninstall DSL::English::EpidemiologyModelingWorkflows
zef uninstall DSL::English::LatentSemanticAnalysisWorkflows
zef uninstall DSL::English::QuantileRegressionWorkflows
zef uninstall DSL::English::RecommenderWorkflows
zef uninstall DSL::Shared
zef uninstall Lingua::NumericWordForms

zef install https://github.com/antononcube/Raku-Lingua-NumericWordForms.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Shared.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows.git --force-install --/test
