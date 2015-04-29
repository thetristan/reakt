minimatch = require 'minimatch'
gaze = require 'gaze'
childProcess = require 'child_process'
{flatten} = require 'lodash'

LINE_PREFIX = "---"

module.exports = (path, command, opts = {}) ->
  {color, daemon, interval, exclude, include} = opts
  interval ?= 1000

  START_COLOR = if color then "\x1b[30;1m" else ""
  END_COLOR = if color then "\x1b[0m" else ""

  log = (message) ->
    console.log("#{START_COLOR}#{LINE_PREFIX} #{message}#{END_COLOR}")

  excluded = (file) ->
    return false if !exclude || exclude.length == 0
    flatten([false, exclude]).reduce (memo, x) ->
      trimLen = x.indexOf('/') && path.length + 1
      minimatch(file.substr(trimLen), x)

  process = null

  log "Observing files in `#{path}` and running `#{command}` on changes"
  include.forEach (i) -> log "Include files matching: #{i}"
  exclude.forEach (x) -> log "Exclude files matching: #{x}"

  if daemon
    process = startProcess()
    startProcess = processRestarter(startProcess)

  gaze include, (err, watcher) ->
    watcher.on 'all', (evt, file) ->
      return if excluded(file) || process
      log "Change detected for #{file}"
      process = startProcess()

  startProcess = ->
    if daemon
      log "Starting `#{command}`"
    else
      log "Running `#{command}`"

    child = childProcess.spawn("sh", ['-c', command], stdio: 'inherit')
    child.on 'exit', (code = 0) ->
      log "PID #{child.pid} exited with #{code}"
      process = null

    child

    processRestarter = (startFn) ->
    ->
      return process = startFn() unless process?
      log "Killing process with PID #{process.pid}"
      process.removeListener('exit', earlyProcessExit)
      process.on('exit', restartProcess(process, startFn))
      process.kill()

  restartProcess = (oldProcess, startFn) ->
    (code = 0) ->
      log "PID #{oldProcess.pid} exited with #{code}"
      process = startFn()
