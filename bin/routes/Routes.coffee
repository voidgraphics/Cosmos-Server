###
    Cosmos-Server
    /bin/routes/Routes.coffee ## Routes setup
    Started Dec. 2, 2015
###

TasksController = require "../controllers/TasksController.coffee"

class Routes
    constructor: () ->
        @TasksController = new TasksController

    define: ( sEvent, callback ) ->
        @socket.on sEvent, callback

    init: ( socket ) ->
        @socket = socket

        @define "task.save", ( oTaskData ) => @TasksController.save( oTaskData )


module.exports = Routes
