###
    Cosmos-Server
    /bin/core/App.coffee ## App bootstrap
    Started Dec. 2, 2015
###
zouti = require "zouti"

TasksController = require "../controllers/TasksController.coffee"
MockupsController = require "../controllers/MockupsController.coffee"
ChatController = require "../controllers/ChatController.coffee"

class App
    constructor: ( io ) ->
        zouti.log "Instanciating App", "core/App.coffee", "BLUE"
        zouti.log "Creating models", "core/App.coffee", "BLUE"
        Sequelize = require "./sequelize.coffee"
        zouti.log "Creating controllers", "core/App.coffee", "BLUE"
        @TasksController = new TasksController
        @MockupsController = new MockupsController
        @ChatController = new ChatController( io )

    route: ( sEvent, fCallback ) ->
        @socket.on sEvent, fCallback

    init: ( oSocket ) ->
        @socket = oSocket
        zouti.bench "Loading routes"

        # Task routes
        @route "task.getAll", ( callback ) => @TasksController.getAll( callback )
        @route "task.getRecent", ( callback ) => @TasksController.getRecent( callback )
        @route "task.save", ( oTaskData ) => @TasksController.save( oTaskData )
        @route "task.saveAll", ( aTasks ) => @TasksController.saveAll( aTasks )
        @route "task.update", ( iTaskID, oTaskData ) => @TasksController.update( iTaskID, oTaskData )
        @route "task.delete", ( iTaskID ) => @TasksController.delete( iTaskID )

        # Mockup routes
        @route "mockup.getAll", ( ) => @MockupsController.getAll( @socket )

        # Chat routes
        @route "chat.getAll", ( callback ) => @ChatController.getAll( callback )
        @route "chat.newMessage", ( message ) => @ChatController.newMessage( message )

        zouti.bench "Loading routes"

module.exports = App
