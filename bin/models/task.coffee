###
    Cosmos-Server
    /bin/models/task.coffee ## Task model
    Started Jan. 18, 2016
###

module.exports = ( oSequelize, DataTypes ) ->
    oColumns =
        uuid:
            type: DataTypes.UUID,
            field: "id",
            unique: true
            primaryKey: true
        title:
            type: DataTypes.STRING,
            field: "title"
        deadline:
            type: DataTypes.DATEONLY,
            field: "deadline"
        state:
            type: DataTypes.STRING
            field: "state"
        position:
            type: DataTypes.INTEGER
            field: "position"
        tag:
            type: DataTypes.INTEGER
            field: "tag"

    oProperties =
        tableName: "tasks",
        paranoid: false

    return oSequelize.define "tasks", oColumns, oProperties
