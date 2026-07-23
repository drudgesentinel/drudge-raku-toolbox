# drudge-raku-toolbox

Reusable Raku modules for local command execution, ripgrep-backed search, and ANSI color formatting.

## Modules

- `Toolkit::System::LocalBinary`
- `Toolkit::Search::Ripgrep`
- `Toolkit::CLI::Color`

## Setup

1. Install dependencies:

```bash
zef install --deps-only .
```

2. Use modules via `-Ilib` during local development, or install with `zef install .`.

## Usage

### Local binary execution

```raku
use Toolkit::System::LocalBinary;

my $result = run-local-command('echo', :args(['hello']));
say $result.stdout;
```

### Ripgrep search

```raku
use Toolkit::Search::Ripgrep;

my $result = search-text('TODO', :path('README.md'));
say $result.has-matches;
```

### Terminal colors

```raku
use Toolkit::CLI::Color;

say color-title('Toolkit');
say color-status('OPEN');
```

## Notes

- Ripgrep binary resolution order:
  1. `:binary('/path/to/rg')` passed to `search-text`
  2. `which rg` on PATH
