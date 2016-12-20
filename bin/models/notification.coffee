###
    Cosmos-Server
    /bin/models/notification.coffee ## Notification model
    Started Dec. 9, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
            primaryKey: true
        text:
            type: DataTypes.TEXT,
            field: "text"
        read:
            type: DataTypes.BOOLEAN
            field: "read"
            defaultValue: false

    oProperties =
        tablename: "notifications"

    return oSequelize.define "notifications", oColumns, oProperties
