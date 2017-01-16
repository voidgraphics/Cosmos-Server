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
Mailgun = require 'mailgun-js'

class UserController
    constructor: ( io ) ->
        @io = io

    getAvatar: ( oData, oSocket ) ->
        fs.readFile __dirname + "/../../public/avatars/#{ oData.avatar }", ( err, buffer ) ->
            if err
                oSocket.emit "login.error", "Could not get your avatar"
                return zouti.error err, "UserController.getAvatar"
            oData.avatar = buffer.toString "base64"
            oSocket.emit "user.logged", oData

    register: ( oUserInfo, oSocket, callback ) ->

        matches = oUserInfo.file.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)
        sUserId = zouti.uuid()

        fs.writeFile "public/avatars/#{sUserId}", new Buffer(matches[2], "base64"), ( err ) =>
            if err
                oSocket.emit 'error.new', 'There was an error while uploading your avatar'
                zouti.error err, "UserController.register (avatar)"
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
                    email: oUserInfo.email
                    password: zouti.sha256 oUserInfo.password
                    avatar: sUserId + '.png'
                    setttings: '{"notifications": {"tasksAssigned": true,"tasksMoved": true,"tasksEdited": true, "newComment": true, "newRequest": true, "newMessage": false, "newTargetedMessage": true, "newChatroom": true, "newMockup": true, "newProject": true},"usability": {"theme": "dark","hasSchedule": false,"isColorblind": true}}'
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

    update: ( oUserData, socket ) ->
        console.log oUserData
        if oUserData.file
            matches = oUserData.file.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)
            fs.writeFile "public/avatars/#{oUserData.uuid}", new Buffer(matches[2], "base64"), ( err ) =>
                if err
                    socket.emit 'error.new', 'There was an error while uploading your avatar'
                    zouti.error err, "UserController.update (avatar)"
                easyimg.thumbnail(
                    src: "./public/avatars/#{oUserData.uuid}", dst: "./public/avatars/#{oUserData.uuid}.png",
                    width:200, height:200,
                    x:0, y:0
                )
                .then () ->

                    fs.readFile __dirname + "/../../public/avatars/#{ oUserData.uuid }", ( err, buffer ) ->
                        if err
                            socket.emit "login.error", "Could not get your avatar"
                            return zouti.error err, "UserController.update"
                        file = buffer.toString "base64"
                        socket.emit 'user.updatedAvatar', oUserData.uuid, file
        User
            .update( {
                username: oUserData.username
                firstname: oUserData.firstname
                lastname: oUserData.lastname
                email: oUserData.email
            },
            where:
                uuid: oUserData.uuid
            )
            .catch ( oError ) ->
                oSocket.emit "error.new", "There was an error while updating your account."
                zouti.error oError, 'UserController:update'
            .then () =>
                User
                    .find
                        where:
                            uuid: oUserData.uuid
                    .catch ( oError ) ->
                        socket.emit 'error.new', 'There was an error while fetching updated data for your account'
                        zouti.error oError, 'UserController:update'
                    .then ( oUser ) ->
                        socket.emit 'user.updated', oUser



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
            .catch ( oError ) ->
                oSocket.emit 'error.new', 'There was an error while logging you in.'
                zouti.error oError, "UserController.login"
            .then ( oData ) =>
                if oData
                    oSocket.cosmosUserId = oData.uuid
                    @getAvatar oData, oSocket
                else oSocket.emit "user.notlogged"

    rejoin: ( sUserId, aRooms, oSocket ) ->
        oSocket.cosmosUserId = sUserId
        @join aRooms, oSocket

    join: ( aRooms, oSocket ) ->
        for room in aRooms
            if room then oSocket.join room

    leave: ( sRoomId, oSocket ) ->
        oSocket.leave sRoomId

    logout: ( oSocket ) ->
        for room, index in oSocket.rooms
            if index != 0 && room
                oSocket.leave room

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
                                            .catch ( oError ) ->
                                                oSocket.emit 'error.new', "There was an error while getting the team's pending requests."
                                                zouti.error oError, "UserController.getTeams"
                                            .then ( oUser ) ->
                                                oSocket.emit "team.receiveRequests", request.teamUuid, oUser
                        callback aTeams


    writeSettings: ( oSettings, socket ) ->
        User
            .find
                where:
                    uuid: socket.cosmosUserId
                attributes: [ 'settings', 'username', 'uuid' ]
            .catch ( oError ) ->
                socket.emit 'error.new', 'There was an error while saving your settings'
                zouti.error oError, 'UserController.writeSettings'
            .then ( oUser ) =>
                if !oUser then return
                userSettings = JSON.parse oUser.settings
                newSettings = Object.assign userSettings, oSettings
                oUser
                    .update
                        settings: JSON.stringify newSettings
                    .catch ( oError ) ->
                        socket.emit 'error.new', 'There was an error while saving your settings'
                        zouti.error oError, 'UserController:writeSettings'

    getSettings: ( socket, callback ) ->
        User
            .find
                where:
                    uuid: socket.cosmosUserId
                attributes: ['settings']
            .catch ( oError ) ->
                socket.emit 'error.new', 'There was an error while getting your settings'
                zouti.error oError, 'UserController:getSettings'
            .then ( settings ) ->
                callback settings

    resetPassword: ( sEmail, socket ) ->

        User
            .find
                where:
                    email: sEmail
            .catch ( oError ) ->
                zouti.error oError, 'UserController.resetPassword:User.find'
                socket.emit 'error.new', 'There was an error while find the account for ' + sEmail
            .then ( oUser ) =>
                if oUser

                    oUser
                        .update
                            pwRequestId: zouti.uuid()
                        .catch ( oError ) ->
                            zouti.error oError, 'UserController.resetPassword:User.update'
                            socket.emit 'error.new', 'There was an error while generating the password reset id'
                        .then ( oUser ) =>
                            setTimeout( =>
                                oUser
                                    .update
                                        pwRequestId: ''
                                    .catch ( oError ) -> zouti.error oError, 'UserController.resetPassword:User.update'
                                    .then () => 
                                        console.log 'removed pw reset token'
                            , 120000 )
                            fs.readFile __dirname + '/../templates/pwreset.html', 'utf8', ( err, html ) =>

                                html = html.replace /@@@pwrequestid@@@/, oUser.pwRequestId

                                mailgun = new Mailgun({apiKey: 'key-a499e3128682bc814ca1e3a091a60617', domain: 'mg.getcosmos.space'})
                                data = {
                                  from: 'Cosmos <noreply@getcosmos.space>'
                                  to: oUser.email
                                  subject: 'Password reset'
                                  html: html
                                }
                                mailgun.messages().send(data, (err, body) =>
                                    if (err)
                                        console.log("got an error: ", err)
                                    else
                                        console.log(body)
                                )

    changePassword: ( sNewPassword, socket ) ->
        User
            .update {
                password: zouti.sha256 sNewPassword
            }, {
                where:
                    uuid: socket.cosmosUserId
            }
            .catch ( oError ) ->
                zouti.error oError, 'UserController.changePassword'
                socket.emit 'error.new', 'There was an error while changing your password'
            .then ( oResult ) ->
                socket.emit 'notification.flash', 'Success', 'Your password has been changed!'

module.exports = UserController
