###
    Cosmos-Server
    /bin/server.coffee ## Entry point
    Started Dec. 2, 2015
###

"use strict"

zouti = require "zouti"
zouti.clearConsole()
zouti.log "Starting server...", "server.coffee", "GREEN"

require "./core/sequelize.coffee"
require "./core/express.coffee"
