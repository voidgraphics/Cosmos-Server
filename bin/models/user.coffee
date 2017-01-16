###
    Cosmos-Server
    /bin/models/user.coffee ## User model
    Started May 10, 2016
###

fs = require 'fs'

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID
            field: "id"
            allowNull: false
            unique: true
            primaryKey: true
        username:
            type: DataTypes.STRING
            field: "username"
            allowNull: false
            unique: true
        firstname:
            type: DataTypes.STRING
            field: "firstname"
        lastname:
            type: DataTypes.STRING
            field: "lastname"
        email:
            type: DataTypes.STRING
            field: "email"
        password:
            type: DataTypes.STRING
            allowNull: false
            field: "password"
        avatar:
            type: DataTypes.STRING
            field: "avatar"
        settings:
            type: DataTypes.STRING 12345
            field: "settings"
            defaultValue: '{"notifications":{"tasksAssigned":true,"tasksMoved":true,"tasksEdited":true,"newComment":true,"newRequest":true,"newMessage":true,"newTargetedMessage":true,"newChatroom":true,"newMockup":true},"usability":{"theme":"light","hasSchedule":false,"isColorblind":true}}'
        pwRequestId:
            type: DataTypes.UUID
            field: 'pwRequestId'

    oProperties =
        tableName: "users"
        paranoid: true

    UserModel = oSequelize.define "users", oColumns, oProperties
    return UserModel
