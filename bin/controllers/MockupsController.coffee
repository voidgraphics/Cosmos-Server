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

    getAll: ( callback ) ->
        Mockup
            .all()
            .catch ( oError ) -> zouti.error oError, "MockupsController.getAll"
            .then ( oData ) ->
                for mockup in oData
                    fs.readFile __dirname + "/../../public/img/#{ mockup.image }", ( error, buffer ) ->
                        if error
                            zouti.error error, "MockupsController.getAll"
                        mockup.imageEncoded = buffer.toString "base64"
                callback( oData )

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

    # For testing
    # items:
        # 'ec96a3ac-9d0a-4e10-9be3-a35aa9377212':
        #     id: 'ec96a3ac-9d0a-4e10-9be3-a35aa9377212'
        #     title: "Something to do"
        #     deadline: "2016-01-16"
        #     users: [ "user1", "user2" ]
        #     state: "todo"
        #     position: 1
        # 'c8b9e3f8-1590-4ecd-9ee5-4dbfd16e9edc':
        #     id: 'c8b9e3f8-1590-4ecd-9ee5-4dbfd16e9edc'
        #     title: "Something else to do"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "todo"
        #     position: 0
        # '9111e89b-02c2-40b5-859e-838d6ff0bf58':
        #     id: '9111e89b-02c2-40b5-859e-838d6ff0bf58'
        #     title: "Something in progress"
        #     deadline: "2015-12-03"
        #     users: [ "user1" ]
        #     state: "inprogress"
        #     position: 0
        # 'e2e7d06c-da03-428c-9a16-1975cbc3dd5f':
        #     id: 'e2e7d06c-da03-428c-9a16-1975cbc3dd5f'
        #     title: "Something finished"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "finished"
        #     position: 1
        # '67d1c4d5-cfa7-4ce0-84f7-cc628922fe71':
        #     id: '67d1c4d5-cfa7-4ce0-84f7-cc628922fe71'
        #     title: "Something else finished"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "finished"
        #     position: 0


module.exports = MockupsController
