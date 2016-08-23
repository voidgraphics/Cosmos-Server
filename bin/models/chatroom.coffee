###
    Cosmos-Server
    /bin/models/chatroom.coffee ## Chatrooms model
    Started Aug. 16, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
            primaryKey: true
        name:
            type: DataTypes.STRING,
            field: "name"

    oProperties =
        tablename: "chatrooms",
        paranoid: true

    return oSequelize.define "chatrooms", oColumns, oProperties
