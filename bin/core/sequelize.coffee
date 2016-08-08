###
    Cosmos-Server
    /bin/core/sequelize.coffee ## Sequelize setup
    Started Dec. 2, 2015
###

"use strict"

Sequelize = require "sequelize"

# Database
oSequelize = new Sequelize "cosmos", "root", "root", {
    host: "localhost",
    dialect: "mysql",
    logging: false
}


Task =      oSequelize.import "../models/task.coffee"
Mockup =     oSequelize.import "../models/mockup.coffee"
User =       oSequelize.import "../models/user.coffee"
Chat =       oSequelize.import "../models/chat.coffee"
Comment =    oSequelize.import "../models/comment.coffee"
Team =       oSequelize.import "../models/team.coffee"

# Relations
Chat.belongsTo( User, { foreignKey: 'user_id' } )
User.hasMany( Chat, { foreignKey: 'user_id' } )
Comment.belongsTo( Mockup, { foreignKey: 'mockup_id' } )
User.belongsToMany( Team, { through: "users_teams" } )
Team.belongsToMany( User, { through: "users_teams" } )

# Models
oSequelize.models = oModels =
    Task:       Task
    Mockup:     Mockup
    User:       User
    Chat:       Chat
    Comment:    Comment
    Team:       Team

oSequelize
    .sync()
    .catch ( oError ) -> console.error oError
    .then () ->
        console.log 'Synced database'

module.exports = oSequelize
