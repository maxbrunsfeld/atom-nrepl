module.exports =
class FakeNreplClient
  constructor: ->
    @expressionsToEval = {}

  connect: (port, fn) ->
    @connectedPort = port
    @connectCallback = fn

  isConnected: ->
    @_isConnected

  eval: (expression, fn) ->
    @expressionsToEval[expression] = fn

  # 'backdoor' methods

  simulateConnectionSucceeding: ->
    @_isConnected = true
    @connectCallback()

  simulateEvaluationSucceeding: (expression, results) ->
    fn = @expressionsToEval[expression]
    unless fn
      throw new Error("""
        Expression was not requested: '#{expression}'.
        Requested expressions: #{JSON.stringify(Object.keys(@expressionsToEval))}
      """)
    fn(null, results)
