{TextEditor} = require 'atom'
{Directory} = require 'pathwatcher'
fs = require 'fs'
temp = require 'temp'
FakeNreplClient = require './helpers/fake-nrepl-client'
Controller = require '../lib/controller'

describe "nrepl", ->
  [client, directory, controller, editor] = []

  beforeEach ->
    document
      .querySelector("#jasmine-content")
      .appendChild(atom.views.getView(atom.workspace))

    client = new FakeNreplClient()
    directory = new Directory(temp.mkdirSync("atom-nrepl-test"))
    editor = new TextEditor
    spyOn(atom.workspace, 'getActiveTextEditor').andReturn(editor)
    editor.insertText("""
      (ns the-first.namespace
        (require [some-library]))
      (the first expression)
      (the second expression)

      (ns the-second.namespace
        (use [some-other-library]))
      (the third expression)
      """)

    controller = new Controller(client, atom.workspace, directory)
    controller.start()

  describe "evaluating a selected expression", ->
    beforeEach ->
      editor.setSelectedBufferRange([[3, 0], [4, 0]])

    describe "when a REPL is running", ->
      fakePort = 41235

      beforeEach ->
        fs.mkdirSync("#{directory.getPath()}/target")
        fs.writeFileSync("#{directory.getPath()}/.nrepl-port", fakePort.toString())
        atom.commands.dispatch(atom.views.getView(editor), 'nrepl:eval')
        waits 50

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

          outputView = atom.workspace.getModalPanels()[0].getItem()
          expect(outputView.textContent).toBe(":the-first-value")

    describe "when no REPL is running", ->
      beforeEach ->
        atom.commands.dispatch(atom.views.getView(editor), 'nrepl:eval')
        waits 5

      it "displays an error message", ->
        outputView = atom.workspace.getModalPanels()[0].getItem()
        expect(outputView.textContent).toBe("Connection Error - Could not find nrepl port file.")
