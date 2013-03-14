watch = require('watch')
childProcess = require('child_process')
_ = {wrap, map, flatten, compact, isString, keys} = require('underscore')

LINE_PREFIX = "---"

compactMap = (arr, fn) -> compact(map(flatten(arr), fn))

module.exports = (path, command, options = {}) ->
  {longRunning, interval, exclude, include} = options

  if include?
    include = RegExp(include)
    notIncluded = -> not include.test.apply(include, arguments)

  if exclude?
    exclude = RegExp(exclude)
    excluded = -> exclude.test.apply(exclude, arguments)

  args = [command]
  args.unshift('-c')

  interval ?= 1000

  class Reaktr

    start: ->
      @log ""
      @log "Observing files in `#{path}` and running `#{command}` on changes"
      @log ""
      @log "Include files matching: #{include}" if include?
      @log "Exclude files matching: #{exclude}" if exclude?

      if longRunning
        @process = @startProcess()
        @startProcess = @processRestarter(@startProcess)

      {after} = _
      @onChange = after(2, @onChange)

      watch.watchTree(path, {interval}, @onChange)

    log: (message) ->
      console.log("#{LINE_PREFIX} #{message}")

    onChange: (files) =>
      files = @parseFiles(files)
      return unless files.length

      @log ""
      @log "Change detected:"
      @log ".#{file}" for file in files
      @log ""

      @startProcess()

    parseFiles: (files) =>
      files = keys(files) unless isString(files)
      compactMap([files], @parseFile)

    parseFile: (file) ->
      file = file.replace(path,'') || '/'
      file = null if notIncluded?(file)
      file = null if excluded?(file)
      file

    startProcess: =>
      @log "Running `#{command}`"
      @log ""
      child = childProcess.spawn("sh", args, stdio: 'inherit')
      child.on('exit', @earlyProcessExit) if longRunning
      child

    earlyProcessExit: (code = 0) =>
      @log ""
      @log "PID #{@process.pid} exited early with #{code}"
      @process = null

    processRestarter: (startFn) ->
      =>
        return @process = startFn() unless @process?
        @log "Killing process with PID #{@process.pid}"
        @process.removeListener('exit', @earlyProcessExit)
        @process.on('exit', @restartProcess(@process, startFn))
        @process.kill()

    restartProcess: (oldProcess, startFn) =>
      (code = 0) =>
        @log "PID #{oldProcess.pid} exited with #{code}"
        @log ""
        @process = startFn()

  return new Reaktr
