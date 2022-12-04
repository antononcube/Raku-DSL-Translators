# Comprehensive Translation

[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This Raku package provides comprehensive multi-DSL translations.

-------

## Installation

To install 
`DSL::Shared::Utilities::ComprehensiveTranslation` 
certain DSL Raku modules have to be installed.

See the installation code in the resource file ["zsh-nuke-and-install.sh"](./resources/zsh-nuke-and-install.sh). 

(The modules listed above are under development, that is why the installation commands have `--force-test`.)

-------

## Usage

Here we load the package:

```perl6
use DSL::Shared::Utilities::ComprehensiveTranslation;
```
```
# (Any)
```

Here is an example that shows:

- Automatic determination of the DSL grammar

- JSON format of the result

```perl6
ToDSLCode('
    use dfStarWars;
    select the columns name, species, mass and height;
    cross tabulate species over mass', 
        format => 'JSON');
```
```
# {
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "USERID": "",
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLTARGET": "R-tidyverse",
#   "COMMAND": "\n    use dfStarWars;\n    select the columns name, species, mass and height;\n    cross tabulate species over mass",
#   "CODE": "dfStarWars %>%\ndplyr::select(name, species, mass, height) %>%\n(function(x) as.data.frame(xtabs( formula = mass ~ species, data = x ), stringsAsFactors=FALSE ))"
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

```perl6
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
# 
```

The function `dsl-translation` is a version of `ToDSLCode` that intended to be used in 
command line and web interfaces. It returns a `Hash` object. Here is an example:

```perl6
my %res = dsl-translation('
    USER ID dd7833sa;
    DSL MODULE DataQueryWorkflows;
    use dfStarWars;
    select the columns name, species, mass and height;
    cross tabulate species over mass');
.say for %res;
```
```
# DSL => DSL::English::DataQueryWorkflows
# STDERR => 
# COMMAND => 
#     USER ID dd7833sa;
#     DSL MODULE DataQueryWorkflows;
#     use dfStarWars;
#     select the columns name, species, mass and height;
#     cross tabulate species over mass
# CODE => dfStarWars %>%
# dplyr::select(name, species, mass, height) %>%
# (function(x) as.data.frame(xtabs( formula = mass ~ species, data = x ), stringsAsFactors=FALSE ))
# USERID => dd7833sa
# DSLFUNCTION => proto sub ToDataQueryWorkflowCode (Str $command, |) {*}
# DSLTARGET => R-tidyverse
```

------

## References

### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
Wolfram Technology Conference 2020.

[AAv2] Anton Antonov,
["Raku for Prediction](https://www.youtube.com/watch?v=frpCBjbQtnA),
(2021),
The Raku Conference 2021.

### Repositories

[AAr1] Anton Antonov,
["Raku for Prediction" book](https://github.com/antononcube/RakuForPrediction-book),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAr2] Anton Antonov,
[DSL::English::DataQueryWorkflow Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020),
[GitHub/antononcube](https://github.com/antononcube).
