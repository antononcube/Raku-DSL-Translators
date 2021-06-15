
# Comment out if there is no zef:
zef nuke home

# Comment out if there is no zef:
zef nuke site

# Edit the following line to be the correct directory name of the zef repository:
cd ~/GitHub/ugexe/zef

raku -I. bin/zef install .

cd -

## Install prove6
zef install App::Prove6
zef install Linenoise

## Install cro
zef install --/test cro

## Install Sous-Chef Susana Raku packages
zef install https://github.com/antononcube/Raku-Lingua-NumericWordForms.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Shared.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Foods.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Geographics.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Jobs.git --force-install
zef install https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-SearchEngineQueries.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-FoodPreparationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-DataAcquisitionWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation.git --force-install --force-test
