###
    Cosmos-Server
    /bin/controllers/MockupsController.coffee ## Controller for mockups.
    Started Jan. 18, 2015
###

zouti = require "zouti"
fs = require "fs"
Mockup = require ( "../core/sequelize.coffee" )
Mockup = Mockup.models.Mockup

class MockupsController
    constructor: () ->
        zouti.log "Mockups Controller initiating", "MockupsController", "GREEN"

    getThumb: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/thumbnail/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "mockup.error", "Could not get thumbnail for #{mockup.title}"
                return zouti.error err, "MockupsController.getThumb"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup

    getImage: ( mockup, oSocket ) ->
        fs.readFile __dirname + "/../../public/mockups/fullsize/#{ mockup.image }", ( err, buffer ) ->
            if err
                oSocket.emit "mockup.error", "Could not get image for #{mockup.title}"
                return zouti.error err, "MockupsController.getImage"
            mockup.image = buffer.toString "base64"
            oSocket.emit "mockup.sent", mockup

    getAll: ( oSocket ) ->
        that = this
        Mockup
            .all()
            .catch ( oError ) -> zouti.error oError, "MockupsController.getAll"
            .then ( oData ) ->
                for mockup in oData
                    that.getThumb mockup, oSocket

    get: ( sId, oSocket ) ->
        Mockup
            .find
                where:
                    id: sId
            .catch( ( oError ) -> zouti.error oError, "UserController.login" )
            .then( ( mockup ) =>
                @getImage mockup, oSocket
            )

    save: ( oMockupData ) ->
        zouti.log "Adding task #{ oMockupData.title }", "MockupsController", "BLUE"
        Task
            .create( {
                uuid: oMockupData.id,
                title: oMockupData.title,
                deadline: oMockupData.deadline,
                state: oMockupData.state,
                position: oMockupData.position
            } )
            .catch( ( oError ) -> zouti.error oError, "MockupsController.save" )
            .then( ( oSavedMockup ) -> zouti.log "Saved mockup", oSavedMockup, "GREEN" )

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
