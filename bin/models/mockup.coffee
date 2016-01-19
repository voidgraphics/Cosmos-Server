###
    Cosmos-Server
    /bin/models/mockup.coffee ## Mockup model
    Started Jan. 18, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
        title:
            type: DataTypes.STRING,
            field: "title"
        image:
            type: DataTypes.STRING,
            field: "image"

    oProperties =
        tablename: "mockups",
        paranoid: true

    return oSequelize.define "mockups", oColumns, oProperties
