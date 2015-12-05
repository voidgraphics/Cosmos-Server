###
    Cosmos-Server
    /bin/core/App.coffee ## App bootstrap
    Started Dec. 2, 2015
###
zouti = require "zouti"
TasksController = require "../controllers/TasksController.coffee"

class App
    constructor: () ->
        zouti.log "Instanciating App, creating controllers", "core/App.coffee", "BLUE"
        @TasksController = new TasksController

    route: ( sEvent, fCallback ) ->
        @socket.on sEvent, fCallback

    init: ( oSocket ) ->
        @socket = oSocket

        @route "task.getAll", ( callback ) => @TasksController.getAll( callback )
        @route "task.get", ( iTaskID ) => @TasksController.get( iTaskID )
        @route "task.save", ( oTaskData ) => @TasksController.save( oTaskData )
        @route "task.delete", ( iTaskID ) => @TasksController.delete( iTaskID )


module.exports = App
