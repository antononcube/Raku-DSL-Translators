use v6.d;

unit module DSL::Translators::ComprehensiveTranslation;

#-----------------------------------------------------------
use DSL::Shared::Utilities::MetaSpecsProcessing;

#-----------------------------------------------------------
use JSON::Fast;
use ML::TriesWithFrequencies;
use ML::TriesWithFrequencies::Trie;

#-----------------------------------------------------------
use DSL::English::ClassificationWorkflows;
use DSL::English::DataQueryWorkflows;
use DSL::English::EpidemiologyModelingWorkflows;
use DSL::English::LatentSemanticAnalysisWorkflows;
use DSL::English::QuantileRegressionWorkflows;
use DSL::English::RecommenderWorkflows;
use DSL::English::SearchEngineQueries;
use DSL::English::FoodPreparationWorkflows;
use DSL::English::DataAcquisitionWorkflows;
use DSL::English::RecruitingWorkflows;

#-----------------------------------------------------------
# DSL target to DSL module
#-----------------------------------------------------------

my %moduleToPythonTarget =

        "DSL::English::ClassificationWorkflows" => "Python-ClCon",
        "DSL::English::DataQueryWorkflows" => "Python-pandas",
        "DSL::English::EpidemiologyModelingWorkflows" => "Python-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "Python-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "Python-QRMon",
        "DSL::English::RecommenderWorkflows" => "Python-SMRMon",
        "DSL::English::SearchEngineQueries" => "Python-pandas",
        "DSL::English::DataAcquisitionWorkflows" => "Python-Ecosystem",
        "DSL::English::RecruitingWorkflows" => "Python-Ecosystem";


my %moduleToRTarget =

        "DSL::English::ClassificationWorkflows" => "R-ClCon",
        "DSL::English::DataQueryWorkflows" => "R-tidyverse",
        "DSL::English::EpidemiologyModelingWorkflows" => "R-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "R-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "R-QRMon",
        "DSL::English::RecommenderWorkflows" => "R-SMRMon",
        "DSL::English::SearchEngineQueries" => "R-tidyverse",
        "DSL::English::FoodPreparationWorkflows" => "R-Ecosystem",
        "DSL::English::DataAcquisitionWorkflows" => "R-Ecosystem",
        "DSL::English::RecruitingWorkflows" => "R-Ecosystem";


my %moduleToRakuTarget =

        "DSL::English::DataQueryWorkflows" => "Raku-Reshapers",
        "DSL::English::RecommenderWorkflows" => "Raku-SBR",
        "DSL::English::SearchEngineQueries" => "Raku-Reshapers",
        "DSL::English::FoodPreparationWorkflows" => "Raku-Ecosystem",
        "DSL::English::DataAcquisitionWorkflows" => "Raku-Ecosystem",
        "DSL::English::RecruitingWorkflows" => "Raku-Ecosystem";

my %moduleToWLTarget =

        "DSL::English::ClassificationWorkflows" => "WL-ClCon",
        "DSL::English::DataQueryWorkflows" => "WL-System",
        "DSL::English::EpidemiologyModelingWorkflows" => "WL-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "WL-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "WL-QRMon",
        "DSL::English::RecommenderWorkflows" => "WL-SMRMon",
        "DSL::English::SearchEngineQueries" => "WL-SMRMon",
        "DSL::English::FoodPreparationWorkflows" => "WL-Ecosystem",
        "DSL::English::DataAcquisitionWorkflows" => "WL-Ecosystem",
        "DSL::English::RecruitingWorkflows" => "WL-Ecosystem";

my %moduleToBulgarianTarget =
        ('DSL::English::ClassificationWorkflows',
         'DSL::English::DataQueryWorkflows',
         'DSL::English::EpidemiologyModelingWorkflows',
         'DSL::English::LatentSemanticAnalysisWorkflows',
         'DSL::English::QuantileRegressionWorkflows',
         'DSL::English::RecommenderWorkflows',
         'DSL::English::SearchEngineQueries') X=> 'Bulgarian';

my %moduleToEnglishTarget = %moduleToBulgarianTarget.keys X=> 'English';

my %moduleToKoreanTarget = %moduleToBulgarianTarget.keys X=> 'Korean';

my %moduleToRussianTarget = %moduleToBulgarianTarget.keys X=> 'Russian';

