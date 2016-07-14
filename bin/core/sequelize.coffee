###
    Cosmos-Server
    /bin/core/sequelize.coffee ## Sequelize setup
    Started Dec. 2, 2015
###

"use strict"

Sequelize = require "sequelize"
exports.db = oSequelize = new Sequelize "cosmos", "root", "root", {
    host: "localhost",
    dialect: "mysql",
    logging: false
}

exports.models = oModels =
    Task:       oSequelize.import "../models/task.coffee"
    Mockup:     oSequelize.import "../models/mockup.coffee"
    User:       oSequelize.import "../models/user.coffee"
    Chat:       oSequelize.import "../models/chat.coffee"

# Relations
oModels.Chat.belongsTo( oModels.User, { foreignKey: 'user_id' } )
oModels.User.hasMany( oModels.Chat, { foreignKey: 'user_id' } )
