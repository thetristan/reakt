watch = require('watch')
childProcess = require('child_process')
{after, wrap, map, flatten, compact, isString, keys} = require('underscore')

LINE_PREFIX = "---"

compactMap = (arr, fn) -> compact(map(flatten(arr), fn))

module.exports = (path, command, options = {}) ->
  {longRunning, exclude, include} = options

  if include?
    include = RegExp(include)
    notIncluded = -> not include.test.apply(include, arguments)

  if exclude?
    exclude = RegExp(exclude)
    excluded = -> exclude.test.apply(exclude, arguments)

  args = [command]
  args.unshift('-c')

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

      @onChange = after(2, @onChange)

      watch.watchTree(path, @onChange)

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
      childProcess.spawn("sh", args, stdio: 'inherit')

    processRestarter: (startFn) ->
      =>
        @killProcess() if @process?
        @process.on 'exit', @onProcessExit(@process, startFn)

    killProcess: ->
      @log "Killing process with PID #{@process.pid}"
      @process.kill()

    onProcessExit: (oldProcess, startFn) =>
      (code = 0) =>
        @log "PID #{oldProcess.pid} exited with #{code}"
        @log ""
        @process = startFn()


  return new Reaktr
