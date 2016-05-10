###
    Cosmos-Server
    /bin/controllers/ChatController.coffee ## Controller for chat.
    Started May 10, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Chat = Sequelize.models.Chat

class ChatController
    constructor: () ->
        zouti.log "Chat Controller initiating", "ChatController", "GREEN"

    getAll: ( callback ) ->
        Chat
            .all( include: [{ model: Sequelize.models.User }] )
            .catch( ( oError ) -> zouti.error oError, "ChatController.getAll" )
            .then( ( oData ) -> callback( oData ) )

module.exports = ChatController
