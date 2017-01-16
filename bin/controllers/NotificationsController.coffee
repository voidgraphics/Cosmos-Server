###
    Cosmos-Server
    /bin/controllers/NotificationsController.coffee ## Controller for notifications.
    Started Aug. 6, 2016
###

zouti = require "zouti"
Sequelize = require ( "../core/sequelize.coffee" )
Project = Sequelize.models.Project
Notification = Sequelize.models.Notification
Notice = Sequelize.models.Notice

class NotificationsController
    constructor: ( io ) ->
        @io = io

    generate: ( sNotificationText, sProjectId, sNotificationType, aUsersToNotify = null, sUserToIgnore = null ) ->
        Project
            .find
                where:
                    id: sProjectId
                include:
                    model: Sequelize.models.Team
            .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
            .then ( oProject ) =>
                console.log sNotificationType
                if aUsersToNotify
                    for sUserId in aUsersToNotify
                        if sUserId != sUserToIgnore
                            @create sNotificationText, sProjectId, oProject.name, sNotificationType, sUserId
                else
                    oProject.team.getUsers()
                    .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
                    .then ( aUsers ) =>
                        for oUser in aUsers
                            if oUser.uuid != sUserToIgnore
                                @create sNotificationText, sProjectId, oProject.name, sNotificationType, oUser.uuid


    notice: ( sNoticeText, sTeamId, sNoticeType, aUsersToNotify = null, sUserToIgnore = null ) ->
        Notice
            .create
                uuid: zouti.uuid()
                text: sNoticeText
                teamUuid: sTeamId
            .catch ( oError ) -> zouti.error oError, 'NotificationsController.notice'
            .then ( oNotice ) =>
                console.log 'emitting ' + sNoticeType + ' to team ' + sTeamId
                @io.of( sTeamId ).emit sNoticeType, oNotice

    create: ( sNotificationText, sProjectId, sProjectName, sNotificationType, sUserId ) ->
        Notification
            .create
                uuid: zouti.uuid()
                userUuid: sUserId
                projectUuid: sProjectId
                text: sNotificationText
            .catch ( oError ) -> zouti.error oError, "NotificationsController.generate"
            .then ( oSavedNotification ) =>
                # if sUserId of @io.users
                o =
                    id: oSavedNotification.uuid
                    text: oSavedNotification.text
                    project:
                        id: sProjectId
                        name: sProjectName
                    date: oSavedNotification.createdAt
                console.log 'pushing notification to socket ' + sUserId
                @io.to( sUserId ).emit sNotificationType, o

    fetch: ( sUserId, callback ) ->
        Notification
            .findAll
                where:
                    userUuid: sUserId
                    read: false
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
