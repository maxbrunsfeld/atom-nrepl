{View} = require 'atom-space-pen-views'

module.exports =
class OutputView extends View
  @content: ->
    @div id: 'nrepl-output', class: 'overlay from-top', tabindex: 1, =>
      @ol outlet: 'messages'
      @span outlet: 'valueList', class: 'message'

  showError: (error) ->
    @valueList.empty()
    @valueList.append View.render ->
      @li class: 'text-error', error.type + " - " + error.message

  showValues: (values) ->
    @valueList.empty()
    for value in values
      @valueList.append View.render ->
        @li class: 'block', value
