Controller = require './controller'
{Client} = require 'nrepl.js'

module.exports =
  controller: null

  activate: (state) ->
    @controller = new Controller(
      new Client(),
      atom.workspace,
      atom.project.getDirectories()[0])
    @controller.start()

  deactivate: ->
    @controller.stop()
