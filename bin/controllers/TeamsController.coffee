###
    Cosmos-Server
    /bin/controllers/TeamsController.coffee ## Controller for teams.
    Started Aug. 15, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
fs = require "fs"
User = Sequelize.models.User
Team = Sequelize.models.Team
Request = Sequelize.models.Request
Chatroom = Sequelize.models.Chatroom

class TeamsController
    constructor: ( io ) ->
        @io = io

    getUsers: ( sTeamId, oSocket ) ->
        Team
            .find
                where:
                    uuid: sTeamId
                include: Sequelize.models.User
            .catch ( oError ) => zouti.error oError, "TeamsController.getUsers"
            .then ( oTeam ) =>
                for user in oTeam.users
                    @fetchAvatar user, oSocket

    fetchAvatar: ( oUser, oSocket ) ->
        fs.readFile __dirname + "/../../public/avatars/#{ oUser.avatar }", ( err, buffer ) ->
            if err
                oSocket.emit "user.error", "Could not get avatar for #{oUser.username}"
                return zouti.error err, "TeamsController.fetchAvatar"
            oUser.avatar = buffer.toString "base64"
            oSocket.emit "team.receiveUser", oUser

    create: ( sTeamName, sUserId, oSocket ) ->
        Team
            .create
                uuid: zouti.uuid()
                name: sTeamName
            .catch ( oError ) -> zouti.error oError, "TeamsController.create"
            .then ( oTeam ) ->
                oTeam
                    .addUser sUserId
                    .catch ( oError ) -> zouti.error oError, "TeamsController.create"
                    .then ( result ) ->
                        Team
                            .find
                                where:
                                    uuid: oTeam.uuid
                                include: [ Sequelize.models.Project, Sequelize.models.Request ]
                            .catch ( oError ) -> zouti.error oError, "TeamsController.create"
                            .then ( bruh ) ->
                                oSocket.emit "team.push", bruh

    createAndProject: ( oTeam, oProject, oSocket ) ->
        id = zouti.uuid()
        Team
            .create {
                uuid: id
                name: oTeam.name
                projects: [
                    {
                        uuid: zouti.uuid()
                        name: oProject.name
                        teamUuid: id
                     }
                ]
            }, {
                include: [ Sequelize.models.Project ]
            }
            .catch ( oError ) -> zouti.error oError, "TeamsController.createAndProject"
            .then ( oResult ) ->
                oResult
                    .addUser oTeam.userUuid
                    .catch ( oError ) -> zouti.error oError, "TeamsController.createAndProject"
                    .then ( result ) -> oSocket.emit "team.initialized", oResult, oResult.projects[0]

                Chatroom
                    .create
                        uuid: zouti.uuid()
                        name: "General"
                        projectUuid: oResult.projects[0].uuid
                    .catch ( oError ) -> zouti.error oError, "TeamsController.createChatroom"
                    .then ( oChatroom ) =>
                        zouti.log "Created chatroom", oChatroom, "GREEN"

    find: ( sTeamName, sUserId, callback ) ->
        Team
            .findAll
                where:
                    name:
                        $like: "%#{sTeamName}%"
            .catch ( oError ) -> zouti.error oError, "TeamsController.find"
            .then ( aResults ) ->
                Request
                    .findAll
                        where:
                            userUuid: sUserId
                    .catch ( oError ) -> zouti.error oError, "TeamsController.find"
                    .then ( aRequests ) ->
                        callback aResults, aRequests

    getRequests: ( sTeamId, oSocket, callback ) ->
        Request
            .findAll
                where:
                    teamUuid: sTeamId
                include: [ { model: Sequelize.models.User, attributes: { exclude: ['password'] }}, Sequelize.models.Team ]
            .catch ( oError ) -> zouti.error oError, "TeamsController.getRequests"
            .then ( aRequests ) =>
                for oRequest in aRequests
                    @getRequestAvatar oRequest.uuid, oRequest.user.avatar, ( sRequestId, sImage ) ->
                        oSocket.emit "request.addAvatar", sRequestId, sImage
                callback aRequests

    getRequestAvatar: ( sRequestId, sPath, callback ) ->
        console.log "getting avatar " + sPath
        fs.readFile __dirname + "/../../public/avatars/#{ sPath }", ( err, buffer ) ->
            if err
                oSocket.emit "error.new", "Could not get user's avatar"
                return zouti.error err, "TeamsController.getRequestAvatar"
            return callback sRequestId, buffer.toString "base64"

    request: ( sUserId, sTeamId, oSocket, callback ) ->
        Request
            .create
                uuid: zouti.uuid()
                userUuid: sUserId
                teamUuid: sTeamId
            .catch ( oError ) ->
                oSocket.emit "error.new", "There was an error while sending your request."
                zouti.error oError, "TeamsController.request"
            .then ( oRequest ) =>
                Request
                    .find
                        where:
                            uuid: oRequest.uuid
                        include: [ { model: Sequelize.models.User, attributes: { exclude: ['password'] }}, Sequelize.models.Team ]
                    .catch ( oError ) -> zouti.error oError, "TeamsController.request"
                    .then ( request ) =>
                        console.log 'emitting to ' + sTeamId
                        @io.to( sTeamId ).emit 'request.new', request
                        @getRequestAvatar request.uuid, request.user.avatar, ( sRequestId, sImage ) =>
                            @io.to( sTeamId ).emit 'request.addAvatar', sRequestId, sImage
                callback oRequest

    leave: ( sTeamId, sUserId, oSocket ) ->
        Team
            .find
                where:
                    uuid: sTeamId
            .catch ( oError ) -> zouti.error oError, "TeamsController.leave"
            .then ( oTeam ) ->
                oTeam
                    .removeUser sUserId
                    .catch ( oError ) -> zouti.error oError, "TeamsController.leave"
                    .then () -> oSocket.emit "team.left", sTeamId

    accept: ( sTeamId, sUserId, socket ) ->
        Team
            .find
                where:
                    uuid: sTeamId
            .catch ( oError ) -> zouti.error oError, "TeamsController.accept"
            .then ( oTeam ) =>
                oTeam
                    .addUser sUserId
                    .catch ( oError ) -> zouti.error oError, "TeamsController.accept"
                    .then ( oResult ) =>
                        User
                            .find
                                where:
                                    uuid: sUserId
                                attributes: [ 'username' ]
                            .catch ( oError ) -> zouti.error oError, 'TeamsController.accept'
                            .then ( oUser ) =>
                                @io.to( sTeamId ).emit 'notification.flash', oTeam.name, oUser.username + ' has just joined your team!'
                        Request
                            .destroy
                                where:
                                    teamUuid: sTeamId
                                    userUuid: sUserId
                            .catch ( oError ) -> zouti.error oError, "TeamsController.accept"
                            .then ( oResult ) =>
                                if oResult
                                    @io.to( sTeamId ).emit "team.removeRequest", sTeamId, sUserId

    removeRequest: ( sRequestId, sTeamId ) ->
        Request
            .find
                where:
                    uuid: sRequestId
                include: [ Sequelize.models.User, Sequelize.models.Team ]
            .catch ( oError ) -> zouti.error oError, "TeamsController.removeRequest"
            .then ( oRequest ) =>
                Request
                    .destroy
                        where:
                            uuid: sRequestId
                    .catch ( oError ) -> zouti.error oError, "TeamsController.removeRequest"
                    .then ( oResult ) =>
                        @io.to( sTeamId ).emit "team.removeRequest", oRequest.team.uuid, oRequest.user.uuid
                        @io.to( sTeamId ).emit 'request.removed', sRequestId
module.exports = TeamsController
