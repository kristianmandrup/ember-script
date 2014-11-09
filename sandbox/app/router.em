Map = class router
  $friends ->
    _new
    _show path: ':friend_id', ->
      $articles ->
        _new
      _edit path: ':friend_id/edit'

$go 'friends.show', @

person.x++
line.y--
