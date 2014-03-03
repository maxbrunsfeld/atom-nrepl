{WorkspaceView, EditorView, Range, Point} = require 'atom'
{Directory} = require 'pathwatcher'
fs = require 'fs'
temp = require 'temp'
FakeNreplClient = require './helpers/fake-nrepl-client'
Controller = require '../lib/controller'

describe "nrepl", ->
  [client, directory, controller, workspaceView, editorView] = []

  beforeEach ->
    waitsFor (done) ->
      setUpFakeProjectDir (path) ->
        client = new FakeNreplClient()



        directory = new Directory(path)
        workspaceView = new WorkspaceView
        editorView = setUpActiveEditorView(workspaceView)
        editorView.insertText("""
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
    subject = ->
      runs ->
        spyOn(editorView.editor, 'getSelectedBufferRange').andReturn(new Range([3, 0], [4, 0]))
        workspaceView.trigger('nrepl:eval')
      waits 5

    describe "when a REPL is running", ->
      fakePort = 41235

      beforeEach ->
        waitsFor (done) ->
          setUpFakePortFile(directory.path, fakePort, done)
        subject()

      it "connects to the port specified in the port file", ->
        expect(client.connectedPort).toBe(fakePort)

      describe "when the connection succeeds", ->
        beforeEach ->
          client.simulateConnectionSucceeding()

        it "displays the value of selected expression, evaluated in the right namespace", ->
          client.simulateEvaluationSucceeding(
            """
            (ns the-first.namespace)
            (the second expression)\n
            """,
            ["nil", ":the-first-value"])

          outputView = workspaceView.find("#nrepl-output")
          expect(outputView.eq(0).text()).toBe(":the-first-value")

    describe "when no REPL is running", ->
      beforeEach ->
        subject()

      it "displays an error message", ->
        outputView = workspaceView.find("#nrepl-output")
        expect(outputView.text()).toBe("Connection Error - Could not find nrepl port file.")

# helpers

setUpActiveEditorView = (parent) ->
  result = new EditorView(mini: true)
  spyOn(parent, 'getActiveView').andReturn(result)
  result

setUpFakeProjectDir = (f) ->
  temp.mkdir("atom-nrepl-test", (err, path) -> f(path))

setUpFakePortFile = (path, port, f) ->
    fs.mkdir "#{path}/target", ->
      fs.writeFile("#{path}/target/repl-port", port.toString(), f)
