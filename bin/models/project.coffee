###
    Cosmos-Server
    /bin/models/project.coffee ## Projects model
    Started Aug. 9, 2016
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
        tablename: "projects",
        paranoid: true

    return oSequelize.define "projects", oColumns, oProperties
