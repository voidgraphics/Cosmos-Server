###
    Cosmos-Server
    /bin/core/sequelize.coffee ## Sequelize setup
    Started Dec. 2, 2015
###

"use strict"

Sequelize = require "sequelize"
exports.db = oSequelize = new Sequelize "cosmos", "root", "root", {
    host: "localhost",
    dialect: "mysql"
}

exports.models = oModels =
    Task: oSequelize.import "../models/task.coffee"
