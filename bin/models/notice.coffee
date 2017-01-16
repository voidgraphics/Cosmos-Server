###
    Cosmos-Server
    /bin/models/notice.coffee ## Notice model
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
        tablename: "notices"

    return oSequelize.define "notices", oColumns, oProperties
