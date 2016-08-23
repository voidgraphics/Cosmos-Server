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

    oProperties =
        tableName: "tasks",
        paranoid: true

    return oSequelize.define "tasks", oColumns, oProperties
