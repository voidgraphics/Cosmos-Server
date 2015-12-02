###
    Cosmos-Server
    /bin/routes/Routes.coffee ## Routes setup
    Started Dec. 2, 2015
###

TasksController = require "../controllers/TasksController.coffee"

class Routes
    constructor: () ->
        @TasksController = new TasksController
        @TasksController.init()

    init: ->
        @define "task.save", ( oTask ) => @TasksController.test( oTask )

    define: ( sEvent, callback ) ->
        @socket.on sEvent, callback

module.exports = Routes
