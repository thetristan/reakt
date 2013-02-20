{ok: expect, equal} = require('assert')
child = require('child_process')
watch = require('watch')
spy = require('bondjs')

observer = require('./')

describe 'observer', ->

  beforeEach ->
    # Silence is golden
    spy(console, 'log').return()
    @subject = observer("/foo/bar", 'ls ..')

  describe 'observe', ->
    it 'sets a watcher on the provided path', ->
      spy(watch, 'watchTree').return()
      @subject.observe()

      [path, cb] = watch.watchTree.calledArgs[0]
      equal path, "/foo/bar"
      equal cb, @subject.onChange

  describe 'parseFiles', ->
    context 'when called with an object', ->
      it 'converts the objects keys to a string and returns it', ->
        result = @subject.parseFiles({'foo','bar'})
        equal result, "- foo\n- bar"

    context 'when called with a string', ->
      it 'returns the original string', ->
        result = @subject.parseFiles('foo')
        equal result, 'foo'

  describe 'onChange', ->
    it 'foos', ->
      spy(@subject, 'runCommand').return()
      @subject.onChange("/filename")
      expect @subject.runCommand.called

  describe 'runCommand', ->
    it 'spawns a child process', ->
      spy(child, 'spawn').return()
      @subject.runCommand()

      [cmd, args, opts] = child.spawn.calledArgs[0]
      equal cmd, 'ls'
      equal args[0], '..'
      equal opts.stdio, 'inherit'




