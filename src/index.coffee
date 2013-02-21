watch = require('watch')
childProcess = require('child_process')

LINE_PREFIX = "---"

module.exports = (path, command, options = {}) ->
  {longRunning, exclude, include} = options
  excludePattern = if exclude then RegExp(exclude) else null
  includePattern = if include then RegExp(include) else null

  args = [command]
  args.unshift('-c')
  child = null

  class Observer

    start: ->
      @log ""
      @log "Observing files in `#{path}` and running `#{command}` on changes"
      @log ""
      @log "Include files matching: /#{include}/" if include?
      @log "Exclude files matching: /#{exclude}/" if exclude?
      watch.watchTree(path, @onChange)

    onChange: (files) =>
      files = @parseFiles(files)
      if files.length
        @log ""
        @log "Change detected:"
        @log ".#{file}" for file in files
        @log ""
        @runCommand()

    parseFiles: (files) ->
      if String == files.constructor
        files = [files]
      else
        files = Object.keys(files)

      files = files.map (file) -> file.replace(path,'') || '/'
      files = files.map (file) -> if includePattern.test(file) then file else null
      files = files.map (file) -> if excludePattern.test(file) then null else file
      files = files.reduce(((files, file) ->
        files.push(file) if file?
        files
      ), [])

    log: (message) ->
      console.log("#{LINE_PREFIX} #{message}")

    runCommand: ->
      if child? && longRunning
        @log "Killing process with PID #{child.pid}"
        child.kill()

      @log "Running `#{command}`"
      @log ""
      child = childProcess.spawn("sh", args, stdio: 'inherit')

      child.on 'exit', (code = 0) =>
        @log "PID #{child?.pid} exited with #{code}" if longRunning
        @log ""
        child = null


  new Observer()
