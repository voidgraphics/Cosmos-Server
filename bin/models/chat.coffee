###
    Cosmos-Server
    /bin/models/chat.coffee ## Chat model
    Started May 10, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
        userId:
            type: DataTypes.UUID,
            field: "user_id"
        text:
            type: DataTypes.STRING,
            field: "text"

    oProperties =
        tableName: "messages",
        paranoid: true

    return oSequelize.define "chat", oColumns, oProperties
