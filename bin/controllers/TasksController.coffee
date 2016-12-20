###
    Cosmos-Server
    /bin/controllers/TasksController.coffee ## Controller for tasks.
    Started Dec. 2, 2015
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Task = Sequelize.models.Task

class TasksController
    constructor: ( io ) ->
        @io = io

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

    save: ( oTaskData, socket ) ->
        zouti.log "Adding task #{ oTaskData.title }", "TasksController", "BLUE"
        Task
            .create
                uuid: oTaskData.uuid,
                title: oTaskData.title,
                deadline: oTaskData.deadline,
                state: oTaskData.state,
                position: oTaskData.position
                projectUuid: oTaskData.projectId
                tag: oTaskData.tag
            .catch ( oError ) ->
                socket.emit "error.new", "We could not save your task. Please try again later."
                zouti.error oError, "TasksController.save"
            .then ( oSavedTask ) =>
                zouti.log "Saved task", oSavedTask, "GREEN"
                oSavedTask.addUsers oTaskData.users
                .catch ( oError ) -> zouti.error oError "TasksController.save"
                .then () =>
                    Task
                        .find
                            where:
                                uuid: oSavedTask.uuid
                            include:
                                model: Sequelize.models.User
                        .catch ( oError ) -> zouti.error oError, "TasksController.save"
                        .then ( oTask ) =>
                            App.NotificationsController.generate "You were assigned to task \"#{oTaskData.title}\"", oTaskData.projectId, 'notification.task.created', oTaskData.users
                            socket.broadcast.to(oTaskData.projectId).emit "task.created", oTask

    saveAll: ( aTasks, socket ) ->
        for task in aTasks
            @moveTask task, socket

    handleMoveNotification: ( oTask ) ->
        location = ""
        if oTask.state == "todo" then location = "To do"
        if oTask.state == "inprogress" then location = "In progr ess"
        if oTask.state == "finished" then location = "Completed"

        aUsers = []
        for user in oTask.users
            aUsers.push user.id

        App.NotificationsController.generate "Task \"#{oTask.title}\" was moved to \"#{location}\"", oTask.projectUuid, 'notification.task.moved', aUsers

    moveTask: ( oTask, socket ) ->
        Task.update( {
            title: oTask.title,
            deadline: oTask.deadline,
            state: oTask.state,
            position: oTask.position
        }, {
            where: {
                uuid: oTask.uuid
            }
        } )
        .catch ( oError ) ->
            socket.emit "error.new", "There was an error while moving the task."
            zouti.error oError, "TasksController.saveAll"
        .then ( affectedRows ) =>
            @sendUpdatedTask oTask, socket

    sendUpdatedTask: ( oTask, socket ) ->
        socket.broadcast.to(oTask.projectUuid).emit "task.updated", oTask

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
            .catch ( oError ) ->
                socket.emit "error.new", "Error while updating the task."
                zouti.error oError, "TasksController.update"
            .then () ->
                zouti.log "Updated task", "GREEN"
                Task
                    .find
                        where:
                            uuid: oTask.uuid
                    .catch ( oError ) -> zouti.error oError, "TasksController.update"
                    .then ( oResult ) ->
                        oResult.setUsers oTask.users


    delete: ( sTaskID, socket, sProjectId ) ->
        zouti.log "Deleting task #{ sTaskID }", "TasksController", "RED"
        Task
            .destroy
                where:
                    uuid: sTaskID

            .catch( ( oError ) ->
                socket.emit "error.new", "There was an error while deleting the task."
                zouti.error oError, "TasksController.delete" )
            .then () =>
                socket.broadcast.to(sProjectId).emit "task.removed", sTaskID


module.exports = TasksController
