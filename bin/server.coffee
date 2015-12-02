###
    Cosmos-Server
    /bin/server.js ## Entry point
    Started Dec. 2, 2015
###

"use strict"

zouti = require "zouti"
zouti.clearConsole()
zouti.log "Starting server...", "cosmos:api", zouti.YELLOW

require "./core/sequelize.coffee"
require "./core/express.coffee"
