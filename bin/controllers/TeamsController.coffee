###
    Cosmos-Server
    /bin/controllers/TeamsController.coffee ## Controller for teams.
    Started Aug. 15, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
fs = require "fs"
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
                    .then ( result ) -> oSocket.emit "team.push", oTeam

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

    request: ( sUserId, sTeamId, callback ) ->
        Request
            .create
                uuid: zouti.uuid()
                userUuid: sUserId
                teamUuid: sTeamId
            .catch ( oError ) -> zouti.error oError, "TeamsController.request"
            .then ( oRequest ) -> callback oRequest

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

    accept: ( sTeamId, sUserId ) ->
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
                        Request
                            .destroy
                                where:
                                    teamUuid: sTeamId
                                    userUuid: sUserId
                            .catch ( oError ) -> zouti.error oError, "TeamsController.accept"
                            .then ( oResult ) =>
                                if oResult
                                    @io.to( sTeamId ).emit "team.removeRequest", sTeamId, sUserId

module.exports = TeamsController
