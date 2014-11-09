a = "js"

# (em)

class PostsController extends Ember.ArrayController
  trimmedPosts: ~>
    @content?.slice(0, 3)

  +observer content.@each
  postsChanged: ->
    console.log('changed')

e = "ember"

# (ls)

l = "live"

# (js)

j = "live"