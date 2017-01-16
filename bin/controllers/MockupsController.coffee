###
    Cosmos-Server
    /bin/controllers/MockupsController.coffee ## Controller for mockups.
    Started Jan. 18, 2015
###

zouti = require "zouti"
fs = require "fs"
easyimg = require "easyimage"
oSequelize = require ( "../core/sequelize.coffee" )
Mockup = oSequelize.models.Mockup

class MockupsController
    constructor: ( io ) ->
        @io = io

    getThumb: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/thumbnail/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "error.new", "Could not get thumbnail for #{mockup.title}"
                return zouti.error err, "MockupsController.getThumb"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup, mockup.commentCount

    getImage: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/fullsize/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "error.new", "Could not get image for #{mockup.title}"
                return zouti.error err, "MockupsController.getImage"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup

    getAll: ( sProjectId, oSocket ) ->
        Mockup
            .findAll
                where:
                    projectUuid: sProjectId
            .catch ( oError ) ->
                oSocket.emit "error.new", "There was an error while getting the mockups."
                zouti.error oError, "MockupsController.getAll"
            .then ( oData ) =>
                for mockup in oData
                    @countComments mockup, oSocket

    countComments: ( mockup, oSocket ) ->
        oSequelize.models.Comment.count
            where:
                'mockup_id': mockup.uuid
        .catch ( e ) ->
            oSocket.emit "error.new", "There was an error while counting comments on #{mockup.title}."
            console.error e
        .then ( count ) =>
            mockup.commentCount = count
            @getThumb mockup, oSocket

    get: ( sId, oSocket ) ->
        Mockup
            .find
                where:
                    id: sId
            .catch ( oError ) ->
                oSocket.emit "error.new", "We could not get this item."
                zouti.error oError, "UserController.login"
            .then ( mockup ) =>
                @getImage mockup, oSocket

    create: ( oMockupData, oSocket ) ->
        zouti.log "Adding mockup #{ oMockupData.name }", "MockupsController", "BLUE"
        matches = oMockupData.file.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)

        uuid = zouti.uuid()

        fs.writeFile "public/mockups/fullsize/#{oMockupData.image}", new Buffer(matches[2], "base64"), ( err ) =>
            if err
                oSocket.emit "error.new", "There was a problem while uploading the image to the server."
                zouti.error err, "MockupsController.create"
            easyimg.convert
                src: "./public/mockups/fullsize/#{oMockupData.image}", dst: "./public/mockups/fullsize/#{uuid}.png"
            easyimg.thumbnail
                src: "./public/mockups/fullsize/#{oMockupData.image}", dst: "./public/mockups/thumbnail/#{uuid}.png",
                width:500, height:350,
                x:0, y:0
            .then(
                ( image ) =>
                    Mockup
                        .create
                            uuid: uuid
                            title: oMockupData.name
                            image: uuid + '.png'
                            projectUuid: oMockupData.projectId
                        .catch ( oError ) ->
                            oSocket.emit "error.new", "We could not save your mockup to the server. Please try again later."
                            zouti.error oError, "MockupsController.save"
                        .then ( oSavedMockup ) =>
                            oSocket.notifications.generate "New design: #{oSavedMockup.title}", oSavedMockup.projectUuid, 'notification.mockup.new', false, oSocket.cosmosUserId

                            fs.readFile __dirname + "/../../public/mockups/thumbnail/#{ oSavedMockup.image }", ( err, buffer ) ->
                                if err
                                    oSocket.emit "error.new", "Could not get thumbnail for #{oSavedMockup.title}"
                                    return zouti.error err, "MockupsController.create"
                                oSavedMockup.image = buffer.toString "base64"
                                oSocket.broadcast.to(oSavedMockup.projectUuid).emit 'mockup.sent', oSavedMockup, 0

                            @countComments oSavedMockup, oSocket
                , ( err ) ->
                    console.error err

                setTimeout( () =>
                    fs.unlink "./public/mockups/fullsize/#{oMockupData.image}", (err) =>
                        if err then console.error err
                , 10000 )
            )

    delete: ( sMockupID, sProjectId, socket ) ->
        zouti.log "Deleting mockup #{ sMockupID }", "MockupsController", "RED"
        Mockup
            .destroy
                where:
                    uuid: sMockupID
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while deleting the mockup."
                zouti.error oError, "MockupsController.delete"
            .then ( oResult ) =>
                console.log 'emitting to project', sProjectId
                socket.broadcast.to(sProjectId).emit "mockup.removed", sMockupID
                console.log oResult

module.exports = MockupsController
