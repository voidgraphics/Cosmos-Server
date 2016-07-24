###
    Cosmos-Server
    /bin/controllers/ChatController.coffee ## Controller for chat.
    Started May 10, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
User = Sequelize.models.User

class UserController
    constructor: ( io ) ->
        @io = io
        zouti.log "User Controller initiating", "UserController", "GREEN"

    register: ( oUserInfo, callback ) ->
        sUserId = zouti.uuid()
        User.create {
            uuid: sUserId
            username: oUserInfo.username
            firstname: oUserInfo.firstname
            lastname: oUserInfo.lastname
            password: zouti.sha256 oUserInfo.password
        }
        .catch( ( oError ) ->
            oResult =
                code: 500
                error: oError.name
            return callback oResult
        )
        .then( ( oUserData ) ->
            if oUserData
                oResult =
                    code: 200
                    message: "User #{oUserData.username} successfully created"
            else
                oResult =
                    code: 500
                    message: "Error while creating the user"

            callback oResult
        )

    login: ( oUserInfo, oSocket ) ->
        oUserInfo.password = zouti.sha256 oUserInfo.password
        User
            .find(
                where:
                    username: oUserInfo.username
                    password: oUserInfo.password
                attributes:
                    exclude: [ "password" ]
            )
            .catch( ( oError ) -> zouti.error oError, "UserController.login" )
            .then( ( oData ) ->
                if oData
                    oSocket.emit "user.logged", oData
                else oSocket.emit "user.notlogged"
            )

    getInfo: ( sUserId, callback ) ->
        User
            .find( {
                where:
                    uuid: sUserId
                attributes:
                    exclude: [ "password" ]
            } )
            .catch( ( oError ) -> zouti.error oError, "UserController.getInfo" )
            .then( ( oData ) -> callback( oData ) )

module.exports = UserController
