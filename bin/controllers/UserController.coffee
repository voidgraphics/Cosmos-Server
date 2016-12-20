###
    Cosmos-Server
    /bin/controllers/ChatController.coffee ## Controller for chat.
    Started May 10, 2016
###

zouti = require "zouti"
fs = require "fs"
easyimg = require "easyimage"
Sequelize = require ( "../core/sequelize.coffee" )
User = Sequelize.models.User
Team = Sequelize.models.Team

class UserController
    constructor: ( io ) ->
        @io = io

    getAvatar: ( oData, oSocket ) ->
        fs.readFile __dirname + "/../../public/avatars/#{ oData.avatar }", ( err, buffer ) ->
            if err
                oSocket.emit "login.error", "Could not get user's avatar"
                return zouti.error err, "UserController.getAvatar"
            oData.avatar = buffer.toString "base64"
            oSocket.emit "user.logged", oData

    register: ( oUserInfo, oSocket, callback ) ->

        matches = oUserInfo.file.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)
        sUserId = zouti.uuid()

        fs.writeFile "public/avatars/#{sUserId}", new Buffer(matches[2], "base64"), ( err ) =>
            if err then zouti.error err, "UserController.register (avatar)"
            easyimg.thumbnail(
                src: "./public/avatars/#{sUserId}", dst: "./public/avatars/#{sUserId}.png",
                width:200, height:200,
                x:0, y:0
            )
            .then(
                User.create
                    uuid: sUserId
                    username: oUserInfo.username
                    firstname: oUserInfo.firstname
                    lastname: oUserInfo.lastname
                    password: zouti.sha256 oUserInfo.password
                    avatar: sUserId + '.png'
                .catch ( oError ) ->
                    oSocket.emit "error.new", "There was an error while creating your account."
                    oResult =
                        code: 500
                        error: oError.name
                    return callback oResult
                .then ( oUserData ) =>
                    if oUserData
                        oResult =
                            code: 200
                            message: "User #{oUserData.username} successfully created"
                            user: oUserData
                        data = {
                            username: oUserInfo.username
                            password: oUserInfo.password
                        }
                        setTimeout( () =>
                            @login data, oSocket
                        , 1000 )
                    else
                        oResult =
                            code: 500
                            message: "Error while creating the user"

                    callback oResult
            )


    login: ( oUserInfo, oSocket ) ->
        oUserInfo.password = zouti.sha256 oUserInfo.password
        User
            .find
                where:
                    username: oUserInfo.username
                    password: oUserInfo.password
                attributes:
                    exclude: [ "password" ]
                include:
                    model: Sequelize.models.Team
                    include: [ Sequelize.models.Project ]
            .catch ( oError ) -> zouti.error oError, "UserController.login"
            .then ( oData ) =>
                if oData
                    @getAvatar oData, oSocket
                    App.users[oData.uuid] = oSocket
                else oSocket.emit "user.notlogged"

    join: ( sProjectId, sTeamId, oSocket ) ->
        oSocket.join sProjectId
        oSocket.join sTeamId

    leave: ( sRoomId, oSocket ) ->
        oSocket.leave sRoomId

    addProjects: ( projects, sTeamName, aProjects ) ->
        return projects[ sTeamName ] = aProjects

    getInfo: ( sUserId, socket, callback ) ->
        User
            .find
                where:
                    uuid: sUserId
                attributes:
                    exclude: [ "password" ]
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while retrieving user data."
                zouti.error oError, "UserController.getInfo"
            .then ( oData ) -> callback( oData )

    getTeams: ( sUserId, oSocket, callback ) ->
        User
            .find
                where:
                    id: sUserId
            .catch ( oError ) -> zouti.error oError, "UserController.getTeams"
            .then ( oUser ) ->
                oUser
                    .getTeams()
                    .catch ( oError ) ->
                        oSocket.emit "error.new", "There was an error while getting the user's teams."
                        zouti.error oError, "UserController.getTeams"
                    .then ( aTeams ) ->
                        for team in aTeams
                            team
                                .getRequests()
                                .catch ( oError ) ->
                                    oSocket.emit "error.new", "There was an error while getting the team's pending requests."
                                    zouti.error oError, "UserController.getTeams"
                                .then ( aRequests ) ->
                                    for request in aRequests
                                        User
                                            .find
                                                where:
                                                    uuid: request.userUuid
                                            .catch ( oError ) -> zouti.error oError, "UserController.getTeams"
                                            .then ( oUser ) ->
                                                oSocket.emit "team.receiveRequests", request.teamUuid, oUser
                        callback aTeams

module.exports = UserController