my %moduleToSpanishTarget = %moduleToBulgarianTarget.keys X=> 'Spanish';

my %specToModuleToTarget =
        'Bulgarian' => %moduleToBulgarianTarget,
        'English' => %moduleToEnglishTarget,
        'Korean' => %moduleToKoreanTarget,
        'Python' => %moduleToPythonTarget,
        'R' => %moduleToRTarget,
        'Raku' => %moduleToRakuTarget,
        'Russian' => %moduleToRussianTarget,
        'Spanish' => %moduleToSpanishTarget,
        'WL' => %moduleToWLTarget;

# Make target-to-module rules by inverting the module-to-target rules
my %targetToModule = reduce({ $^a.push($^b.invert) }, {}, |%specToModuleToTarget.values);

# Make target-to-module rules by inverting the module-to-target rules and modifying the targets, e.g. "R-LSAMon" to "R::LSAMon"
my %targetToModule2 = reduce({ $^a.push($^b.deepmap({ $_.subst('-', '::'):g }).invert) }, {}, |%specToModuleToTarget.values);

# Make target-to-module rules by inverting the module-to-target rules and reversing the targets components int "LSAMon::R" to "ClCon::WL"
my %targetToModule3 = reduce({ $^a.push($^b.deepmap({ $_.split('-').reverse.join('::') }).invert) }, {}, |%specToModuleToTarget.values);

# Join the two target-to-module dictionaries
%targetToModule = %targetToModule, %targetToModule2, %targetToModule3;

#-----------------------------------------------------------
# DSL module to DSL grammar
#-----------------------------------------------------------
my %moduleToDSLGrammar =

        "DSL::English::ClassificationWorkflows" => DSL::English::ClassificationWorkflows::Grammar,
        "DSL::English::DataQueryWorkflows" => DSL::English::DataQueryWorkflows::Grammar,
        "DSL::English::EpidemiologyModelingWorkflows" => DSL::English::EpidemiologyModelingWorkflows::Grammar,
        "DSL::English::LatentSemanticAnalysisWorkflows" => DSL::English::LatentSemanticAnalysisWorkflows::Grammar,
        "DSL::English::QuantileRegressionWorkflows" => DSL::English::QuantileRegressionWorkflows::Grammar,
        "DSL::English::RecommenderWorkflows" => DSL::English::RecommenderWorkflows::Grammar,
        "DSL::English::SearchEngineQueries" => DSL::English::SearchEngineQueries::Grammar,
        "DSL::English::FoodPreparationWorkflows" => FoodPreparationWorkflowsGrammar(),
        "DSL::English::DataAcquisitionWorkflows" => DataAcquisitionWorkflowsGrammar(),
        "DSL::English::RecruitingWorkflows" => RecruitingWorkflowsGrammar();

#-----------------------------------------------------------
# DSL module to DSL workflow code function
#-----------------------------------------------------------
my %moduleToDSLFunction =

        "DSL::English::ClassificationWorkflows" => "ToClassificationWorkflowCode",
        "DSL::English::DataQueryWorkflows" => "ToDataQueryWorkflowCode",
        "DSL::English::EpidemiologyModelingWorkflows" => "ToEpidemiologyModelingWorkflowCode",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "ToLatentSemanticAnalysisWorkflowCode",
        "DSL::English::QuantileRegressionWorkflows" => "ToQuantileRegressionWorkflowCode",
        "DSL::English::RecommenderWorkflows" => "ToRecommenderWorkflowCode",
        "DSL::English::SearchEngineQueries" => "ToSearchEngineQueryCode",
        "DSL::English::FoodPreparationWorkflows" => "ToFoodPreparationWorkflowCode",
        "DSL::English::DataAcquisitionWorkflows" => "ToDataAcquisitionWorkflowCode",
        "DSL::English::RecruitingWorkflows" => "ToRecruitingWorkflowCode";


