# A button used to set integers
directive =
  template: '<i></i>'
  restrict: 'E'
  scope:
    direction: '='
    axis:      '='
    icon:      '='
  link: (scope, el, attr) ->
    classes =
      x:
        up:   'fa fa-2x fa-arrow-left arrow-button radius'
        down: 'fa fa-2x fa-arrow-right arrow-button radius'
      y:
        up:   'fa fa-2x fa-arrow-up arrow-button radius'
        down: 'fa fa-2x fa-arrow-down arrow-button radius'
      z:
        up:   'fa fa-2x fa-arrow-up arrow-button radius'
        down: 'fa fa-2x fa-arrow-down arrow-button radius'
    try
      el.addClass(classes[attr.axis][attr.direction])
    catch e
      el.addClass(classes.x.up)
      console.warn 'Malformed <directionbutton> params. Using default.'

    el.on 'click', ->
      scope.move attr.axis, (attr.direction == 'up') ? -1 : 1
  controller: ['$scope', 'Devices', ($scope, Devices) ->
    $scope.move = (axis, direction) ->
      cmd = {x: 0, y: 0, z: 0}
      direction = if direction then 1 else -1
      cmd[axis] = Devices.stepSize * direction
      Devices.moveRel cmd.x, cmd.y, cmd.z, (d) -> (d)
  ]

angular.module("FarmBot").directive 'directionbutton', [() -> directive]
