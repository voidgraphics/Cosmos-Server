###
    Cosmos-Server
    /bin/controllers/NotificationsController.coffee ## Controller for notifications.
    Started Aug. 6, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Project = Sequelize.models.Project
Notification = Sequelize.models.Notification

class NotificationsController
    generate: ( sNotificationText, sProjectId, sNotificationType, aUsersToNotify = null ) ->
        console.log "Project id", sProjectId
        console.log "Notification type", sNotificationType
        console.log "Users", aUsersToNotify
        Project
            .find
                where:
                    id: sProjectId
                include:
                    model: Sequelize.models.Team
            .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
            .then ( oProject ) =>
                if aUsersToNotify
                    for sUserId in aUsersToNotify
                        @create sNotificationText, sProjectId, oProject.name, sNotificationType, sUserId
                else
                    oProject.team.getUsers()
                    .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
                    .then ( aUsers ) =>
                        for oUser in aUsers
                            @create sNotificationText, sProjectId, oProject.name, sNotificationType, oUser.uuid

    create: ( sNotificationText, sProjectId, sProjectName, sNotificationType, sUserId ) ->
        Notification
            .create
                uuid: zouti.uuid()
                userUuid: sUserId
                projectUuid: sProjectId
                text: sNotificationText
            .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
            .then ( oSavedNotification ) =>
                if sUserId of App.users
                    o =
                        id: oSavedNotification.uuid
                        text: oSavedNotification.text
                        project:
                            id: sProjectId
                            name: sProjectName
                        date: oSavedNotification.createdAt
                    App.users[sUserId].emit sNotificationType, o

    fetch: ( sUserId, callback ) ->
        Notification
            .findAll
                where:
                    userUuid: sUserId
                limit: 5
                order: 'createdAt DESC'

                include:
                    model: Sequelize.models.Project

            .catch ( oError ) -> zouti.error oError, "NotificationsController.fetch"
            .then ( aNotifications ) ->
                callback aNotifications

    read: ( sNotificationId ) ->
        Notification
            .update({
                read: true
            },
            where: {
                uuid: sNotificationId
            })
            .catch ( oError ) -> zouti.error oError, "NotificationsController.read"




module.exports = NotificationsController
