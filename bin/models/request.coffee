###
    Cosmos-Server
    /bin/models/request.coffee ## Request model
    Started Aug. 21, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
            primaryKey: true
        userUuid:
            type: DataTypes.UUID,
            field: "user_id"
        teamUuid:
            type: DataTypes.UUID,
            field: "team_id"

    oProperties =
        tablename: "requests",
        paranoid: true,

    return oSequelize.define "requests", oColumns, oProperties
