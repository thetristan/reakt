commander = require 'commander'
{pick, assign} = require 'lodash'

{version} = require '../package.json'
reakt = require './index'

collect = (val, memo) =>
  memo.push(val)
  memo

commander.version(version)
  .usage('[options] <command>')
  .description('tool for observing file directories and reacting to changes')
  .option('-d, --daemon', 'treat <command> as a long running process')
  .option('-nc, --no-color', 'disable color output (disabled by default for non-TTY)')
  .option('-i, --include [pattern]', 'run <command> when files matching [pattern] change; may be used multiple times', collect, [])
  .option('-x, --exclude [pattern]', 'do not run <command> if files matching [pattern] change; may be used multiple times', collect, [])
  .option('-n, --interval [milliseconds]', 'polling interval in ms - defaults to 1000ms')
  .parse(process.argv)

cwd = process.cwd()
command = commander.args.join(' ')

if !command
  console.error commander.help()
  process.exit 1

opts = pick commander, ["daemon", "color", "include", "exclude", "interval"]

if !(process.stdout.isTTY || process.stderr.isTTY)
  opts.color = false

reakt(cwd, command, opts)
