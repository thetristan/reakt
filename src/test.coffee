{ok: expect, equal} = require('assert')
child = require('child_process')
watch = require('watch')
spy = require('bondjs')

reakt = require('./')


describe 'reakt', ->

  before ->
    @createSubject = (args = {}) ->
      @subject = reakt("/foo/bar", 'ls ..', args)
      # Silence is golden
      spy(@subject, 'log').return()

  beforeEach ->
    @createSubject()

  describe '#start', ->
    beforeEach ->
      spy(watch, 'watchTree').return()
      spy(@subject, 'processRestarter').return()

    it 'sets an empty process attribute', ->
      equal @subject.process, null

    context 'when in long running mode', ->
      it 'wraps the #startProcess method with a #processRestarter', ->
        @createSubject(longRunning: true)
        spy(@subject, 'startProcess').return()
        spy(@subject, 'processRestarter').return()
        expectedStartFn = @subject.startProcess
        @subject.start()
        [actualStartFn] = @subject.processRestarter.calledArgs[0]
        equal actualStartFn, expectedStartFn

    context 'when not in long running mode', ->
      it 'does not wrap the startProcess method', ->
        @subject.start()
        expect not @subject.processRestarter.called

    it 'sets a watcher on the provided path', ->
      @subject.start()

      [path, cb] = watch.watchTree.calledArgs[0]
      equal path, "/foo/bar"
      equal cb, @subject.onChange

  describe '#onChange', ->
    beforeEach ->
      @fakeData = ['foo']
      spy(@subject, 'parseFiles').return(@fakeData)
      spy(@subject, 'startProcess').return()

    context 'with no files', ->
      it 'returns early', ->
        @subject.parseFiles.return([])
        @subject.onChange(@fakeData)
        expect not @subject.startProcess.called

    context 'with files', ->
      it 'calls #runProcess', ->
        @subject.parseFiles.return(['/foo'])
        @subject.onChange(@fakeData)
        expect @subject.startProcess.called

  describe '#parseFiles', ->
    context 'when called with an object', ->
      it 'converts the objects keys to a string and returns it', ->
        result = @subject.parseFiles({'foo','bar'})
        equal result[0], 'foo'
        equal result[1], 'bar'

    context 'when called with a string', ->
      it 'returns the original string', ->
        result = @subject.parseFiles('foo')
        equal result[0], 'foo'

  describe '#parseFile', ->
    beforeEach ->
      @createSubject(include: "(baz\/qux|lorem\/ipsum)", exclude: "ipsum\/lorem")

    it 'strips the base path', ->
      equal @subject.parseFile('/foo/bar/baz/qux'), '/baz/qux'

    context 'if the file does not match the include pattern', ->
      it 'returns null', ->
        equal @subject.parseFile('/foo/bar/foo/ipsum'), null

    context 'if the file matches the exclude pattern', ->
      it 'returns null', ->
        equal @subject.parseFile('/foo/bar/ipsum/lorem'), null

  describe '#killProcess', ->
    it 'kills the process', ->
      @subject.process = kill: spy()
      @subject.killProcess()
      expect @subject.process.kill.called

  describe '#startProcess', ->
    it 'spawns a child process', ->
      spy(child, 'spawn').return()
      @subject.startProcess()

      [cmd, args, opts] = child.spawn.calledArgs[0]
      equal cmd, 'sh'
      equal args[0], '-c'
      equal args[1], 'ls ..'
      equal opts.stdio, 'inherit'
