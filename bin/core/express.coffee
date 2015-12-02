###
    Cosmos-Server
    /bin/core/express.coffee ## Express setup
    Started Dec. 2, 2015
###

"use strict"

oApp = require( "express" )()
server = require( "http" ).Server( oApp )
io = require( "socket.io" )( server )
zouti = require "zouti"

# Configure routes
Routes = new ( require "../routes/Routes.coffee" )

# Init socket.io
io.on "connection", ( socket ) =>
    zouti.log "A user connected", "cosmos:api", "GREEN"

    Routes.init( socket )

# Listen
server.listen 12345
