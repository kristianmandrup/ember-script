Friends = model
  articles:       hasMany 'articles', async: true
  twitter:        belongsTo 'twit'

  email:          $string
  firstName:      $string
  lastName:       $string
  totalArticles:  $number

  fullName:       computed 'firstName', 'lastName', ->
    [@firstName, @lastName].join ' '