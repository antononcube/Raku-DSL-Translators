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
zef install App::Prove6
zef install Linenoise

## Install cro
zef install --/test cro

## Install utility (required) packages
zef install Hash::Merge
zef install silently
zef install XDG::BaseDirectory

## Install DSL Raku packages
zef install https://github.com/antononcube/Raku-Lingua-NumericWordForms.git --force-install
zef install https://github.com/antononcube/Raku-Chemistry-Stoichiometry.git --force-install
zef install https://github.com/antononcube/Raku-Data-Generators.git --force-install

# This installation line for Text::Wrap is needed by Pretty::Table (used in Data::Reshapers.)
# For some reason from zef I was getting deficient version on 2021-12-21
#(base) [18:03]antonov/Raku-DSL-Shared-Utilities-ComprehensiveTranslation> zef install Text::Wrap --force-install
#===> Searching for: Text::Wrap
#===> Testing: _:ver<0.0.1>:auth<zef:codesections>
#===> Testing [OK] for _:ver<0.0.1>:auth<zef:codesections>
#===> Installing: _:ver<0.0.1>:auth<zef:codesections>
#(base) [18:03]antonov/Raku-DSL-Shared-Utilities-ComprehensiveTranslation> zef install https://github.com/jkramer/p6-Text-Wrap.git --force-install
#===> Testing: Text::Wrap:ver<0.0.3>
#===> Testing [OK] for Text::Wrap:ver<0.0.3>
#===> Installing: Text::Wrap:ver<0.0.3>
zef install https://github.com/jkramer/p6-Text-Wrap.git --force-install

zef install https://github.com/antononcube/Raku-Data-Reshapers.git --force-install
zef install https://github.com/antononcube/Raku-Data-Summarizers.git --force-install
zef install https://github.com/antononcube/Raku-Data-ExampleDatasets.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Shared.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Foods.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Geographics.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Jobs.git --force-install
zef install https://github.com/antononcube/Raku-DSL-Entity-Metadata.git --force-install
zef install https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-SearchEngineQueries.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-DataAcquisitionWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-FoodPreparationWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-English-RecruitingWorkflows.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-Shared-Utilities-ComprehensiveTranslation.git --force-install --force-test
zef install https://github.com/antononcube/Raku-ML-StreamsBlendingRecommender.git --force-install --force-test
zef install https://github.com/antononcube/Raku-DSL-Bulgarian.git --force-install --force-test

## Install packages used to invoke DSL::Shared::Utilities::ComprehensiveTranslation
## in R, WL, Jupyter notebooks and Markdown, Org-mode, Pod6 files.
zef install Net::ZMQ --force-install
zef install Text::CodeProcessing --force-install