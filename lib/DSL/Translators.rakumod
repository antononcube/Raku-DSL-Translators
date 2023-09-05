use v6.d;

unit module DSL::Translators;

#-----------------------------------------------------------
use DSL::Translators::ComprehensiveTranslation;
use JSON::Fast;
use HTTP::UserAgent;
use Test::Output;

#===========================================================
# DSL translation
#===========================================================

#| More general and "robust" DSL translation function to be used in web- and notebook interfaces.
proto sub dsl-translation(Str:D $commands,
                          Str:D :$language = 'English',
                          Str:D :defaultTargetsSpec(:$default-targets-spec) = 'R',
                          Bool :$ast = False,
                          Bool :$prepend-setup-code = False,
                          Int :$degree = 1) is export {*}

multi sub dsl-translation(@commands, *%args) {
    return dsl-translation(@commands.join(";\n"), |%args);
}

multi sub dsl-translation(Str:D $commands,
                          Str:D :$language = 'English',
                          Str:D :defaultTargetsSpec(:$default-targets-spec) = 'R',
                          Bool :$ast = False,
                          Bool :$prepend-setup-code = False,
                          Int :$degree = 1) {

    my Str $commands2 = $commands;

    ## Remove wrapper quotes
    if $commands2 ~~ / ^ ['"' | '\''] .* ['"' | '\''] $ / {
        $commands2 = $commands2.substr(1, *- 1)
    }

    ## I am not sure is this hack or nice "eat your own dog food" application.
    if $commands2 && $prepend-setup-code {
        $commands2 ~= ";\n" ~ 'include setup code';
    }

    ## Interpret
    my %res;
    my $err =
            stderr-from({
                if $ast {
                    #        %res = ToDSLCode( $commands2, language => "English", format => 'json', :guessGrammar, :$default-targets-spec, :$ast );
                    #        %res = %res , %( CODE => %res{"CODE"}.gist );
                    %res = ToDSLSyntaxTree($commands2, :$language, format => 'object', :guess-grammar, :$default-targets-spec, :$degree):as-hash;
                } else {
                    %res = ToDSLCode($commands2, :$language, format => 'object', :guess-grammar, :$default-targets-spec, :$degree);
                }
            });

    ## Combine with custom $err with interpretation result
    %res = %res, %(STDERR => $err, COMMAND => $commands);

    if %res<SETUPCODE>:exists and $prepend-setup-code {
        %res<CODE> = %res<SETUPCODE> ~ "\n" ~ %res<CODE>
    }

    ## Result
    return %res;
}

#===========================================================
# DSL Web translation
#===========================================================

#| Gets the data from a specified URL.
sub get-url-data(Str $url, UInt :$timeout = 10) {
    my $ua = HTTP::UserAgent.new;
    $ua.timeout = $timeout;

    my $response = $ua.get($url);

    if not $response.is-success {
        # say $response.content.WHAT;
        die $response.status-line;
    }

    return $response.content;
}


#| Translates natural language commands into programming code using web (dedicated) service.
proto sub dsl-web-translation(
        Str $command,                                         #= Command to translate.
        Str :$url = 'http://accendodata.net:5040/translate',  #= Web service URL.
        Str :$sub = '',                                       #= Sub for given URL.
        Str :t(:$to-language) is copy = 'R',                  #= Language to translate to: one of 'Bulgarian', 'English', 'Python', 'R', 'Raku', 'Russian', or 'WL';
        Str :f(:$from-language) is copy = 'English',          #= Language to translate from; one of 'Bulgarian', 'English', 'Russian', or 'Whatever'.
        Str :$format is copy = 'json',                        #= Format of the result; one of 'json', 'raku', 'code';
        Bool :$fallback = True,                               #= Should fallback parsing be done or not?
        UInt :$timeout= 10,                                   #= Timeout in seconds.
                             ) is export {*}

multi sub dsl-web-translation(
        Str $command,                                         #= Command to translate.
        Str :$url = 'http://accendodata.net:5040/translate',  #= Web service URL.
        Str :$sub = '',                                       #= Sub for given URL.
        Str :t(:$to-language) is copy = 'R',                  #= Language to translate to: one of 'Bulgarian', 'English', 'Python', 'R', 'Raku', 'Russian', or 'WL';
        Str :f(:$from-language) is copy = 'English',          #= Language to translate from; one of 'Bulgarian', 'English', 'Russian', or 'Whatever'.
        Str :$format is copy = 'json',                        #= Format of the result; one of 'json', 'raku', 'code';
        Bool :$fallback = True,                               #= Should fallback parsing be done or not?
        UInt :$timeout= 10,                                   #= Timeout in seconds.
                              ) {

    my $command2 = $command.subst(/<-alnum>/, *.ord.fmt("%%%02X"), :g);

    my $urlQuery = $sub ?? "$url/$sub" !! $url;
    $urlQuery = "$urlQuery?command=$command2&lang=$to-language&from-lang=$from-language";

    #$url-query = "http://accendodata.net:5040/translate?command='make%20a%20document%20term%20matrix'&lang=WL&from-lang=Automatic";

    my $urlResult = get-url-data($urlQuery, :$timeout);
    my $resJSON = from-json($urlResult);

    if !$resJSON<CODE> && $fallback {
        return dsl-web-translation($command, :$url, sub => 'qas', :$to-language, :$from-language, :$format, :!fallback, :$timeout);
    }

    my $res = do given $format.lc {
        when 'code' { $resJSON<CODE> }
        when $_ ∈ <raku hash> { $resJSON.raku }
        default { $urlResult }
    }

    return $res;
}