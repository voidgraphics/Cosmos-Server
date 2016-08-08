###
    Cosmos-Server
    /bin/core/App.coffee ## App bootstrap
    Started Dec. 2, 2015
###
zouti = require "zouti"

TasksController = require "../controllers/TasksController.coffee"
MockupsController = require "../controllers/MockupsController.coffee"
ChatController = require "../controllers/ChatController.coffee"
UserController = require "../controllers/UserController.coffee"
CommentsController = require "../controllers/CommentsController.coffee"

class App
    constructor: ( io ) ->
        zouti.log "Instanciating App", "core/App.coffee", "BLUE"
        zouti.log "Creating models", "core/App.coffee", "BLUE"
        zouti.log "Creating controllers", "core/App.coffee", "BLUE"
        @TasksController = new TasksController
        @MockupsController = new MockupsController
        @ChatController = new ChatController( io )
        @UserController = new UserController
        @CommentsController = new CommentsController

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
        @route "mockup.get", ( sId ) => @MockupsController.get( sId, @socket )

        # Comment routes
        @route "comment.get", ( sMockupId, callback ) => @CommentsController.get( sMockupId, callback )
        @route "comment.submit", ( oComment ) => @CommentsController.submit( oComment )

        # Chat routes
        @route "chat.getAll", ( callback ) => @ChatController.getAll( callback )
        @route "chat.newMessage", ( message ) => @ChatController.newMessage( message )

        # User routes
        @route "user.login", ( oUserData ) => @UserController.login( oUserData, @socket )
        @route "user.register", ( oUserData, callback ) => @UserController.register( oUserData, callback )
        @route "user.getInfo", ( sUserId, callback ) => @UserController.getInfo( sUserId, callback )

        zouti.bench "Loading routes"

module.exports = App