#-----------------------------------------------------------
# Shortcuts for DSL module specs
#-----------------------------------------------------------
my %englishModuleFunctions =

        "DSL::English::ClassificationWorkflows" => &ToClassificationWorkflowCode,
        "DSL::English::DataQueryWorkflows" => &ToDataQueryWorkflowCode,
        "DSL::English::EpidemiologyModelingWorkflows" => &ToEpidemiologyModelingWorkflowCode,
        "DSL::English::LatentSemanticAnalysisWorkflows" => &ToLatentSemanticAnalysisWorkflowCode,
        "DSL::English::QuantileRegressionWorkflows" => &ToQuantileRegressionWorkflowCode,
        "DSL::English::RecommenderWorkflows" => &ToRecommenderWorkflowCode,
        "DSL::English::SearchEngineQueries" => &ToSearchEngineQueryCode,
        "DSL::English::FoodPreparationWorkflows" => &ToFoodPreparationWorkflowCode,
        "DSL::English::DataAcquisitionWorkflows" => &ToDataAcquisitionWorkflowCode,
        "DSL::English::RecruitingWorkflows" => &ToRecruitingWorkflowCode;


#-----------------------------------------------------------
# Module shortcut rules
#-----------------------------------------------------------

my %moduleToShortcuts =
        "DSL::English::ClassificationWorkflows" =>
                $["ClCon", "DSL::English::ClassificationWorkflows", "ClassificationWorkflows", "Classification"],
        "DSL::English::DataAcquisitionWorkflows" =>
                $["DSL::English::DataAcquisitionWorkflows", "DataAcquisition", "DataAcquisitionWorkflows", "DataAcquirer"],
        "DSL::English::DataQueryWorkflows" =>
                $["DataQuery", "DSL::English::DataQueryWorkflows", "DataWrangling", "DataQueryWorkflows"],
        "DSL::English::EpidemiologyModelingWorkflows" =>
                $["EpidemiologicModeling", "EpidemiologyModeling", "EpidemiologyModelingWorkflows", "DSL::English::EpidemiologyModelingWorkflows", "ECMMon"],
        "DSL::English::FoodPreparationWorkflows" =>
                $["FoodPreparationWorkflows", "FoodPrep", "FoodPreparation", "DSL::English::FoodPreparationWorkflows"],
        "DSL::English::LatentSemanticAnalysisWorkflows" =>
                $["LSAMon", "DSL::English::LatentSemanticAnalysisWorkflows", "LatentSemanticAnalysis", "LatentSemanticAnalysisWorkflows"],
        "DSL::English::QuantileRegressionWorkflows" =>
                $["RegressionWorkflows", "QuantileRegressionWorkflows", "QuantileRegression", "QRMon", "DSL::English::QuantileRegressionWorkflows"],
        "DSL::English::RecommenderWorkflows" =>
                $["Recommenders", "RecommenderWorkflows", "SMRMon", "Recommendations", "DSL::English::RecommenderWorkflows"],
        "DSL::English::RecruitingWorkflows" =>
                $["RecruitingWorkflows", "DSL::English::RecruitingWorkflows", "Recruiting"],
        "DSL::English::SearchEngineQueries" =>
                $["SearchEngineQueries", "DSL::English::SearchEngineQueries", "SearchEngine"];

my %englishModuleShortcuts = %moduleToShortcuts.map({ $_.value.map(-> $x { $x => $_.key }) }).flat;

my %bulgarianModuleShortcuts = %englishModuleShortcuts;

#-----------------------------------------------------------
my %languageDispatch =
        English => %englishModuleShortcuts,
        Bulgarian => %bulgarianModuleShortcuts,
        Portuguese => %bulgarianModuleShortcuts,
        Russian => %bulgarianModuleShortcuts;

#-----------------------------------------------------------
# DSL classifier
#-----------------------------------------------------------

# See the BEGIN block at the bottom of the file.

my ML::TriesWithFrequencies::Trie $trDSL .= new;
my $knownWords;
my @dslLabels;

sub get-dsl-trie-classifier() is export {

    my $fileName = %?RESOURCES<dsl-trie-classifier.json>;

    my ML::TriesWithFrequencies::Trie $trDSL .= new;

    my Str $dslClassifierMapFormatCode = slurp($fileName.IO);

    my %trieMap = from-json($dslClassifierMapFormatCode);

    $trDSL.from-json-map-format(%trieMap);

    return $trDSL;
}

