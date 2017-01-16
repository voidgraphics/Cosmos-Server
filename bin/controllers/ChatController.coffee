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
User = Sequelize.models.User
Project = Sequelize.models.Project

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

    createChatroom: ( oChatroom, socket ) ->
        Chatroom
            .create
                uuid: oChatroom.uuid
                name: oChatroom.name
                projectUuid: oChatroom.projectUuid
            .catch ( oError ) -> zouti.error oError, "ChatController.createChatroom"
            .then ( oChatroom ) =>
                zouti.log "Created chatroom", oChatroom, "GREEN"
                socket.notifications.generate 'New chatroom: #' + oChatroom.name, oChatroom.projectUuid, 'notification.chatroom.new'
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
                                            limit: 30
                                            order: 'createdAt DESC'
                                        .catch ( oError ) -> zouti.error oError, "ChatController.getAll"
                                        .then ( aMessages ) ->
                                            callback aChatrooms, aMessages, aUsers

    getMessages: ( sChatroomId, callback ) ->
        Chat
            .findAll
                where:
                    chatroomUuid: sChatroomId
                limit: 30
                order: 'createdAt DESC'
                include: [{ model: Sequelize.models.User }]
            .catch ( oError ) -> zouti.error oError, "ChatController.getMessages"
            .then ( aMessages ) ->
                callback aMessages

    newMessage: ( message, socket ) ->
        Chat.create( {
            id: zouti.uuid()
            userId: message.userId
            text: message.text
            projectUuid: message.projectId
            chatroomUuid: message.chatroomId
        }, {
            include: [{ model: Sequelize.models.User }]
        } )
        .catch ( oError ) -> zouti.error oError, "ChatController.newMessage"
        .then ( oSavedMessage ) =>
            User.find
                where: { uuid: message.userId }
            .catch ( oError ) -> zouti.error oError, "ChatController.newMessage"
            .then ( user ) =>
                @parseMessage oSavedMessage, socket
                @io.to( message.projectId ).emit "chat.new", oSavedMessage, user

    parseMessage: ( oMessage, socket ) ->
        regex = /\B@([.\S]+)\b/g
        match = regex.exec oMessage.text
        aUsersToNotify = []
        while match != null
            aUsersToNotify.push match[1]
            match = regex.exec oMessage.text
        Project
            .find
                where:
                    uuid: oMessage.projectUuid
                include: [
                    {
                        model: Team
                        attributes: [ 'uuid' ]
                        include: [ {
                            model: User
                            where: { username: { $in: aUsersToNotify } }
                            attributes: [ 'uuid', 'username' ]
                        } ]
                    },
                    {
                        model: Chatroom
                        where:
                            uuid: oMessage.chatroomUuid
                    }
                 ]
            .catch ( oError ) ->
                zouti.error oError, 'ChatController.parseMessage'
            .then ( oResult ) =>
                if oResult
                    aUsersToNotify = []
                    for user in oResult.team.users
                        aUsersToNotify.push user.uuid
                    if oMessage.text.length > 50
                        oMessage.text = oMessage.text.substring(0, 50) + '...'
                    socket.notifications.generate '#' + oResult.chatrooms[0].name + ': ' + oMessage.text, oResult.uuid, 'notification.message.targeted', aUsersToNotify, socket.cosmosUserId

module.exports = ChatController
