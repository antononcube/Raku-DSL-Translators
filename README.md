# DSL::Translators (Comprehensive Translation by DSL parser-interpreters)

[![MacOS](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/macos.yml/badge.svg)](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/macos.yml)
[![Linux](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/linux.yml/badge.svg)](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/linux.yml)
[![Win64](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/windows.yml/badge.svg)](https://github.com/antononcube/Raku-DSL-Translators/actions/workflows/windows.yml)

[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This Raku package provides comprehensive multi-DSL translations.

-------

## Installation

To install 
`DSL::Translators` 
certain DSL Raku modules have to be installed.

See the installation code in the resource file ["zsh-nuke-and-install.sh"](./resources/zsh-nuke-and-install.sh). 

(The modules listed above are under development, that is why the installation commands have `--force-test`.)

-------

## Usage

Here we load the package:

```raku
use DSL::Translators;
```

Here is an example that shows:

- Automatic determination of the DSL grammar

- JSON format of the result

```raku
ToDSLCode('
    use dfStarWars;
    select the columns name, species, mass and height;
    cross tabulate species over mass', 
        format => 'JSON');
```
```
# {
#   "CODE": "dfStarWars %>%\ndplyr::select(name, species, mass, height) %>%\n(function(x) as.data.frame(xtabs( formula = mass ~ species, data = x ), stringsAsFactors=FALSE ))",
#   "USERID": "",
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "DSLTARGET": "R-tidyverse",
#   "COMMAND": "\n    use dfStarWars;\n    select the columns name, species, mass and height;\n    cross tabulate species over mass"
# }
```

In the example above the function `ToDSLCode` figured out that the sequence of commands (separated by semicolon)
specifies a 
[data transformation workflow](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows). 
See [AAr2].

Here is an example using Bulgarian data transformation spec that explicitly specifies:

- DSL parser to use (with the first command)
- Language (Bulgarian)
- Default targets spec that is usually a programming language name ("Python") 

```raku
ToDSLCode('
    DSL module DataQueryWorkflows;
    използвай dfStarWars;
    избери колоните name, species, mass и height;
    крос табулация на species върху mass', 
        language => 'Bulgarian',
        default-targets-spec => 'Python',
        format => 'Code');
```
```
# obj = dfStarWars.copy()
# obj = obj[["name", "species", "mass", "height"]]
# obj = pandas.crosstab( index = obj["species"], values = obj["mass"], aggfunc = "sum" )
```

The function `dsl-translation` is a version of `ToDSLCode` that is intended to be used in 
command line and web interfaces. It returns a `Hash` object. Here is an example:

```raku
my %res = dsl-translation('
    USER ID dd7833sa;
    DSL MODULE DataQueryWorkflows;
    use dfStarWars;
    select the columns name, species, mass and height;
    cross tabulate species over mass');
.say for %res;
```
```
# USERID => dd7833sa
# COMMAND => 
#     USER ID dd7833sa;
#     DSL MODULE DataQueryWorkflows;
#     use dfStarWars;
#     select the columns name, species, mass and height;
#     cross tabulate species over mass
# DSLTARGET => R-tidyverse
# DSLFUNCTION => proto sub ToDataQueryWorkflowCode (Str $command, |) {*}
# STDERR => 
# DSL => DSL::English::DataQueryWorkflows
# CODE => dfStarWars %>%
# dplyr::select(name, species, mass, height) %>%
# (function(x) as.data.frame(xtabs( formula = mass ~ species, data = x ), stringsAsFactors=FALSE ))
```

------

## CLI

The package provides several Command Line Interface (CLI) scripts:

| CLI                                               | Description                                                                                                   |
|---------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `dsl-translation`                                 | DSL translation with the package                                                                              | 
| `dsl-web-translation`                             | DSL translation using a Web service provided by this package                                                  | 
| `dsl-web-translation-service`                     | Starts a Web service for DSL translation                                                                      | 
| `dsl-web-translation-service-with-wolfram-engine` | Starts a Web service for DSL translation which can also use [Wolfram Engine](https://www.wolfram.com/engine/) | 

Here is the usage message of `dsl-translation`:

```shell
dsl-translation --help
```
```
# Translates natural language commands into programming code.
# Usage:
#   dsl-translation <command> [-f|--from-language=<Str>] [-t|--to-language=<Str>] [--format=<Str>] [--guess-grammar] [--degree[=UInt]] [--ast] [-c|--clipboard-command=<Str>] -- Translates natural language commands into programming code.
#   dsl-translation <progLang> <command> [-f|--from-language=<Str>] [--format=<Str>] [--guess-grammar] [--degree[=UInt]] [--ast] [-c|--clipboard-command=<Str>]
#   
#     <command>                       A string with one or many commands (separated by ';').
#     -f|--from-language=<Str>        Language to translate from; one of 'Bulgarian', 'English', 'Russian', or 'Whatever'. [default: 'Whatever']
#     -t|--to-language=<Str>          Language to translate to: one of 'Bulgarian', 'English', 'Python', 'R', 'Raku', 'Russian', or 'WL'; [default: 'R']
#     --format=<Str>                  The format of the output, one of 'automatic', 'ast', 'code', 'hash', 'json', or 'raku'. [default: 'automatic']
#     --guess-grammar                 Should the DSL grammar of $command of be guessed or not? [default: True]
#     --degree[=UInt]                 Positive integer for the degree parallelism. [default: 1]
#     --ast                           Should Match object be returned for the key "CODE" or not?, [default: False]
#     -c|--clipboard-command=<Str>    Clipboard command to use. [default: 'Whatever']
#     <progLang>                      Programming language.
# 
# 
# Details:
#     If --language is 'Whatever' then:
#         1. If at least 40% of the letters are Cyrillic then Bulgarian is used.
#         2. Otherwise English is used.
#     If --clipboard-command is the empty string then no copying to the clipboard is done.
#     If --clipboard-command is 'Whatever' then:
#         1. It is attempted to use the environment variable CLIPBOARD_COPY_COMMAND.
#             If CLIPBOARD_COPY_COMMAND is defined and it is the empty string then no copying to the clipboard is done.
#         2. If the variable CLIPBOARD_COPY_COMMAND is not defined then:
#             - 'pbcopy' is used on macOS
#             - 'clip.exe' on Windows
#             - 'xclip -sel clip' on Linux.
```

The DSL Web translation can be seen (tried on) with this [interactive interface](https://antononcube.shinyapps.io/DSL-evaluations/).

**Remark:** `dsl-web-translation-service` provides a service that has both grammar-based and LLM-based DSL translations.

------

## References

### Articles, blog posts

[AA1] Anton Antonov,
["Multi-language Data Wrangling and Acquisition Conversational Agents presentation"](https://rakuforprediction.wordpress.com/2021/07/21/multi-language-data-wrangling-and-acquisition-conversational-agents-presentation/),
(2021),
[RakuForPreiction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Fast and compact classifier of DSL commands"](https://rakuforprediction.wordpress.com/2022/07/31/fast-and-compact-classifier-of-dsl-commands/),
(2022),
[RakuForPreiction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["DSL::Bulgarian"](https://rakuforprediction.wordpress.com/2022/12/31/dslbulgarian/),
(2022),
[RakuForPreiction at WordPress](https://rakuforprediction.wordpress.com).

### Packages

[AAp1] Anton Antonov,
[DSL::English::ClassificationWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-ClassificationWorkflows),
(2020-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::English::DataAcquisitionWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-DataAcquisitionWorkflows),
(2021-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[DSL::English::DataQueryWorkflow, Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[DSL::English::EpidemiologyModelingWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-EpidemiologyModelingWorkflows),
(2020-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[DSL::English::FoodPreparationWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-FoodPreparationWorkflows),
(2021-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[DSL::English::LatentSemanticAnalysisWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-LatentSemanticAnalysisWorkflows),
(2020-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[DSL::English::QuantileRegressionWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-QuantileRegressionWorkflows),
(2020-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp8] Anton Antonov,
[DSL::English::RecommenderWorkflows, Raku package](https://github.com/antononcube/Raku-DSL-English-RecommenderWorkflows),
(2020-2025),
[GitHub/antononcube](https://github.com/antononcube).

[AAp9] Anton Antonov,
[DSL::English::SearchEngineQueries, Raku package](https://github.com/antononcube/Raku-DSL-English-SearchEngineQueries),
(2020-2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp10] Anton Antonov,
[DSL::Bulgarian, Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp11] Anton Antonov,
[ML::FindTextualAnswer, Raku package](https://github.com/antononcube/Raku-ML-FindTextualAnswer),
(2023-2026),
[GitHub/antononcube](https://github.com/antononcube).

[AAp12] Anton Antonov,
[ML::NLPTemplateEngine, Raku package](https://github.com/antononcube/Raku-ML-NLPTemplateEngine),
(2023-2025),
[GitHub/antononcube](https://github.com/antononcube).

### Repositories

[AAr1] Anton Antonov,
["Raku for Prediction" book](https://github.com/antononcube/RakuForPrediction-book),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
Wolfram Technology Conference 2020.

[AAv2] Anton Antonov,
["Raku for Prediction](https://www.youtube.com/watch?v=frpCBjbQtnA),
(2021),
The Raku Conference 2021.

