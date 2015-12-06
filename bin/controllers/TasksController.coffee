###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"

class TasksController
    constructor: () ->
        zouti.log "Tasks Controller initiating", "TasksController", "GREEN"

    get: ( iTaskID ) ->
        console.log "Returning task:", iTaskID

    getAll: ( callback ) ->
        callback( @items )

    save: ( oTaskData ) ->
        iTaskID = Object.keys( @items ).length + 1
        @items[iTaskID] = oTaskData

    update: ( iTaskID, oTaskData ) ->
        @items[ iTaskID ] = oTaskData

    delete: ( iTaskID ) ->
        zouti.log "Deleting task #{ iTaskID }", "TasksController", "RED"
        delete @items[ iTaskID ]

    # For testing
    items:
        0:
            title: "Something to do"
            deadline: "2016-01-16"
            users: [ "user1", "user2" ]
            state: "todo"
        1:
            title: "Something else to do"
            deadline: "2016-01-18"
            users: [ "user3", "user4" ]
            state: "todo"
        2:
            title: "Something in progress"
            deadline: "2015-12-03"
            users: [ "user1" ]
            state: "inprogress"
        3:
            title: "Something finished"
            deadline: "2016-01-18"
            users: [ "user3", "user4" ]
            state: "finished"
        3:
            title: "Something else finished"
            deadline: "2016-01-18"
            users: [ "user3", "user4" ]
            state: "finished"


module.exports = TasksController
