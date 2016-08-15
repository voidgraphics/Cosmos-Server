###
    Cosmos-Server
    /bin/controllers/ProjectsController.coffee ## Controller for projects.
    Started Aug. 15, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Project = Sequelize.models.Project

class ProjectsController
    constructor: () ->
        zouti.log "Projects Controller initiating", "ProjectsController", "GREEN"

    create: ( oProject, callback ) ->
        Project
            .create
                uuid: oProject.uuid
                name: oProject.name
                teamUuid: oProject.teamId
            .catch ( oError ) -> zouti.error oError, "ProjectsController.create"
            .then ( oSavedProject ) ->
                zouti.log "Created project", oSavedProject, "GREEN"
                callback oSavedProject

module.exports = ProjectsController
