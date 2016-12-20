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
    get: ( sMockupId, callback ) ->
        Comment
            .findAll
                where:
                    mockupId: sMockupId
                include: Sequelize.models.User
            .catch ( oError ) -> zouti.error oError, "CommentsController.get"
            .then ( aComments ) =>
                for comment in aComments
                    @getUserAvatar comment.user.avatar
                callback aComments

    getUserAvatar: ( sPath ) ->
        console.log sPath

    submit: ( oComment, socket ) ->
        Comment
            .create( {
                uuid: zouti.uuid()
                text: oComment.text
                mockupId: oComment.mockup.id
                authorId: oComment.author.id
                x: oComment.x
                y: oComment.y
            } )
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while saving your comment."
                zouti.error oError, "CommentsController.submit"
            .then( ( oSavedComment ) -> zouti.log "Saved comment", oSavedComment, "GREEN" )

module.exports = CommentsController
