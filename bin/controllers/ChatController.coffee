###
    Cosmos-Server
    /bin/controllers/ChatController.coffee ## Controller for chat.
    Started May 10, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
fs = require "fs"
Chat = Sequelize.models.Chat
Chatroom = Sequelize.models.Chatroom
Team = Sequelize.models.Team

class ChatController
    constructor: ( io ) ->
        @io = io

    getAvatar: ( oData, oSocket ) ->
        u = {
            uuid: oData.uuid
        }
        fs.readFile __dirname + "/../../public/avatars/#{ oData.avatar }", ( err, buffer ) ->
            if err
                oSocket.emit "login.error", "Could not get user's avatar"
                return zouti.error err, "ChatController.getAvatar"
            u.avatar = buffer.toString "base64"
            setTimeout () ->
                oSocket.emit "user.receiveAvatar", u
            , 20

    createChatroom: ( oChatroom ) ->
        Chatroom
            .create
                uuid: oChatroom.uuid
                name: oChatroom.name
                projectUuid: oChatroom.projectUuid
            .catch ( oError ) -> zouti.error oError, "ChatController.createChatroom"
            .then ( oChatroom ) =>
                zouti.log "Created chatroom", oChatroom, "GREEN"
                @io.to(oChatroom.projectUuid).emit "chat.newChatroom", oChatroom

    getAll: ( sProjectId, sTeamId, oSocket, callback ) ->
        Chatroom
            .findAll
                where:
                    projectUuid: sProjectId
            .catch ( oError ) -> zouti.error oError, "ChatController.getAll"
            .then ( aChatrooms ) =>
                Team
                    .find
                        where:
                            uuid: sTeamId
                    .catch ( oError ) -> zouti.error oError, "ChatController.getAll"
                    .then ( oTeam ) =>
                        oTeam.getUsers
                            attributes:
                                exclude: [ "password" ]
                        .catch ( oError ) -> zouti.error oError, "ChatController.getAll"
                        .then ( aUsers ) =>
                            for user in aUsers
                                @getAvatar user, oSocket
                                user.avatar = "../img/default.png"
                            for oChatroom in aChatrooms
                                if oChatroom.name == "General"
                                    oChatroom
                                        .getChats
                                            include: [{ model: Sequelize.models.User }]
                                        .catch ( oError ) -> zouti.error oError, "ChatController.getAll"
                                        .then ( aMessages ) ->
                                            callback aChatrooms, aMessages, aUsers

    getMessages: ( sChatroomId, callback ) ->
        Chat
            .findAll
                where:
                    chatroomUuid: sChatroomId
                include: [{ model: Sequelize.models.User }]
            .catch ( oError ) -> zouti.error oError, "ChatController.getMessages"
            .then ( aMessages ) ->
                callback aMessages

    newMessage: ( message ) ->
        that = this
        Chat.create( {
            id: zouti.uuid()
            userId: message.userId
            text: message.text
            projectUuid: message.projectId
            chatroomUuid: message.chatroomId
        }, {
            include: [{ model: Sequelize.models.User }]
        } )
        .catch( ( oError ) -> zouti.error oError, "ChatController.newMessage" )
        .then( ( oSavedMessage ) ->
            Sequelize.models.User.find({
                where: { uuid: message.userId }
            } )
            .catch ( oError ) -> zouti.error oError, "ChatController.newMessage"
            .then ( user ) ->
                that.io.to( message.projectId ).emit "chat.new", oSavedMessage, user
        )

module.exports = ChatController
