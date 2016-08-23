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
                include:
                    model: Sequelize.models.User
                    attributes: [ 'id' ]
            .catch ( oError ) -> zouti.error oError, "TasksController.getAll"
            .then ( aTasks ) ->
                callback( aTasks )

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
            .create
                uuid: oTaskData.uuid,
                title: oTaskData.title,
                deadline: oTaskData.deadline,
                state: oTaskData.state,
                position: oTaskData.position
                projectUuid: oTaskData.projectId
            .catch ( oError ) -> zouti.error oError, "TasksController.save"
            .then ( oSavedTask ) ->
                zouti.log "Saved task", oSavedTask, "GREEN"
                oSavedTask.addUsers oTaskData.users

    saveAll: ( aTasks ) ->
        for task in aTasks
            Task.update( {
                title: task.title,
                deadline: task.deadline,
                state: task.state,
                position: task.position
            }, {
                where: {
                    uuid: task.uuid
                }
            } )
        zouti.log "Saving tasks", "TasksController.saveAll", "GREEN"

    update: ( oTask ) ->
        Task
            .update( {
                title: oTask.title
                deadline: oTask.deadline
                state: oTask.state
                position: oTask.position
            },
            where:
                uuid: oTask.uuid
            )
            .catch ( oError ) -> zouti.error oError, "TasksController.update"
            .then () ->
                zouti.log "Updated task", "GREEN"
                Task
                    .find
                        where:
                            uuid: oTask.uuid
                    .catch ( oError ) -> zouti.error oError, "TasksController.update"
                    .then ( oResult ) ->
                        oResult.setUsers oTask.users


    delete: ( sTaskID ) ->
        zouti.log "Deleting task #{ sTaskID }", "TasksController", "RED"
        Task
            .destroy
                where:
                    uuid: sTaskID

            .catch( ( oError ) -> zouti.error oError, "TasksController.delete" )


module.exports = TasksController