my %dslLabelToModule =
        <Recommendations Classification NeuralNetworkCreation LatentSemanticAnalysis RandomTabularDataset QuantileRegression>
        Z=>
        <DSL::English::RecommenderWorkflows DSL::English::ClassificationWorkflows
         DSL::English::ClassificationWorkflows DSL::English::LatentSemanticAnalysisWorkflows
         DSL::English::DataQueryWorkflows DSL::English::QuantileRegressionWorkflows>;

my %dslLabelToModule2 =
        ["RecommenderWorkflows",
         "ClassificationWorkflows",
         "LatentSemanticAnalysisWorkflows",
         "DataQueryWorkflows", "QuantileRegressionWorkflows"].map({ $_ => "DSL::English::$_" });

%dslLabelToModule = %dslLabelToModule , %dslLabelToModule2;

#-----------------------------------------------------------
#| Classifies commands to DSL workflow labels.
proto sub dsl-classify($command) is export {*}

multi sub dsl-classify(@commands) {
    return dsl-classify(@commands.join("\n"));
}

multi sub dsl-classify(Str $command) {
    return $trDSL.classify($command.lc.words.grep({ $_ ∈ $knownWords }).sort, prop => 'Probabilities'):!verify-key-existence;
}

#| #-----------------------------------------------------------
#| Finds most applicable DSL grammar.
proto dsl-most-applicable(Str $command, %dslToGrammar = %moduleToDSLGrammar, Int :$n = 10, Str :$norm = 'sum',
                          Int :$batch = 64, Int :$degree = 1) is export {*};
#= Uses parsing residuals -- the DSL grammar with the smallest count of un-parsed characters is the most applicable.

multi dsl-most-applicable(Str $command, %dslToGrammar = %moduleToDSLGrammar, Int :$n = 10, Str :$norm = 'sum',
                          Int :$batch = 64, Int :$degree = 1) {

    die "The argument \$n is expected to be a postive integer." unless $n > 0;

    # "Elegant" version, but enumerates all DSLs.
    # my @pairs = map({ $_.key => get-dsl-parser-residual($_.value, $command, :$norm) }, %dslToGrammar.pairs);

    # "Optimized" version, stops as soon as
    # the residual is 0 and the attempted grammar is not 'DSL::English::SearchEngineQueries'.
    my @pairs;
    if $degree <= 1 {

        # Classification of the command into a DSL label
        my %clRes = $trDSL.classify($command.lc.words.grep({ $_ ∈ $knownWords }).sort, prop => 'Probabilities'):!verify-key-existence;

        # Replace DSL labels with module names
        %clRes = %clRes.map({ (%dslLabelToModule{$_.key}:exists ?? %dslLabelToModule{$_.key} !! $_.key) => $_.value });

        # Make module-name-to-probability hash
        %clRes = %clRes, %( %dslToGrammar.grep({ $_.key ∉ %clRes })>>.key X=> 0e0);

        # Try out the parsers with starting in the highest probability modules first
        for %clRes.pairs.sort(-*.value) -> $p {
            my $pres = get-dsl-parser-residual(%dslToGrammar{$p.key}, $command, :$norm);
            @pairs = @pairs.append($p.key => $pres);
            last if $pres == 0 and $p.key ne 'DSL::English::SearchEngineQueries';
        }
    } else {
        # Using the "elegant" version for parallel execution.
        # @pairs = race %dslToGrammar.pairs.race(:$batch, :$degree).map({ $_.key => get-dsl-parser-residual($_.value, $command, :$norm) });

        @pairs = do race for %dslToGrammar.list.race(:$batch, :$degree) -> $p {
            my $pres = get-dsl-parser-residual($p.value, $command, :$norm);
            #say "From thread {$*THREAD.id} : {$p.key} => $pres";
            $p.key => $pres
        }
    }

    @pairs = @pairs.sort({ $_.value });

    return $n < @pairs.elems ?? @pairs[^$n] !! @pairs;
}

#-----------------------------------------------------------
#| Picks most applicable DSL grammar.
proto dsl-pick(Str $command, %dslToGrammar = %moduleToDSLGrammar, Str :$norm = 'sum', Int :$degree = 1) is export {*};

