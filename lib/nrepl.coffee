Controller = require './controller'
{Client} = require 'nrepl.js'

module.exports =
  controller: null

  activate: (state) ->
    @controller = new Controller(
      new Client(),
      atom.workspaceView,
      atom.project.getRootDirectory())
    @controller.start()

  deactivate: ->
    @controller.stop()

  serialize: ->
    {}
