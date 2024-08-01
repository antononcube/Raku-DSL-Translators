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

Using `ToDSLCode`:

```perl6
ToDSLCode($cmd);
```

Using the "web ready" `dsl-translation`:

```perl6
$cmd ==> dsl-translation(language => 'English', :prepend-setup-code)
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

Using `ToDSLCode`:

```perl6
ToDSLCode($cmd);
```

Using the "web ready" `dsl-translation`:

```perl6
$cmd ==> dsl-translation(lang => 'English', to => 'WL', :setup) ==> { $_<CODE> }()
```

### Web service

```perl6
dsl-web-translation($cmd, to => 'Python')
```