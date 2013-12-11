{View} = require 'atom'
_ = require 'underscore'

module.exports =
class OutputView extends View
  @content: ->
    @div id: 'nrepl-output', class: 'overlay from-top', click: 'hide', =>
      @ol outlet: 'messages'
      @span outlet: 'valueList', class: 'message'

  initialize: ->
    @hide()

  showError: (error) ->
    @show()
    @valueList.empty()
    @valueList.append View.render ->
      @li class: 'text-error', error.type + " - " + error.message

  showValues: (values) ->
    @show()
    @valueList.empty()
    for value in values
      @valueList.append View.render ->
        @li class: 'block', value
