[![Build Status](https://travis-ci.org/ghempton/ember-script.png?branch=master)](https://travis-ci.org/ghempton/ember-script)

# EmberScript

EmberScript is a CoffeeScript-derived language which takes advantage of the [Ember.js](http://emberjs.com) runtime. Ember constructs such as Inheritance, Mixins, Bindings, Observers, etc. are all first-class citizens within EmberScript.

## Examples

```coffeescript
class PostsController extends Ember.ArrayController
  trimmedPosts: ~>
    @content.slice(0, 3)
```

compiles to:

```javascript
var PostsController;
var get$ = Ember.get;
PostsController = Ember.ArrayController.extend({
  trimmedPosts: Ember.computed(function () {
    return get$(this, 'content').slice(0, 3);
  }).property('content.@each')
});
```

For a more comprehensive list of live examples, check out the main [EmberScript website](http://emberscript.com).

## Is this ready to use?

For the most part, but use at your own risk. See the [todo](https://github.com/ghempton/ember-script/blob/master/TODO.txt) list for details. It is recommended to use EmberScript side by side with javascript and/or coffeescript.

## Installation

### Ruby on Rails

If you are using Rails as your backend, simply add the following to your Gemfile:

```
gem 'ember_script-rails'
```

All assets ending in `.em` will be compiled by EmberScript.

### Npm

```
sudo npm install -g ghempton/ember-script
ember-script --help
```

## Development

```
make -j build test
```

To simply build coffee files:

`coffee --watch -o lib -c src/multi-compiler.coffee src/cli-multi-compile.coffee`

Run individual tests...

`$bin/ember-script -j --input sandbox/test-fragmented.em`

Testing model file with Ember Data extra goodies! :)

`$ bin/ember-script -j --input sandbox/app/models/friends.em`
`$ bin/ember-script -j --input sandbox/app/models/friends-adv.coffee`
`$ bin/ember-script -j --input sandbox/app/router.em`

## Script fragments and Multi compilation

This branch support compilation of script fragments (multi compilation).
It was added in order to better support environments where you need more control of the compilation, such
as with ember-cli and ES6 modules.

```coffeescript
var a = "js";

# (coffee)

y = "coffee with a"

# (ember)

class Post
  trimmedPosts: ~>
    @content?.slice(0, 3)

# (live)

x = "milk and y"
```

Valid aliases are:

- coffeescript:
  `cs`,   `coffee`
- javascript:
  `js`,   `ecma`
- livescript:
  `ls`,   `live`
- emberscript:  
  `em`, `ember`

The first block is (by default) assumed to be *coffeescript* (unless you have a script identifier comment as the first line of code).

Another way to add top level code is this [ember-cli fix](https://github.com/patricklx/ember-script/commit/7516a4e90481c9f4ac4dc64ec55f4ee5b4261752) by @patricklx.

```js
  em2js: (input, options = {}) ->
    options.optimise ?= on
    csAST = @parse input, options
    jsAST = @compile csAST, bare: options.bare
    jsCode = @js jsAST, compact: options.compact or options.minify
    if options.es6 then 'import Ember from "ember";\n' + jsCode else jsCode
```

We use this approach as well if `options.es6` is set!

### Customization

For your own customizations, go to the end of `cli-multi-compile.coffee` and change `compilers` or `codeEmitter`. You can also send an extra `mcOptions` object as the last argument. This object can
take a `transformer` function (f.ex to prepend each compiled fragment with a custom comment) and a `lang` (string) argument to override `coffeescript` as the default/first fragment script language.

```coffeescript
multiCompile = require './multi-compiler'

module.exports = (code, options) ->
  mcOptions = {
    lang: 'coffee'
  }
  codeEmitter = options.codeEmitter || createCodeEmitter(options)
  multiCompile code, compilers, codeEmitter, mcOptions
```

### Top fragment customization

You can now also configure your topFragments and default fragment language via
an `.emberscriptrc` file in your project root

```js
{
  "defaultLang": "coffee",
  "fragments": {
    "default": [
      "`import Ember from 'ember'`"
    ],
    "model": [
      "`import DS from 'ember-data'`",
      "Model = DS.Model",
      "attr = DS.attr",
      "hasMany = DS.hasMany",
      "belongsTo = DS.belongsTo",
      "computed = Ember.computed"
    ]
  }
}
```

You can also add/edit custom top level fragments in `src/multi-compiler.coffee`

```coffeescript
# customize your own initial top fragments here
defaultFragments = config.fragments.default or ['`import Ember from "ember"`']
topFragments defaultFragments

# if the file is located inside app/models we assume it is a models file
if srcPath.match /app\/models\//
  topFragments config.fragments.model or defaultModelFragments
```

Currently we always add `import Ember from "ember"` as the top fragment. Then if the file is located inside `app/models`,
we assume it is a model file using Ember Data and import the DS namespace and setup some convenience variables.
This allows us to write the model like this:

```coffeescript
Friends = Model.extend
  articles:       hasMany 'articles', async: true
  email:          attr 'string'
  firstName:      attr 'string'
  lastName:       attr 'string'
  totalArticles:  attr 'number'
  twitter:        attr 'string'
  fullName:       Ember.computed 'firstName', 'lastName', ->
    [@firstName, @lastName].join ' '
```

## Precompile extras

As an experiment, we have now added an (optional) precompile step

Precompilation currently works with>

- models
- the router

Note: It would be much better to use [sweet.js](http://sweetjs.org/) to provide macros than to use
the current crude regexp replace approach!

### Model

```coffeescript
Friends = model
  articles:       hasMany 'articles', async: true
  twitter:        belongsTo 'twit'

  email:          $string
  firstName:      $string
  lastName:       $string
  totalArticles:  $number

  fullName:       computed 'firstName', 'lastName', ->
    [@firstName, @lastName].join ' '
```

Precompiled and then compiled into:

```js
Friends = Model.extend({
  articles: hasMany('articles', { async: true }),
  twitter: belongsTo('twit'),
  email: attr('string'),
  firstName: attr('string'),
  lastName: attr('string'),
  totalArticles: attr('number'),
```

### Router

```coffeescript
Map = class router
  $friends ->
    _new
    _show path: ':friend_id', ->
      $articles ->
        _new
      _edit path: ':friend_id/edit'

```

Precompiled and then compiled into:

```js
Map = Router.map(function () {
  this.resource('friends', function () {
    this.route('new');
    this.route('show', { path: ':friend_id' }, function () {
      this.resource('articles', function () {
        this.route('new');
      });
      this.route('edit', { path: ':friend_id/edit' });
    });
  });
});
```

### Other extras

```js
$go 'friends.show', @

person.x++
line.y--
```

Precompiled and then compiled into:

```js
this.transitionToRoute('friends.show', this);
person.incrementProperty('x');
line.decrementProperty('y');
```
