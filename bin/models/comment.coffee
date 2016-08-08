###
    Cosmos-Server
    /bin/models/comment.coffee ## Comment model
    Started Aug. 6, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
        authorId:
            type: DataTypes.UUID,
            field: "author_id"
        mockupId:
            type: DataTypes.UUID,
            field: "mockup_id"
        text:
            type: DataTypes.UUID,
            field: "text"
        x:
            type: DataTypes.FLOAT
            field: "x"
        y:
            type: DataTypes.FLOAT
            field: "y"

    oProperties =
        tablename: "comments",
        paranoid: true

    return oSequelize.define "comments", oColumns, oProperties
