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
    constructor: () ->
        zouti.log "Mockups Controller initiating", "MockupsController", "GREEN"

    getThumb: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/thumbnail/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "mockup.error", "Could not get thumbnail for #{mockup.title}"
                return zouti.error err, "MockupsController.getThumb"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup, mockup.commentCount

    getImage: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/fullsize/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "mockup.error", "Could not get image for #{mockup.title}"
                return zouti.error err, "MockupsController.getImage"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup

    getAll: ( sProjectId, oSocket ) ->
        that = this
        Mockup
            .findAll
                where:
                    projectUuid: sProjectId
            .catch ( oError ) -> zouti.error oError, "MockupsController.getAll"
            .then ( oData ) ->
                for mockup in oData
                    that.countComments mockup, oSocket


    countComments: ( mockup, oSocket ) ->
        oSequelize.models.Comment.count
            where:
                mockupId: mockup.uuid
        .catch ( e ) -> console.error e
        .then ( count ) =>
            mockup.commentCount = count
            console.log mockup
            @getThumb mockup, oSocket

    get: ( sId, oSocket ) ->
        Mockup
            .find
                where:
                    id: sId
            .catch( ( oError ) -> zouti.error oError, "UserController.login" )
            .then( ( mockup ) =>
                @getImage mockup, oSocket
            )

    create: ( oMockupData, oSocket ) ->
        zouti.log "Adding task #{ oMockupData.name }", "MockupsController", "BLUE"
        matches = oMockupData.file.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)

        fs.writeFile "public/mockups/fullsize/#{oMockupData.image}", new Buffer(matches[2], "base64"), ( err ) ->
            if err then zouti.error err, "MockupsController.create"
            easyimg.thumbnail
                src: "./public/mockups/fullsize/#{oMockupData.image}", dst: "./public/mockups/thumbnail/#{oMockupData.image}",
                width:500, height:350,
                x:0, y:0
            .then(
                ( image ) =>
                    Mockup
                        .create
                            uuid: zouti.uuid()
                            title: oMockupData.name
                            image: oMockupData.image
                            projectUuid: oMockupData.projectId
                        .catch( ( oError ) -> zouti.error oError, "MockupsController.save" )
                        .then( ( oSavedMockup ) =>
                            @countComments oSavedMockup, oSocket
                        )
                , ( err ) ->
                    console.error err
            )


    update: ( sMockupID, oMockupData ) ->


    delete: ( sMockupID ) ->
        zouti.log "Deleting mockup #{ sMockupID }", "MockupsController", "RED"
        Mockup
            .destroy( {
                where: {
                    uuid: sMockupID
                }
            } )
            .catch( ( oError ) -> zouti.error oError, "MockupsController.delete" )

module.exports = MockupsController
