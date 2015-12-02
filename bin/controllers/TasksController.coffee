zouti = require "zouti"

class TasksController
    constructor: () ->

    init: ->
        zouti.log "Tasks Controller initiating", "cosmos:api:TasksController", "GREEN"

    test: ( oTask ) ->
        console.log oTask

module.exports = TasksController
