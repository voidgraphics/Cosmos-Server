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

    getAll: ( sProjectId, socket, callback ) ->
        Task
            .findAll
                where:
                    projectUuid: sProjectId
                include:
                    model: Sequelize.models.User
                    attributes: [ 'id', 'username', 'firstname', 'lastname' ]
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while fetching the tasks."
                zouti.error oError, "TasksController.getAll"
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
                .catch ( oError ) ->
                    zouti.error oError "TasksController.save"
                    socket.emit "error.new", "There was an error while assigning users to the task."
                .then () =>
                    Task
                        .find
                            where:
                                uuid: oSavedTask.uuid
                            include:
                                model: Sequelize.models.User
                        .catch ( oError ) -> zouti.error oError, "TasksController.save"
                        .then ( oTask ) =>
                            socket.emit 'task.created', oTask
                            socket.broadcast.to(oTaskData.projectId).emit "task.created", oTask
                            socket.notifications.generate "You were assigned to task \"#{oTaskData.title}\"", oTaskData.projectId, 'notification.task.created', oTaskData.users, socket.cosmosUserId

    saveAll: ( aTasks, socket ) ->
        for task in aTasks
            @editTask task, socket

    handleMoveNotification: ( oTask, oSocket ) ->
        location = ""
        if oTask.state == "todo" then location = "To do"
        if oTask.state == "inprogress" then location = "In progress"
        if oTask.state == "finished" then location = "Completed"

        aUsers = []
        for user in oTask.users
            id = if typeof user == 'string' then id = user else ( user.id || user.uuid )
            aUsers.push id

        oSocket.notifications.generate "Task \"#{oTask.title}\" was moved to \"#{location}\"", ( oTask.projectUuid || oTask.projectId ), 'notification.task.moved', aUsers, oSocket.cosmosUserId

    editTask: ( oTask, socket ) ->
        Task.update( {
            title: oTask.title,
            deadline: oTask.deadline,
            tag: oTask.tag,
            state: oTask.state,
            position: oTask.position
        }, {
            where: {
                uuid: oTask.uuid
            }
        } )
        .catch ( oError ) ->
            socket.emit "error.new", "There was an error while updating the task."
            zouti.error oError, "TasksController.saveAll"
        .then ( affectedRows ) =>
            @sendUpdatedTask oTask, socket

    sendUpdatedTask: ( oTask, socket ) ->
        socket.broadcast.to(oTask.projectId || oTask.projectUuid).emit "task.updated", oTask

    update: ( oTask, socket ) ->
        Task
            .update( {
                title: oTask.title
                deadline: oTask.deadline
                state: oTask.state
                tag: oTask.tag
                position: oTask.position
            },
            where:
                uuid: oTask.uuid
            )
            .catch ( oError ) ->
                socket.emit "error.new", "Error while updating the task."
                zouti.error oError, "TasksController.update:update"
            .then () ->
                zouti.log "Updated task", "GREEN"
                Task
                    .find
                        where:
                            uuid: oTask.uuid
                    .catch ( oError ) -> zouti.error oError, "TasksController.update:find"
                    .then ( oResult ) ->
                        oResult.setUsers oTask.users
                        .catch ( oError ) -> zouti.error oError, 'TasksController.update:setUsers'
                        .then ( ) ->
                            Task
                                .find
                                    where:
                                        uuid: oTask.uuid
                                    include: Sequelize.models.User
                                .catch ( oError ) -> zouti.error oError, 'TasksController.update:find2'
                                .then ( oTask ) ->
                                    aUsers = []
                                    for user in oTask.users
                                        id = if typeof user == 'string' then id = user else ( user.id || user.uuid )
                                        aUsers.push id
                                    socket.notifications.generate "Update to task: #{oTask.title}", ( oTask.projectUuid || oTask.projectId ), 'notification.task.edited', aUsers, socket.cosmosUserId
                                    socket.broadcast.to(oTask.projectId || oTask.projectUuid).emit "task.updated", oTask


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
