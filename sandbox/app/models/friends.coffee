Friends = DS.Model.extend
  articles:       hasMany 'articles', async: true
  email:          attr 'string'
  firstName:      attr 'string'
  lastName:       attr 'string'
  totalArticles:  attr 'number'
  twitter:        attr 'string'
  fullName:       Ember.computed 'firstName', 'lastName', ->
    [@firstName, @lastName].join ' '

