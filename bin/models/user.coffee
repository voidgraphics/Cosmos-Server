###
    Cosmos-Server
    /bin/models/user.coffee ## User model
    Started May 10, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
        username:
            type: DataTypes.STRING,
            field: "username"
        firstname:
            type: DataTypes.STRING,
            field: "firstname"
        lastname:
            type: DataTypes.STRING,
            field: "lastname"

    oProperties =
        tableName: "users",
        paranoid: true

    return oSequelize.define "users", oColumns, oProperties
