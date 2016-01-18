###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"
Task = require ( "../core/sequelize.coffee" )
Task = Task.models.Task

class TasksController
    constructor: () ->
        zouti.log "Tasks Controller initiating", "TasksController", "GREEN"

    get: ( iTaskID ) ->
        console.log "Returning task:", iTaskID

    getAll: ( callback ) ->
        callback( @items )

    save: ( oTaskData ) ->
        iTaskID = oTaskData.id
        zouti.log "Adding task #{ oTaskData.title }", "TasksController", "BLUE"
        @items[ iTaskID ] = oTaskData

    saveAll: ( aTasks ) ->
        @items = aTasks

    update: ( iTaskID, oTaskData ) ->
        @items[ iTaskID ] = oTaskData

    changeState: ( iTaskID, sNewState ) ->
        @items[ iTaskID ].state = sNewState
        console.log @items[ iTaskID ]

    delete: ( iTaskID ) ->
        zouti.log "Deleting task #{ iTaskID }", "TasksController", "RED"
        delete @items[iTaskID]

    # For testing
    items: {}
        # 0:
        #     id: 0
        #     title: "Something to do"
        #     deadline: "2016-01-16"
        #     users: [ "user1", "user2" ]
        #     state: "todo"
        #     position: 1
        # 1:
        #     id: 1
        #     title: "Something else to do"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "todo"
        #     position: 0
        # 2:
        #     id: 2
        #     title: "Something in progress"
        #     deadline: "2015-12-03"
        #     users: [ "user1" ]
        #     state: "inprogress"
        #     position: 0
        # 3:
        #     id: 3
        #     title: "Something finished"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "finished"
        #     position: 1
        # 4:
        #     id: 4
        #     title: "Something else finished"
        #     deadline: "2016-01-18"
        #     users: [ "user3", "user4" ]
        #     state: "finished"
        #     position: 0


module.exports = TasksController
