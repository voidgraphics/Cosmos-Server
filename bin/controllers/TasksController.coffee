###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"

class TasksController
    constructor: () ->

    init: ->
        zouti.log "Tasks Controller initiating", "cosmos:api:TasksController", "GREEN"

    test: ( oTask ) ->
        console.log oTask

module.exports = TasksController
