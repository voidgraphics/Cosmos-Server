###
    Cosmos-Server
    /bin/core/App.coffee ## App bootstrap
    Started Dec. 2, 2015
###

TasksController = require "../controllers/TasksController.coffee"

class App
    constructor: () ->
        @TasksController = new TasksController

    route: ( sEvent, fCallback ) ->
        @socket.on sEvent, fCallback

    init: ( oSocket ) ->
        @socket = oSocket

        @route "task.getAll", () => @TasksController.getAll()
        @route "task.get", ( iTaskID ) => @TasksController.get( iTaskID )
        @route "task.save", ( oTaskData ) => @TasksController.save( oTaskData )
        @route "task.delete", ( iTaskID ) => @TasksController.delete( iTaskID )


module.exports = App
