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
ProjectsController = require "../controllers/ProjectsController.coffee"
TeamsController = require "../controllers/TeamsController.coffee"
NotificationsController = require "../controllers/NotificationsController.coffee"

class App
    constructor: ( io ) ->
        zouti.log "Instanciating App", "core/App.coffee", "BLUE"
        zouti.log "Creating controllers", "core/App.coffee", "BLUE"
        @TasksController = new TasksController io
        @MockupsController = new MockupsController io
        @ChatController = new ChatController io
        @UserController = new UserController
        @CommentsController = new CommentsController
        @ProjectsController = new ProjectsController
        @TeamsController = new TeamsController io
        @NotificationsController = new NotificationsController
        @users = {}

    route: ( sEvent, fCallback ) ->
        @socket.on sEvent, fCallback

    init: ( oSocket ) ->
        @socket = oSocket
        zouti.bench "Loading routes"

        # Task routes
        @route "task.getAll", ( sProjectId, callback ) => @TasksController.getAll( sProjectId, callback )
        @route "task.getRecent", ( callback ) => @TasksController.getRecent( callback )
        @route "task.save", ( oTaskData ) => @TasksController.save( oTaskData, @socket )
        @route "task.saveAll", ( aTasks ) => @TasksController.saveAll( aTasks, @socket )
        @route "task.update", ( oTaskData ) => @TasksController.update( oTaskData )
        @route "task.delete", ( iTaskID, sProjectId ) => @TasksController.delete( iTaskID, @socket, sProjectId )
        @route "task.notifyMove", ( oTask ) => @TasksController.handleMoveNotification( oTask )

        # Mockup routes
        @route "mockup.getAll", ( sProjectId ) => @MockupsController.getAll( sProjectId, @socket )
        @route "mockup.get", ( sId ) => @MockupsController.get( sId, @socket )
        @route "mockup.create", ( oMockup, callback ) => @MockupsController.create( oMockup, @socket )
        @route "mockup.delete", ( sMockupId ) => @MockupsController.delete( sMockupId, @socket )

        # Comment routes
        @route "comment.get", ( sMockupId, callback ) => @CommentsController.get( sMockupId, callback )
        @route "comment.submit", ( oComment ) => @CommentsController.submit( oComment, @socket )

        # Chat routes
        @route "chat.getAll", ( sProjectId, sTeamId, callback ) => @ChatController.getAll( sProjectId, sTeamId, @socket, callback )
        @route "chat.getMessages", ( sChatroomId, callback ) => @ChatController.getMessages( sChatroomId, callback )
        @route "chat.newMessage", ( message ) => @ChatController.newMessage( message )
        @route "chat.createChatroom", ( oChatroom ) => @ChatController.createChatroom( oChatroom )

        # User routes
        @route "user.login", ( oUserData ) => @UserController.login( oUserData, @socket )
        @route "user.register", ( oUserData, callback ) => @UserController.register( oUserData, @socket, callback )
        @route "user.getInfo", ( sUserId, callback ) => @UserController.getInfo( sUserId, @socket, callback )
        @route "user.getTeams", ( sUserId, callback ) => @UserController.getTeams( sUserId, @socket, callback )
        @route "user.join", ( sProjectId, sTeamId ) => @UserController.join( sProjectId, sTeamId, @socket )
        @route "user.leave", ( sRoomId ) => @UserController.leave( sRoomId, @socket )

        # Team routes
        @route "team.create", ( sTeamName, sUserId ) => @TeamsController.create( sTeamName, sUserId, @socket )
        @route "team.createAndProject", ( oTeam, oProject ) => @TeamsController.createAndProject( oTeam, oProject, @socket )
        @route "team.accept", ( sTeamId, sUserId ) => @TeamsController.accept( sTeamId, sUserId )
        @route "team.find", ( sTeamName, sUserId, callback ) => @TeamsController.find( sTeamName, sUserId, callback )
        @route "team.leave", ( sTeamId, sUserId ) => @TeamsController.leave( sTeamId, sUserId, @socket )
        @route "team.request", ( sUserId, sTeamId, callback ) => @TeamsController.request( sUserId, sTeamId, callback )
        @route "team.getUsers", ( sTeamId ) => @TeamsController.getUsers( sTeamId, @socket )

        # Project routes
        @route "project.create", ( oProjectData, callback ) => @ProjectsController.create( oProjectData, @socket, callback )

        # Notification routes
        @route "notifications.fetch", ( sUserId, callback ) =>  @NotificationsController.fetch( sUserId, callback )
        @route "notifications.read", ( sNotificationId ) =>  @NotificationsController.read( sNotificationId )

        zouti.bench "Loading routes"

module.exports = App
