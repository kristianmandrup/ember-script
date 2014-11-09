EmberScript  = require './module'

# utility method to merge/extend two objects
extend = exports.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

EmberScript.compileCode = (input, options) ->
  # options['raw'] = yes

  # Alternative??
  # EmberScript.em2js input, options

# IMPORTANT!! we could test for harmony option here and prepend input with import Ember ...
#  if options.es6? or options.harmony?
#    input = 'import Ember from "ember";\n' + input

# Perhaps we need to avoid importing Ember for each ember block encountered! Should only be for first one!

  csAst = EmberScript.parse input, raw: yes
  jsAst = EmberScript.compile csAst, options
  EmberScript.js jsAst, options

compilers =
  js: (source) ->
    source

  coffee: (source, options = {}) ->
    CoffeeScript = require 'coffee-script'
    # console.log 'CoffeeScript.compile:', source
    CoffeeScript.compile source, { bare: true }

  live: (source, options = {}) ->
    LiveScript = require('LiveScript')
    # console.log 'LivesScript.compile:', source
    LiveScript.compile source, { bare: true }

  ember: (source, options = {}) ->
    # console.log 'EmberScript.compile:', source
    opts = raw: yes, literate: yes
    # opts = extend options, opts
    EmberScript.compileCode source, opts

# emit the code to a file or stdout
# depending on options

createCodeEmitter = (options) ->
  (code) ->
    code = "#{code}\n"
    if options.output    
      fs.writeFile options.output, code, (err) ->
        throw err if err?
    else
      process.stdout.write code


multiCompile = require './multi-compiler'

module.exports = (code, options) ->
  mcOptions =
    lang: 'coffee'

  # console.log 'options', options
  codeEmitter = options.codeEmitter || createCodeEmitter(options)
  multiCompile code, compilers, codeEmitter, mcOptions, options
