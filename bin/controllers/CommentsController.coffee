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
    constructor: ( io ) ->
        @io = io

    get: ( sMockupId, oSocket, callback ) ->
        Comment
            .findAll
                where:
                    'mockup_id': sMockupId
                include: Sequelize.models.User
            .catch ( oError ) -> zouti.error oError, "CommentsController.get"
            .then ( aComments ) =>
                for comment in aComments
                    if comment.user
                        @getUserAvatar comment.uuid, comment.user.avatar, ( sCommentId, sImage ) =>
                            oSocket.emit "comment.addAvatar", sCommentId, sImage
                callback aComments

    getUserAvatar: ( sCommentId, sPath, callback ) ->
        fs.readFile __dirname + "/../../public/avatars/#{ sPath }", ( err, buffer ) ->
            if err
                oSocket.emit "error.new", "Could not get user's avatar"
                return zouti.error err, "CommentsController.getUserAvatar"
            callback sCommentId, buffer.toString 'base64'


    submit: ( oComment, sProjectId, socket ) ->
        Comment
            .create( {
                uuid: zouti.uuid()
                text: oComment.text
                'mockup_id': oComment.mockup.id
                authorId: oComment.author.id
                x: oComment.x
                y: oComment.y
            } )
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while saving your comment."
                zouti.error oError, "CommentsController.submit"
            .then ( oSavedComment ) =>
                console.log oComment
                console.log '#########'
                console.log "Added comment!"
                Comment
                    .find
                        where:
                            id: oSavedComment.uuid
                        include: [Sequelize.models.User, Sequelize.models.Mockup]
                    .catch ( oError ) =>
                        socket.emit "error.new", "There was an error while fetching your new comment."
                        zouti.error oError, "CommentsController.submit"
                    .then ( oComment ) =>
                        @getUserAvatar oComment.uuid, oComment.user.avatar, ( sCommentId, sAvatar ) =>
                            console.log 'sending the avatar to go with the comment'
                            @io.to( sProjectId ).emit 'comment.addAvatar', sCommentId, sAvatar
                        socket.notifications.generate "#{oComment.user.username} commented on \"#{oComment.mockup.title}\"", sProjectId, 'notification.comment.created', null, oComment.user.uuid
                        console.log "emitting the comment!"
                        @io.to( sProjectId ).emit "comment.sent", oComment
                zouti.log "Saved comment", oSavedComment, "GREEN"

module.exports = CommentsController
