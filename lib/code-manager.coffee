_ = require 'underscore'
DEFAULT_NAMESPACE = "user"

module.exports =
class CodeManager
  constructor: (@workspaceView) ->

  currentExpressionWithNamespace: ->
    view = @workspaceView.getActiveView()
    range = currentExpressionRange(view)
    expression = expressionInRange(range, view)
    namespace = namespaceForRange(range, view)
    [namespaceCall(namespace), expression].join("\n")

namespaceForRange = (range, view) ->
  buffer = view.getBuffer();
  charIndex = buffer.characterIndexForPosition(range.start)
  matches = buffer.matchesInCharacterRange(/\(ns\s+([\w\.-]+)/g, 0, charIndex)
  _.last(matches)?[1] or DEFAULT_NAMESPACE

currentExpressionRange = (view) ->
  view.getSelectedBufferRange()

expressionInRange = (range, view) ->
  view.getTextInRange(range)

view = (self) ->
  self.workspaceView.getActiveView()

namespaceCall = (namespace) ->
  "(ns #{namespace})"
