EmberScript  = require './module'
util = require 'util'

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

  csAst = EmberScript.parse input, raw: yes, bare: yes
  jsAst = EmberScript.compile csAst, bare: yes #, options
  EmberScript.js jsAst #, options

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

precompilerFor = (options) ->
  srcPath = options.input
  # console.log 'srcPath', srcPath, options
  return routerPrecompiler if srcPath.match /app\/router\./
  return modelPrecompiler if srcPath.match /app\/models\//
  basePrecompiler

basePrecompiler = (code) ->
  code = code.replace ///\$go///gi, "@transitionToRoute"
  code = code.replace ///(\w+)\+\+///gi, "incrementProperty '$1'"
  code = code.replace ///(\w+)\-\-///gi, "decrementProperty '$1'"
  code

modelPrecompiler = (code) ->
  code = basePrecompiler code
  # class\s*
  for type in ['string', 'number', 'boolean', 'date']
    code = code.replace ///\$#{type}///gi, "attr '#{type}'"
  code = code.replace ///=\s*model$///mgi, "= Model.extend"
  code

routerPrecompiler = (code) ->
  code = basePrecompiler code
  code = code.replace ///^(\s*)\$(\w+)///mgi, "$1@resource '$2',"
  code = code.replace ///^(\s*)_(\w+)$///mgi, "$1@route '$2'"
  code = code.replace ///^(\s*)_(\w+)\s*(\w+)///mgi, "$1@route '$2', $3"
  code = code.replace ///=\s*class\s*router\s///gi, "= Router.map ->"
  code


module.exports = (code, options) ->
  mcOptions =
    lang: 'coffee'

  # console.log 'options', options
  codeEmitter = options.codeEmitter || createCodeEmitter(options)

  # always insert ember script fragment identifier at the top unless first line has such a comment
  lines = code.split '\n'
  unless lines[0] and lines[0].match /# \(\w+\)/
    code = "# (em)\n#{code}"

  precompile = precompilerFor options
  code = precompile code

  multiCompile code, compilers, codeEmitter, mcOptions, options
