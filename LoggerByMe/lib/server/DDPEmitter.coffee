
Observatory = @Observatory ? {}

class Observatory.DDPEmitter extends @Observatory.MessageEmitter
  @messageStub: ->
    options =
      isServer: true
      severity: Observatory.LOGLEVEL.DEBUG
      module: "DDP"
      timestamp: new Date
    options

  @_instance: undefined

  # getter for the instance
  @de: => 
    @_instance?= new Observatory.DDPEmitter "DDP Emitter"
    @_instance

  constructor: (@name, @formatter)->
    #console.log "DDPEmitter::constructor #{name}"
    super @name, @formatter
    @turnOff()
    if Observatory.DDPEmitter._instance? then throw new Error "Attempted to create another instance of DDPEmitter and it is a really bad idea"
    # registering to listen to socket events with Meteor
    Meteor.default_server.stream_server.register (socket)->
      return unless Observatory.DDPEmitter.de().isOn
      #console.log socket._session.connection
      msg = Observatory.DDPEmitter.messageStub()
      msg.socketId = socket.id
      msg.textMessage = "Connected socket #{socket.id}" 
      # emitting message and putting to the buffer for the sake of Meteor logging. Insensitive loggers, such as Console,
      # should actually ignore this
      #console.log msg
      Observatory.DDPEmitter.de().emitMessage msg, true

      socket.on 'data', (raw_msg)->
        #console.log @_session.connection._meteorSession.id
        return unless Observatory.DDPEmitter.de().isOn
        msg = Observatory.DDPEmitter.messageStub()
        msg.socketId = @id
        msg.sessionId = @_session.connection._meteorSession.id
        msg.textMessage = "Got message in a socket #{@id} session #{@_session.connection._meteorSession.id}"
        msg.object = raw_msg
        msg.type = "DDP"
        #console.log msg
        Observatory.DDPEmitter.de().emitMessage msg, true
      
      socket.on 'close', ->
        return unless Observatory.DDPEmitter.de().isOn
        msg = Observatory.DDPEmitter.messageStub()
        msg.socketId = socket.id
        msg.textMessage = "Closed socket #{socket.id}"
        #console.log msg
        Observatory.DDPEmitter.de().emitMessage msg, true

    
        


(exports ? this).Observatory = Observatory