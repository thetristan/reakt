# reakt

A tool for observing file directories and reacting to changes. Also includes `reaktd` for working with long-running processes.

### Usage

```
$ reakt [options] <command>
$ reaktd [options] <command>

  Options:

    -h, --help                     output usage information
    -V, --version                  output the version number
    -g, --grep [pattern]           run <command> when files matching [pattern] change
    -v, --invert [pattern]         do not run <command> if files matching [pattern] change
    -i, --interval [milliseconds]  polling interval in ms - defaults to 1000ms
```

### Examples
```
$ reakt say "files updated"
$ reakt coffee -c src/foo.coffee -o lib
$ reakt -g "^\/src" make test
$ reaktd ./start_server.sh
```

