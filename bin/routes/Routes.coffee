###
    Cosmos-Server
    /bin/routes/Routes.coffee ## Routes setup
    Started Dec. 2, 2015
###

TasksController = require "../controllers/TasksController.coffee"

class Routes
    constructor: () ->
        @TasksController = new TasksController

    define: ( sEvent, fCallback ) ->
        @socket.on sEvent, fCallback

    init: ( oSocket ) ->
        @socket = oSocket

        @define "task.save", ( oTaskData ) => @TasksController.save( oTaskData )


module.exports = Routes
