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
        zouti.bench "Loading routes"
        @route "task.getAll", ( callback ) => @TasksController.getAll( callback )
        @route "task.get", ( iTaskID ) => @TasksController.get( iTaskID )
        @route "task.save", ( oTaskData ) => @TasksController.save( oTaskData )
        @route "task.saveAll", ( aTasks ) => @TasksController.saveAll( aTasks )
        @route "task.changeState", ( iTaskID, sNewState ) => @TasksController.changeState( iTaskID, sNewState )
        @route "task.update", ( iTaskID, oTaskData ) => @TasksController.update( iTaskID, oTaskData )
        @route "task.delete", ( iTaskID ) => @TasksController.delete( iTaskID )
        zouti.bench "Loading routes"

module.exports = App
