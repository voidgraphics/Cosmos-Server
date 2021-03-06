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


Task =          oSequelize.import "../models/task.coffee"
Mockup =         oSequelize.import "../models/mockup.coffee"
User =           oSequelize.import "../models/user.coffee"
Chat =           oSequelize.import "../models/chat.coffee"
Comment =        oSequelize.import "../models/comment.coffee"
Team =          oSequelize.import "../models/team.coffee"
Project =       oSequelize.import "../models/project.coffee"
Chatroom =      oSequelize.import "../models/chatroom.coffee"
Request =       oSequelize.import "../models/request.coffee"
Notification =  oSequelize.import "../models/notification.coffee"
Notice =        oSequelize.import "../models/notice.coffee"

# Relations
Chat.belongsTo( User, { foreignKey: 'user_id' } )
User.hasMany( Chat, { foreignKey: 'user_id' } )
Comment.belongsTo( User, { foreignKey: 'author_id' } )
Comment.belongsTo( Mockup, { foreignKey: 'mockup_id' } )
Mockup.hasMany( Comment, { foreignKey: 'mockup_id' } )
User.belongsToMany( Team, { through: "users_teams" } )
Team.belongsToMany( User, { through: "users_teams" } )
Task.belongsToMany( User, { through: "users_tasks" } )
User.belongsToMany( Task, { through: "users_tasks" } )
Chatroom.hasMany( Chat )
Project.hasMany( Chatroom )
Team.hasMany( Project )
Project.belongsTo( Team )
Project.hasMany( Chat )
Project.hasMany( Task )
Project.hasMany( Mockup )
Team.hasMany( Request )
User.hasMany( Request )
Request.belongsTo( User, { foreignKey: 'user_id' } )
Request.belongsTo( Team, { foreignKey: 'team_id' } )
User.hasMany( Notification )
Notification.belongsTo( User, { foreignKey: 'userUuid' } )
Notification.belongsTo( Project, { foreignKey: 'projectUuid' } )
Notice.belongsTo( Team, { foreignKey: 'teamUuid' } )

# Models
oSequelize.models = oModels =
    Task:       Task
    Mockup:     Mockup
    User:       User
    Chat:       Chat
    Comment:    Comment
    Team:       Team
    Project:    Project
    Chatroom:   Chatroom
    Request:    Request
    Notification: Notification
    Notice:     Notice

oSequelize
    .sync({ force: false })
    .catch ( oError ) -> console.error oError
    .then () ->
        console.log 'Synced database'

module.exports = oSequelize