multi dsl-pick(Str $command, %dslToGrammar = %moduleToDSLGrammar, Str :$norm = 'sum', Int :$degree = 1) {
    my @pairs = dsl-most-applicable($command, %dslToGrammar, n => 3, :$norm, :$degree, batch => max(floor(%dslToGrammar
            .elems / $degree), 1));

    my @pairs2 = grep({ not($_.key eq "DSL::English::SearchEngineQueries") }, @pairs);

    if @pairs.elems == @pairs2.elems {
        return @pairs.min({ $_.value }).key;
    }

    my %res = Hash.new(@pairs);
    my Int $minVal2 = @pairs.min({ $_.value }).value;

    if %res{"DSL::English::SearchEngineQueries"} == 0 and $minVal2 > 15 {
        return "DSL::English::SearchEngineQueries";
    } else {
        return @pairs2.min({ $_.value }).key;
    }
}

#-----------------------------------------------------------
#| Get AST tree for a given command and (detected) DSL.
sub get-ast(Str:D $command, Str:D $dsl) {
    my $gram = %moduleToDSLGrammar{$dsl};

    $gram.parse($command, rule => 'workflow-commands-list')
}

#-----------------------------------------------------------
#| Post process interpretation results.
sub post-process-result(%rakuRes, Str $format) {
    if $format.lc (elem) <object hash> {
        return %rakuRes;
    } elsif $format.lc eq 'raku' {
        return %rakuRes.raku;
    } elsif $format.lc eq 'json' {
        return to-json(%rakuRes);
    } elsif $format.lc eq 'code' {
        return %rakuRes<CODE>;
    } else {
        warn "Unknown format: $format. Using 'Hash' instead.";
        return %rakuRes;
    }
}

#-----------------------------------------------------------
#|( Translates natural language commands into programming code.
    * C<$command> is a string with one or many commands (separated by ';').
    * C<$language> is the natural language to translate from.
    * C<$format> is the format of the output, one of 'ast', 'code', 'hash', 'json', or 'raku'.
    * C<$guess-grammar> is a Boolean whether to guess the DSL grammar of C<$command>.
    * C<$default-targets-spec> is a programming language name, one of 'Python', 'R', 'Raku', 'WL'.
    * C<$degree> is a positive integer for the degree parallelism.
    * C<$ast> is a Boolean whether a Match object be returned for the key "CODE"?
)
our proto ToDSLCode(Str $command, |) is export {*};

multi sub ToDSLCode(@commands, *%args) {
    return ToDSLCode(@commands.join("\n;"), |%args);
}

multi sub ToDSLCode(Str $command,
                    Str :$language = 'English',
                    Str :$format is copy = 'hash',
                    Bool :guessGrammar(:$guess-grammar) = True,
                    Str :defaultTargetsSpec(:$default-targets-spec) = 'R',
                    Int :$degree = 1,
                    Bool :$ast = False,
                    Bool :$code = False) {

    die "Unknown natural language: $language." unless %languageDispatch{$language}:exists;

    die "Unknown default targets spec: $default-targets-spec." unless %specToModuleToTarget{$default-targets-spec}:exists;

    if $code { $format = "code" }

    # Get DSL specifications
    my %dslSpecs = get-dsl-spec($command, 'any');

    # Get DSL module
    if not (%dslSpecs and %dslSpecs{'DSL'}:exists) {

        die "No DSL module specification command." unless $guess-grammar;

        if %dslSpecs{'DSLTARGET'}:exists and %targetToModule{%dslSpecs{'DSLTARGET'}}:exists {
            # Restrict the DSL guessing to the specified target DSLs
            my %small = %moduleToDSLGrammar{|%targetToModule{%dslSpecs{'DSLTARGET'}}}:p;
            %dslSpecs = %dslSpecs, 'DSL' => dsl-pick($command, %small);
        } else {
            %dslSpecs = %dslSpecs, 'DSL' => dsl-pick($command, %moduleToDSLGrammar, :$degree);
        }
    }

    my Str $dsl = %dslSpecs{'DSL'};
    $dsl = %languageDispatch{$language}{$dsl};

    die "Unknown DSL spec: $dsl." unless %languageDispatch{$language}{$dsl}:exists;

    warn "Cannot find interpretation target for DSL spec: $dsl and default target spec $default-targets-spec"
    unless %specToModuleToTarget{$default-targets-spec}{$dsl}:exists;

    # Get DSL target
    my Str $dslTarget = %specToModuleToTarget{$default-targets-spec}{$dsl};

    $dslTarget = %dslSpecs{'DSLTARGET'}:exists ?? %dslSpecs{'DSLTARGET'} !! $dslTarget;

    # Get DSL function
    my &dslFunc = %englishModuleFunctions{$dsl};

    # Get user specifications
    my %userSpecs = get-user-spec($command);

    if not so (%userSpecs and %userSpecs{'USERID'}:exists) {
        %userSpecs = %userSpecs, USERID => '';
    } elsif %userSpecs{'USERID'} (elem) <NONE NULL> {
        %userSpecs = %userSpecs, USERID => '';
    }

    # DSL translate
    my $translation = $ast ?? get-ast($command, $dsl) !! &dslFunc($command, $dslTarget, :$language, format => 'hash');

    if $ast {
        $translation = { CODE => $translation }
    }

    # Handle failure from the parser-interpreters
    CATCH {
        default {
            my %rakuRes = Hash.new(%dslSpecs, %userSpecs, { CODE => '', DSL => $dsl, DSLTARGET => $dslTarget,
                                                            DSLFUNCTION => &dslFunc.raku, COMMAND => $command,
                                                            SETUPCODE => '' });
            return post-process-result(%rakuRes, $format)
        }
    }

    # Result
    my %rakuRes = Hash.new(%dslSpecs, %userSpecs, %($translation.pairs), { DSL => $dsl, DSLTARGET => $dslTarget,
                                                                           DSLFUNCTION => &dslFunc.raku,
                                                                           COMMAND => $command });

    %rakuRes = %rakuRes, %userSpecs;
    %rakuRes = %rakuRes.sort({ $^a.key });

    return post-process-result(%rakuRes, $format)
}

