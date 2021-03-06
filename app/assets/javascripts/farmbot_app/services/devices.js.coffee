class DeviceService
  constructor: (@Command, @Router, @socket, @Data, @$timeout) ->
    [@list, @current, @status] = [[], {}, {meshblu: "Connecting"}]
    @stepSize = 10
    @initConnections()

  initConnections: ->
    nope = ->
      alert "Oh no! I could not connect to the My Farmbot service. The server" +
          " might be temporarily down"
    ok = (data) =>
      if data[0]
        [@list, @current] = [data, data[0]]
        @connectToMeshBlu()
      else
        alert 'You need to link a Farmbot to your account.'
        window.location = '/dashboard#/devices'
    @Data.findAll('device', {}).catch(nope).then(ok)

  handleMsg: (data) =>
    bot = _.find(@list, {uuid: data.fromUuid})
    @Router.create(data, bot)

  handleStatus: (data) ->
    @status = data

  connectToMeshBlu: ->
    # Avoid double connections
    if @socket?.connected()
      console.log "[WARN] Already connected to MeshBlu."
    else
      skynet = {createConnection: ->
                  console.warn "Need to deprecate skynetJS"
                  return {on: -> null}}
      @socket.on "message", (d) => @handleMsg; console.log(d)
      @socket.on "status", @handleStatus
      @socket.on 'connect', =>
        @socket.on 'identify', (data) =>
          @socket.emit 'identity',
            socketid: data.socketid
            uuid:  "7e3a8a10-6bf6-11e4-9ead-634ea865603d"
            token: "zj6tn36gux6crf6rjjarh35wi3f5stt9"

  getStatus: =>
    console.log 'Status is disabled right now.'
    # @send(@Command.create("read_status"))
    @pollStatus()

  pollStatus: =>
    INTERVAL = 9000
    if @socket.connected()
      @$timeout @getStatus, INTERVAL
    else
      @$timeout @pollStatus, INTERVAL

  togglePin: (number, cb) ->
    pin = "pin#{number}"
    if @current[pin] is on
      @current[pin] = off
      message = {pin: number, value1: 1, mode: 0}
    else
      @current[pin] = on
      message = {pin: number, value1: 0, mode: 0}
    @send @Command.create("pin_write", message), cb

  # TODO This method (and moveAbs) might be overly specific. Consider removal in
  # favor of @sendMessage()
  moveRel: (x, y, z, cb) ->
    @send(@Command.create("move_rel", {x: x, y: y, z: z}), cb)

  moveAbs: (x, y, z, cb) ->
    @send(@Command.create("move_abs", {x: x, y: y, z: z}), cb)

  sendMessage: (name, params) ->
    @send @Command.create(name, params)

  send: (msg) ->
    if @socket.connected()
      @socket.emit "message", {devices: @current.uuid, payload: msg}
    else
      alert 'Unable to send device messages.' +
            ' Wait for device to connect or refresh the page'

angular.module("FarmBot").service "Devices",[
  'Command'
  'Router'
  'socket'
  'Data'
  '$timeout'
  (Command, Router, socket, Data, $timeout) ->
    return new DeviceService(Command, Router, socket, Data, $timeout)
]
