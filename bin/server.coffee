###
    Cosmos
    /bin/server.js ## Entry point
    Started Dec. 2, 2015
###

"use strict"

zouti = require "zouti"
zouti.clearConsole
zouti.log "Launching...", "cosmos:api", zouti.YELLOW
require "./core/express.coffee"
