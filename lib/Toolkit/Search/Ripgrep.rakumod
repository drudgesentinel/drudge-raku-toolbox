unit module Toolkit::Search::Ripgrep;

=begin pod

=head1 SYNOPSIS

    use Toolkit::Search::Ripgrep;

    my $ripgrep-binary = resolve-ripgrep-binary;
    my $ignore-case = True;

    # Equivalent core command: rg -i --max-count 20 TODO lib
    my $result = search-text(
        'TODO',
        :path('lib'),
        :binary($ripgrep-binary),
        :$ignore-case,
        :max-count(20),
    );

    # Equivalent core command: rg -A1 foo
    my $after-context = search-text(
        'foo',
        :binary($ripgrep-binary),
        :context(1),
    );

    say $result.has-matches;
    say $result.matches.elems;

=end pod

use JSON::Fast;
use Toolkit::System::LocalBinary;

class RipgrepSearchResult {
    has Int $.exit-code is required;
    has Str $.stdout is required;
    has Str $.stderr is required;
    has Str $.binary is required;
    has @.matches;

    method has-matches() {
        @!matches.elems > 0;
    }
}

sub search-text(
    Str:D $pattern,
    Str:D :$path = '.',
    Str :$binary,
    :@extra-flags = [],
    Bool :$ignore-case = False,
    Bool :$fixed-strings = False,
    Bool :$word-regexp = False,
    Bool :$reverse = False,
    Int :$max-count,
    Bool :$hidden = False,
    Bool :$follow = False,
    Bool :$no-ignore = False,
    Int :$context,
    --> RipgrepSearchResult:D
) is export {
    my $rg = resolve-ripgrep-binary(:candidate($binary));

    my @args = '--json', '--line-number', '--column', '--color', 'never';
    @args.push('--ignore-case') if $ignore-case;
    @args.push('--fixed-strings') if $fixed-strings;
    @args.push('--word-regexp') if $word-regexp;
    @args.push('--invert-match') if $reverse;
    @args.push('--hidden') if $hidden;
    @args.push('--follow') if $follow;
    @args.push('--no-ignore') if $no-ignore;
    @args.append('--max-count', $max-count.Str) if $max-count.defined;
    @args.append('-C', $context.Str) if $context.defined;
    @args.append(@extra-flags) if @extra-flags.elems;
    @args.push($pattern, $path);

    my $result = run-local-command($rg, :args(@args), :allow-nonzero(True));

    if $result.exit-code != 0 && $result.exit-code != 1 {
        die "ripgrep failed with exit code {$result.exit-code} using binary '$rg':\n{$result.stderr}";
    }

    my @matches = parse-json-matches($result.stdout);

    RipgrepSearchResult.new(
        exit-code => $result.exit-code,
        stdout => $result.stdout,
        stderr => $result.stderr,
        binary => $rg,
        :@matches,
    );
}

sub resolve-ripgrep-binary(Str :$candidate --> Str:D) is export {
    resolve-binary(:name('rg'), :$candidate);
}

sub parse-json-matches(Str:D $stdout --> Array:D) {
    my @matches;

    for $stdout.lines -> $line {
        next unless $line.trim.chars;

        my %event = from-json($line);

        next unless %event<type>:exists;
        next unless %event<type> eq 'match';

        my %data = %event<data> // {};
        my @submatches;
        for (%data<submatches> // []) -> $sub {
            my %sub = $sub ~~ Associative ?? $sub.Hash !! {};
            @submatches.push({
                start => (%sub<start> // 0),
                end => (%sub<end> // 0),
                text => (%sub<match><text> // ''),
            });
        }

        @matches.push({
            path => (%data<path><text> // ''),
            line-number => (%data<line_number> // 0),
            line-text => (%data<lines><text> // ''),
            submatches => @submatches,
        });
    }

    @matches;
}
