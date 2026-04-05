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

The function `dsl-translation` is a version of `ToDSLCode` that intended to be used in 
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

