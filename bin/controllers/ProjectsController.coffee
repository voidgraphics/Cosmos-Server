###
    Cosmos-Server
    /bin/controllers/ProjectsController.coffee ## Controller for projects.
    Started Aug. 15, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Project = Sequelize.models.Project

class ProjectsController
    create: ( oProject, socket, callback ) ->
        Project
            .create
                uuid: oProject.uuid
                name: oProject.name
                teamUuid: oProject.teamId
            .catch ( oError ) ->
                socket.emit "error.new", "There was an error while creating the project."
                zouti.error oError, "ProjectsController.create"
            .then ( oSavedProject ) ->
                zouti.log "Created project", oSavedProject, "GREEN"

                oSavedProject
                    .createChatroom
                        uuid: zouti.uuid()
                        name: "General"
                    .catch ( oError ) ->
                        socket.emit "error.new", "There was an error while creating the project's default chatroom."
                        zouti.error oError, "ProjectsController.create (addChatroom)"
                    .then ( oSavedChatroom ) ->
                        zouti.log "Created General chatroom", oSavedChatroom, "GREEN"
                        callback oSavedProject


module.exports = ProjectsController
