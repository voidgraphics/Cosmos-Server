###
    Cosmos-Server
    /bin/models/user.coffee ## User model
    Started May 10, 2016
###

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
        password:
            type: DataTypes.STRING
            allowNull: false
            field: "password"
        avatar:
            type: DataTypes.STRING
            field: "avatar"
        settings:
            type: DataTypes.TEXT
            field: "settings"

    oProperties =
        tableName: "users"
        paranoid: true

    UserModel = oSequelize.define "users", oColumns, oProperties
    return UserModel
