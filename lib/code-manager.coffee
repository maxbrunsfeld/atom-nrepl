_ = require 'underscore'
DEFAULT_NAMESPACE = "user"

module.exports =
class CodeManager
  constructor: (@workspaceView) ->

  currentExpressionWithNamespace: ->
    editor = @workspaceView.getActiveView().editor
    range = currentExpressionRange(editor)
    expression = expressionInRange(range, editor)
    namespace = namespaceForRange(range, editor)
    [namespaceCall(namespace), expression].join("\n")

namespaceForRange = (range, editor) ->
  buffer = editor.getBuffer();
  charIndex = buffer.characterIndexForPosition(range.start)
  matches = buffer.matchesInCharacterRange(/\(ns\s+([\w\.-]+)/g, 0, charIndex)
  _.last(matches)?[1] or DEFAULT_NAMESPACE

currentExpressionRange = (editor) ->
  editor.getSelectedBufferRange()

expressionInRange = (range, editor) ->
  editor.getTextInRange(range)

namespaceCall = (namespace) ->
  "(ns #{namespace})"
