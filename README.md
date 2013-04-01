# reakt

A tool for observing file directories and reacting to changes. Also includes `reaktd` for working with long-running processes.

### Usage

```
$ reakt [options] <command>
$ reaktd [options] <command>

  Options:

    -h, --help                     output usage information
    -V, --version                  output the version number
    -g, --grep [pattern|regexp]    run <command> when files matching [pattern|regexp] change (see below)
    -v, --invert [pattern|regexp]  do not run <command> if files matching [pattern|regexp] change (see below)
    -i, --interval [milliseconds]  polling interval in ms - defaults to 1000ms
```

### Examples
```
$ reakt say "files updated"
$ reakt coffee -c src/foo.coffee -o lib
$ reakt -g "src/*.coffee" "make && make test"
$ reakt -g "/^src/" foo
$ reaktd ./start_server.sh
```

### Patterns/RegExp

Currently `--grep` and `--invert` accept file glob or regex patterns.

##### Globs

All patterns are re-expanded on every file change to ensure new files matching the glob are watched. Internally, reakt uses (node-glob)[https://github.com/isaacs/node-glob] to handle expanding globs:

```javascript
// $ reakt -g "src/*.coffee" bar
var includePattern = glob.sync("src/*.coffee")
```

##### RegExp

If the patterns you specify begin and end with a '/', they will be converted into RegExps internally:

```javascript
// $ reakt -g "/^src/" foo
var includeRegExp = RegExp("/^src/");
```

### License

MIT
