###
    Cosmos-Server
    /bin/models/team.coffee ## Team model
    Started Aug. 7, 2016
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
        tablename: "teams",
        paranoid: true,
        instanceMethods:
            fetchProjects: ( callback ) ->
                this.getProjects()
                    .catch ( oError ) -> zouti.error oError, "UserController.login (team.getProjects)"
                    .then ( aProjects ) =>
                        callback this.name, aProjects

    return oSequelize.define "teams", oColumns, oProperties
