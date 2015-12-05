###
    Cosmos-Server
    /bin/core/express.coffee ## Express setup
    Started Dec. 2, 2015
###

"use strict"

express = require( "express" )()
server = require( "http" ).Server( express )
io = require( "socket.io" )( server )
zouti = require "zouti"
App = new ( require "../core/App.coffee" )

# Init socket.io
io.on "connection", ( oSocket ) =>
    zouti.log "A user connected", "bin/core/express.coffee", "GREEN"
    
    App.init( oSocket )

# Listen
server.listen 12345
