watch = require('watch')
child = require('child_process')

module.exports = observer = (path, fullCommand) ->
  args = fullCommand.split(' ')
  command = args.shift()

  class Observer

    start: ->
      watch.watchTree(path, @onChange)

    onChange: (files) =>
      files = @parseFiles(files)
      @log "\nChange detected to:\n#{files}"
      @runCommand()

    parseFiles: (files) ->
      if String == files.constructor
        files = [files]
      else
        files = Object.keys(files)
      files = files.map (file) -> file.replace(path,'') || '/'
      files = files.join("\n- ")
      "- #{files}"

    log: (message) ->
      console.log(message)

    runCommand: ->
      @log "\nRunning `#{fullCommand}`..."
      child.spawn(command, args, stdio: 'inherit')

  new Observer()
