###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"

class TasksController
    constructor: () ->
        zouti.log "Tasks Controller initiating", "cosmos:api:TasksController", "GREEN"

    save: ( oTask ) ->
        console.log "Saving:", oTask

module.exports = TasksController
