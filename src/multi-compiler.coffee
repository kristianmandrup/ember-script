fs = require 'fs'
util = require 'util'

emptyConfig = {fragments: {}}

parseConfig = ->
  try
    return emptyConfig unless fs.existsSync '.emberscriptrc'

    json = fs.readFileSync '.emberscriptrc', 'utf8'
    JSON.parse json
  catch e
    console.error e
    emptyConfig

fragmenter = (mcOptions, options) ->
  anyFragExpr = /#\s\((ember|em|coffee|cs|ecma|js|live|ls)\)\s*/

  createFragment = (lang, code) ->
    {type: lang, code: code}

  config = parseConfig()

  srcPath = options.input

  config.defaultLang ||= mcOptions.lang or 'coffee'

  # by default starts with coffeescript
  fragmentStack = [config.defaultLang]

  fragments = []

  topFragment = (code) ->
    return unless code
    fragments.push(createFragment config.defaultLang, code)

  topFragments = (fragments) ->
    if typeof fragments is 'object' and fragments.length
      topFragment fragments.join '\n'

  # customize your own initial top fragments here
  defaultFragments = config.fragments.default or ['`import Ember from "ember"`']
  topFragments defaultFragments if defaultFragments

  defaultModelFragments = [
    '`import DS from "ember-data"`',
    'Model = DS.Model',
    'attr = DS.attr',
    'hasMany = DS.hasMany',
    'belongsTo = DS.belongsTo',
    "computed = Ember.computed"
  ]

  # if the file is located inside app/models we assume it is a models file
  if srcPath.match /app\/models\//
    topFragments config.fragments.model or defaultModelFragments

  # more topFragment customizations may follow here...

  return {
    fragments: fragments

    fragmentize: (code) ->
      unless typeof code is 'string'
        console.log util.inspect code
        throw Error "Code to fragmentize must be a String, was: #{typeof code}"

      nextFragMatch = code.match anyFragExpr
      unless nextFragMatch
        return @fragments.push(createFragment fragmentStack.shift(), code)

      # get text matched (separator: start of next fragment)
      matchTxt = nextFragMatch[0]

      # get index of separator
      index = code.indexOf matchTxt

      # get current fragment until next fragment starts
      curFragment = code.slice(0, index)
      @fragments.push(createFragment fragmentStack.shift(), curFragment)
      # add lang for next iteration
      fragmentStack.push nextFragMatch[1]

      # advance code cursor until start of next fragment
      @fragmentize code.slice(index + matchTxt.length)
    }

compilerAliases =
  cs:     'coffee'
  em:     'ember'
  ecma:   'js'
  ls:     'live'

resolveCompilerAlias = (alias) ->
  compilerAliases[alias] or alias

commentTransform = (compiled, type) ->
  compileComment = "\n// fragment: #{type}\n"
  compileComment.concat compiled

createIterator = (compilers, mcOptions, options) ->

  transform = mcOptions.transformer or commentTransform

  (fragment, cb) ->
    type = resolveCompilerAlias fragment.type
    code = fragment.code

    if !!code
      compiled = transform compilers[type](code, options), type
      cb null, compiled
    else
      cb null, code

async = require 'async'

# Arguments: 
# @code to compile in parallel

# @compilerss a compiler object where each key is one of js, coffee, live, ember:  

# Example:
# {coffee: function(codeToCompile) {}, ember: ...}

# callback to receive the compiled code when done

# Example:
# showCompiledCode = (compiledCode) ->
#   console.log return compiledCode

concatAll = (code, compilers, cb, mcOptions, options) ->
  mcOptions = mcOptions or {}

  fragger = fragmenter mcOptions, options
  fragger.fragmentize code
  # console.log fragger

  async.concat(fragger.fragments, createIterator(compilers, mcOptions, options), (err, results) ->
    return next(err)  if (err)
    cb results.join('\n')
  )

module.exports = concatAll