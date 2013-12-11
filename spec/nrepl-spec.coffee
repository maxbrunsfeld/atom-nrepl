{WorkspaceView, EditorView, Directory, Range, Point} = require 'atom'
fs = require 'fs'
temp = require 'temp'
FakeNreplClient = require './helpers/fake-nrepl-client'
Controller = require '../lib/controller'

describe "nrepl", ->
  [client, controller, workspaceView, view] = []

  beforeEach ->
    waitsFor (done) ->
      setUpFakeProjectDir (path) ->
        client = new FakeNreplClient()
        directory = new Directory(path)
        workspaceView = new WorkspaceView
        view = setUpActiveView(workspaceView)
        view.insertText("""
          (ns the-first.namespace
            (require [some-library]))
          (the first expression)
          (the second expression)

          (ns the-second.namespace
            (use [some-other-library]))
          (the third expression)
          """)

        controller = new Controller(client, workspaceView, directory)
        controller.start()
        done()

  describe "evaluating a selected expression", ->
    beforeEach ->
      spyOn(view, 'getSelectedBufferRange').andReturn(new Range([3, 0], [4, 0]))
      workspaceView.trigger('nrepl:eval')
      waits 5

    it "connects to the port specified in the port file", ->
      expect(client.connectedPort).toBe(51234)

    describe "when the connection succeeds", ->
      beforeEach ->
        client.simulateConnectionSucceeding()

      it "displays the value of selected expression," +
         "evaluated in the right namespace", ->
        client.simulateEvaluationSucceeding(
          """
          (ns the-first.namespace)
          (the second expression)\n
          """,
          ["nil", ":the-first-value"])

        outputView = workspaceView.find("#nrepl-output")
        expect(outputView.eq(0).text()).toBe(":the-first-value")

# helpers

setUpActiveView = (parent) ->
  result = new EditorView(mini: true)
  spyOn(parent, 'getActiveView').andReturn(result)
  result

setUpFakeProjectDir = (f) ->
  temp.mkdir "atom-nrepl-test", (err, path) ->
    fs.mkdir "#{path}/target", ->
      fs.writeFile "#{path}/target/repl-port", "51234", ->
        f(path)
