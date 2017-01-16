###
    Cosmos-Server
    /bin/controllers/ProjectsController.coffee ## Controller for projects.
    Started Aug. 15, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Project = Sequelize.models.Project

class ProjectsController
    constructor: ( io ) ->
        @io = io

    create: ( oProject, socket, callback ) ->
        Project
            .create
                uuid: oProject.uuid
                name: oProject.name
                teamUuid: oProject.teamId
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while creating the project."
                zouti.error oError, "ProjectsController.create"
            .then ( oSavedProject ) =>
                zouti.log "Created project", oSavedProject, "GREEN"
                oSavedProject
                    .getTeam()
                    .catch ( oError ) ->
                        zouti.error oError, 'ProjectsController.create'
                    .then ( oTeam ) =>
                        @io.to( oSavedProject.teamUuid ).emit 'notification.flash', oTeam.name, 'New project created: ' + oSavedProject.name

                oSavedProject
                    .createChatroom
                        uuid: zouti.uuid()
                        name: "General"
                    .catch ( oError ) ->
                        socket.emit "error.new", "There was an error while creating the project's default chatroom."
                        zouti.error oError, "ProjectsController.create (addChatroom)"
                    .then ( oSavedChatroom ) ->
                        zouti.log "Created General chatroom", oSavedChatroom, "GREEN"
                        socket.broadcast.to(oSavedProject.teamUuid).emit "project.new", oSavedProject
                        callback oSavedProject


module.exports = ProjectsController
