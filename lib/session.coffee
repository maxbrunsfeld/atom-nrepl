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
      currentFile = atom.workspace.getActiveTextEditor().buffer.file.path
      getParentDir currentFile, (path) =>
        getPort path, (port) =>
          if port
            @client.connect(port, fn)
          else
            error = new Error("Could not find nrepl port file.")
            error.type = "Connection Error"
            fn(error)

getPort = (path, fn) ->
  portFilePath = path + "/.nrepl-port"
  fs.exists portFilePath, (result) ->
    if result
      fs.readFile portFilePath, (err, content) ->
        fn(content and parseInt(content))
    else
      getParentDir path, (newPath) ->
        if newPath
          getPort newPath, fn
        else
          fn(null)

getParentDir = (path, fn) ->
  re = /(.*)[\\\/]/
  parent = re.exec path
  if parent
    fn(parent[1])
  else
    fn(null)
