###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Task = Sequelize.models.Task

class TasksController
    constructor: () ->
        zouti.log "Tasks Controller initiating", "TasksController", "GREEN"

    getAll: ( sProjectId, callback ) ->
        Task
            .findAll
                where:
                    projectUuid: sProjectId
            .catch( ( oError ) -> zouti.error oError, "TasksController.getAll" )
            .then( ( oData ) -> callback( oData ) )
        # callback( @items )

    getRecent: ( callback ) ->
        zouti.log "Getting recent tasks", "TasksController.getRecent", "GREEN"
        aTasks = []
        Task
            .findAll( {
                where: { state: "todo" },
                order: [ [ "createdAt", "DESC" ] ],
                limit: 2
            } )
            .catch ( oError ) -> zouti.error oError, "TasksController.getRecent"
            .then ( aReturnedTodoTasks ) -> [].push.apply aTasks, aReturnedTodoTasks
        Task
            .findAll( {
                where: { state: "inprogress" },
                order: [ [ "createdAt", "DESC" ] ],
                limit: 2
            } )
            .catch ( oError ) -> zouti.error oError, "TasksController.getRecent"
            .then ( aReturnedInProgressTasks ) -> [].push.apply aTasks, aReturnedInProgressTasks
        Task
            .findAll( {
                where: { state: "finished" },
                order: [ [ "createdAt", "DESC" ] ],
                limit: 2
            } )
            .catch ( oError ) -> zouti.error oError, "TasksController.getRecent"
            .then ( aReturnedFinishedTasks ) ->
                [].push.apply aTasks, aReturnedFinishedTasks
                callback( aTasks )


    save: ( oTaskData ) ->
        zouti.log "Adding task #{ oTaskData.title }", "TasksController", "BLUE"
        Task
            .create( {
                uuid: oTaskData.id,
                title: oTaskData.title,
                deadline: oTaskData.deadline,
                state: oTaskData.state,
                position: oTaskData.position
                projectUuid: oTaskData.projectId
            } )
            .catch( ( oError ) -> zouti.error oError, "TasksController.save" )
            .then( ( oSavedTask ) -> zouti.log "Saved task", oSavedTask, "GREEN" )

    saveAll: ( aTasks ) ->
        for task in aTasks
            Task.update( {
                title: task.title,
                deadline: task.deadline,
                state: task.state,
                position: task.position
            }, {
                where: {
                    uuid: task.id
                }
            } )
        zouti.log "Saving tasks", "TasksController.saveAll", "GREEN"

    update: ( iTaskID, oTaskData ) ->
        @items[ iTaskID ] = oTaskData

    delete: ( sTaskID ) ->
        zouti.log "Deleting task #{ sTaskID }", "TasksController", "RED"
        Task
            .destroy( {
                where: {
                    uuid: sTaskID
                }
            } )
            .catch( ( oError ) -> zouti.error oError, "TasksController.delete" )


module.exports = TasksController
