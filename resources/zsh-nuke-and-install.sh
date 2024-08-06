#! /bin/zsh

## Comment out if there is no zef:
#zef nuke home
#
## Comment out if there is no zef:
#zef nuke site
#
# Edit the following line to be the correct directory name of the zef repository:
#cd ~/GitHub/ugexe/zef
##
#raku -I. bin/zef install .
##
#cd -

## Install prove6
#zef install App::Prove6
#zef install Linenoise

## Install cro
#zef install --/test cro

## Install utility (required) packages
zef install 'Hash::Merge:ver<2.0.0>'
zef install silently
zef install XDG::BaseDirectory

## Install DSL Raku packages
zef install https://github.com/antononcube/Raku-Lingua-NumericWordForms.git --force-install --/test
zef install https://github.com/antononcube/Raku-Chemistry-Stoichiometry.git --force-install --/test
zef install https://github.com/antononcube/Raku-Data-Generators.git --force-install --/test

# Beware potential installation problems of "Text::Wrap".
# "Text::Wrap" is needed by "Pretty::Table" (used in "Data::Reshapers".)
zef install Text::Wrap --force-install --/test

zef install https://github.com/antononcube/Raku-Data-TypeSystem.git --force-install --/test
zef install https://github.com/antononcube/Raku-Data-Reshapers.git --force-install --/test
zef install https://github.com/antononcube/Raku-Data-Summarizers.git --force-install --/test
zef install https://github.com/antononcube/Raku-Data-ExampleDatasets.git --force-install --/test
zef install https://github.com/antononcube/Raku-Math-DistanceFunctions-Edit.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Shared.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Entity-Foods.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Entity-Geographics.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Entity-Jobs.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Entity-Metadata.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-SearchEngineQueries.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-DataAcquisitionWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-FoodPreparationWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-DSL-English-RecruitingWorkflows.git --force-install --/test 
zef install https://github.com/antononcube/Raku-ML-StreamsBlendingRecommender.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Bulgarian.git --force-install --/test
zef install https://github.com/antononcube/Raku-DSL-Translators.git --force-install --/test

## Install packages used to invoke DSL::Translators
## in R, WL, Jupyter notebooks and Markdown, Org-mode, Pod6 files.
#zef install Net::ZMQ --force-install --/test
#zef install Text::CodeProcessing --force-install --/test