watch = require('watch')
child = require('child_process')

module.exports = observer = (path, command) ->
  class Observer
    observe: ->
      watch.watchTree(path, @onChange)

    parseFiles: (files) ->
      files = "- " + Object.keys(files).join("\n- ") unless String == files.constructor
      files

    onChange: (files) =>
      files = @parseFiles(files)
      console.log "Change detected to:\n- #{files}"
      @runCommand()

    runCommand: ->
      console.log "Running #{command}"
      args = command.split(' ')
      cmd = args.shift()
      child.spawn(cmd, args, stdio: 'inherit')

  return new Observer()
