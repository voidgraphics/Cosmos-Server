###
    Cosmos-Server
    /bin/controllers/CommentsController.coffee ## Controller for comments.
    Started Aug. 6, 2016
###

zouti = require "zouti"
fs = require "fs"
Sequelize = require ( "../core/sequelize.coffee" )
Comment = Sequelize.models.Comment

class CommentsController
    constructor: () ->
        zouti.log "Comments Controller initiating", "CommentsController", "GREEN"

    get: ( sMockupId, callback ) ->
        Comment
            .findAll
                where:
                    mockupId: sMockupId
            .catch ( oError ) -> zouti.error oError, "CommentsController.get"
            .then ( aComments ) -> callback aComments

module.exports = CommentsController
