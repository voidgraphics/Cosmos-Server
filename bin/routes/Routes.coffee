class Routes
    constructor: () ->

    init: ->

    define: ( sEvent, callback ) ->
        @socket.on sEvent, callback

module.exports = Routes
