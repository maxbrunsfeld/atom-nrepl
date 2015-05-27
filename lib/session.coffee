fs = require 'fs'
path = require 'path'

module.exports =
class Session
  constructor: (@client, @directory) ->

  evaluate: (input, fn) ->
    @connect null, (err) =>
      if err
        fn(err)
      else
        @client.eval(input, fn)

  connect: (port, fn) ->
    if @client.isConnected()
      fn()
    else
      getPort this, (port) =>
        if port
          @client.connect(port, fn)
        else
          error = new Error("Could not find nrepl port file.")
          error.type = "Connection Error"
          fn(error)

getPort = (self, fn) ->
  portFilePath = path.join(self.directory.getPath(), ".nrepl-port")

  fs.exists portFilePath, (result) ->
    if result
      fs.readFile portFilePath, (err, content) ->
        fn(content and parseInt(content))
    else
      fn(null)
