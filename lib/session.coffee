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
        @client.connect(port, fn)

getPort = (self, fn) ->
  portFilePath = path.join(self.directory.path, "target", "repl-port")
  fs.exists portFilePath, (result) ->
    if result
      fs.readFile portFilePath, (err, content) ->
        fn(content and parseInt(content))
    else
      fn(null)