#-----------------------------------------------------------
#| Converts parsed results into JSON-marshal-able hashes.
sub to-pairs($m) {
    given $m {
        when Grammar | Match {
            my $k = $_.orig.substr($_.from .. $_.to - 1).trim;
            $k => to-pairs($_.hash)
        }
        when Hash | Map { $_.pairs.map({ $_.key => to-pairs($_.value) }).hash }
        when Array | List { $_.map({ to-pairs($_) }) }
        default { $_ }
    }
}

#-----------------------------------------------------------
#|( Translates natural language commands into Abstract Syntax Trees (ASTs).
    * C<$command> is a string with one or many commands (separated by ';').
    * C<$language> is the natural language to translate from.
    * C<$format> is the format of the output one of 'raku' or 'json'.
    * C<$guessGrammar> is a Boolean whether to guess the DSL grammar of C<$command>.
    * C<$default-targets-spec> is a programming language name, one of 'Python', 'R', 'WL'.
    * C<$as-hash> is a Boolean whether to return the AST as Hash.
    * C<$degree> is a positive integer for the degree parallelism.
)
sub ToDSLSyntaxTree(Str $command,
                    Str :$language = 'English',
                    Str :$format = 'hash',
                    Bool :guessGrammar(:$guess-grammar) = True,
                    Str :defaultTargetsSpec(:$default-targets-spec) = 'R',
                    Bool :$as-hash = True,
                    Int :$degree = 1) is export {

    # Call ToDSLCode
    my %ast = ToDSLCode($command, :$language, format => 'hash', :$guess-grammar, :$default-targets-spec, :$degree):ast;

    # Convert to Hash pairs
    if $as-hash {
        %ast<CODE> = to-pairs(%ast<CODE>)
    }

    # Result
    if $format.lc (elem) <object hash> {
        return %ast;
    } elsif $format.lc eq 'raku' {
        return %ast.raku;
    } elsif $format.lc eq 'json' {
        %ast<CODE> = to-pairs(%ast<CODE>);
        return to-json(%ast);
    } elsif $format.lc eq 'code' {
        return %ast<CODE>;
    } else {
        warn "Unknown format: $format. Using 'Hash' instead.";
        return %ast;
    }
}
#= This function uses C<ToDSLCode> with C<ast => True>.

#===========================================================
# Optimization
#===========================================================

($trDSL, $knownWords, @dslLabels) = BEGIN {
    my ML::TriesWithFrequencies::Trie $tr .= new;
    $tr = get-dsl-trie-classifier();
    my $words = Set(unique($tr.words.flat>>.lc));
    ($tr, $words, |$tr.leaf-probabilities.keys.Array)
}