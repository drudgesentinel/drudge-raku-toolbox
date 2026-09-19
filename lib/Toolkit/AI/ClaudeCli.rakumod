unit module Toolkit::AI::ClaudeCli;

=begin pod

=head1 SYNOPSIS

    use Toolkit::AI::ClaudeCli;

    my $result = run-claude-prompt(
        'Summarize the files in this directory.',
        :add-dirs(['/path/to/bundle']),
    );

    say $result.exit-code;
    say $result.stdout;

=end pod

use Toolkit::System::LocalBinary;

class ClaudeCliResult {
    has Int $.exit-code is required;
    has Str $.stdout is required;
    has Str $.stderr is required;
    has Str $.binary is required;
}

# Runs a single non-interactive `claude -p` invocation and returns its result.
# Tool access defaults to read-only (Read/Glob/Grep) and, via :add-dirs, scoped
# to specific directories — callers that need write/network access must opt in
# explicitly via :allowed-tools.
sub run-claude-prompt(
    Str:D $prompt,
    Str :$binary,
    :@add-dirs = [],
    :@allowed-tools = <Read Glob Grep>,
    Str :$output-format = 'text',
    --> ClaudeCliResult:D
) is export {
    my $bin = resolve-claude-binary(:candidate($binary));

    # The prompt must come immediately after --print: --add-dir and
    # --allowedTools are both variadic (they greedily consume every
    # following non-flag token), so putting the prompt after them means it
    # gets swallowed as just another directory/tool name and claude reports
    # "Input must be provided either through stdin or as a prompt argument".
    my @args = '--print', $prompt, '--output-format', $output-format;
    @args.append('--allowedTools', |@allowed-tools) if @allowed-tools.elems;
    for @add-dirs -> $dir { @args.append('--add-dir', $dir) }

    my $result = run-local-command($bin, :args(@args), :allow-nonzero(True));

    ClaudeCliResult.new(
        exit-code => $result.exit-code,
        stdout => $result.stdout,
        stderr => $result.stderr,
        binary => $bin,
    );
}

# Use :candidate to override the default 'which claude' search for the path.
sub resolve-claude-binary(Str :$candidate --> Str:D) is export {
    resolve-binary(:name('claude'), :$candidate);
}
