Session = require './session'
OutputView = require './output-view'
CodeManager = require './code-manager'

module.exports =
class Controller
  constructor: (client, @workspaceView, directory) ->
    @session = new Session(client, directory)
    @codeManager = new CodeManager(workspaceView)
    @outputView = new OutputView()

  start: ->
    @outputView.appendTo(@workspaceView)
    @workspaceView.command "nrepl:eval", =>
      @evalCurrentExpression()

  stop: ->
    @outputView.detach()
    @client?.end()

  evalCurrentExpression: ->
    expression = @codeManager.currentExpressionWithNamespace()
    @session.evaluate expression, (err, values) =>
      if err
        @outputView.showError(err)
      else
        @outputView.showValues(values.slice(1))
