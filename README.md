# reakt

A tool for observing file directories and reacting to changes. Also includes `reaktd` for working with long-running processes.

### Usage

```
$ reakt [options] <command>
$ reaktd [options] <command>
```

### Examples
```
$ reakt say "files updated"
$ reakt coffee -c src/foo.coffee -o lib
$ reaktd ./start_server.sh
```

