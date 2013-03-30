# reakt

A tool for observing file directories and reacting to changes. Also includes `reaktd` for working with long-running processes.

### Usage

```
$ reakt [options] <command>
$ reaktd [options] <command>

  Options:

    -h, --help                     output usage information
    -V, --version                  output the version number
    -g, --grep [regex]             run <command> when files matching [regex] change (see below)
    -v, --invert [regex]           do not run <command> if files matching [regex] change (see below)
    -i, --interval [milliseconds]  polling interval in ms - defaults to 1000ms
```

### Examples
```
$ reakt say "files updated"
$ reakt coffee -c src/foo.coffee -o lib
$ reakt -g "^\/src" make test
$ reaktd ./start_server.sh
```

### Regex

Currently `--grep` and `--invert` only accept regex patterns. Internally, these are converted into RegExp:

```javascript
var includeRegExp = RegExp(grep);
var excludeRegExp = RegExp(invert);
```

Support for file globbing will be added soon.

### License

MIT
