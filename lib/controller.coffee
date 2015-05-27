Session = require './session'
OutputView = require './output-view'
CodeManager = require './code-manager'

module.exports =
class Controller
  constructor: (client, @workspace, directory) ->
    @session = new Session(client, directory)
    @codeManager = new CodeManager(@workspace)
    @outputView = new OutputView()
    @outputView.on("click", @dismissModal.bind(this))
    @outputView.on("blur", @dismissModal.bind(this))
    atom.commands.add @outputView.element, 'core:cancel', @dismissModal.bind(this)

  start: ->
    @panel = atom.workspace.addModalPanel(item: @outputView[0])
    atom.commands.add 'atom-text-editor:not([mini])',
      "nrepl:eval": @evalCurrentExpression.bind(this)

  stop: ->
    @panel.destroy()
    @client?.end()

  evalCurrentExpression: ->
    expression = @codeManager.currentExpressionWithNamespace()
    @session.evaluate expression, (err, values) =>
      @dismissModal()
      @panel.show()
      @outputView.focus()
      if err
        @outputView.showError(err)
      else
        @outputView.showValues(values.slice(1))

  dismissModal: ->
    @panel.hide()
