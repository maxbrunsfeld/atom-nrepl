_ = require 'underscore'

DEFAULT_NAMESPACE = "user"
NAMESPACE_REGEX = /\(ns\s+([\w\.-]+)/g

module.exports =
class CodeManager
  constructor: (@workspace) ->

  currentExpressionWithNamespace: ->
    editor = @workspace.getActiveTextEditor()
    range = currentExpressionRange(editor)
    expression = expressionInRange(range, editor)
    namespace = namespaceForRange(range, editor)
    [namespaceCall(namespace), expression].join("\n")

namespaceForRange = (range, editor) ->
  precedingNamespace = null
  editor.backwardsScanInBufferRange NAMESPACE_REGEX, [[0, 0], range.start], ({match, stop}) ->
    precedingNamespace = match[1]
    stop()
  precedingNamespace ? DEFAULT_NAMESPACE

currentExpressionRange = (editor) ->
  editor.getSelectedBufferRange()

expressionInRange = (range, editor) ->
  editor.getTextInRange(range)

namespaceCall = (namespace) ->
  "(ns #{namespace})"
