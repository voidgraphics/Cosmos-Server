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

    getAll: ( callback ) ->
        Task
            .all()
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
        delete @items[ sTaskID ]

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


module.exports = TasksController
