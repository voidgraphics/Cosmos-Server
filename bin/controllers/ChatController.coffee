###
    Cosmos-Server
    /bin/controllers/ChatController.coffee ## Controller for chat.
    Started May 10, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Chat = Sequelize.models.Chat

class ChatController
    constructor: ( io ) ->
        @io = io
        zouti.log "Chat Controller initiating", "ChatController", "GREEN"

    getAll: ( callback ) ->
        Chat
            .all( include: [{ model: Sequelize.models.User }] )
            .catch( ( oError ) -> zouti.error oError, "ChatController.getAll" )
            .then( ( oData ) -> callback( oData ) )

    newMessage: ( message ) ->
        that = this
        Chat.create( {
            id: zouti.uuid()
            userId: message.userId,
            text: message.text
        }, {
            include: [{ model: Sequelize.models.User }]
        } )
        .catch( ( oError ) -> zouti.error oError, "ChatController.newMessage" )
        .then( ( oSavedMessage ) ->
            Sequelize.models.User.find({
                where: { uuid: message.userId }
            } )
            .catch ( oError ) -> zouti.error oError, "ChatController.newMessage"
            .then ( user ) -> that.io.sockets.emit "chat.new", oSavedMessage, user

        )

module.exports = ChatController
