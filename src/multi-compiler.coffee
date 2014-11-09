fragmenter = (mcOptions, options) ->
  anyFragExpr = /#\s\((ember|em|coffee|cs|ecma|js|live|ls)\)\s*/

  createFragment = (lang, code) ->
    {type: lang, code: code}

  # by default starts with coffeescript
  fragmentStack = [mcOptions.lang or 'coffee']

  fragments = []

  topFragment = (code) ->
    fragments.push(createFragment 'coffee', code)

  topFragments = (fragments) ->
    topFragment fragments.join '\n'

  # customize your own initial top fragments here
  topFragment '`import Ember from "ember"`'

  srcPath = options.input

  # if the file is located inside app/models we assume it is a models file
  if srcPath.match /app\/models\//
    topFragments [
      '`import DS from "ember-data"`',
      'attr = DS.attr',
      'hasMany = DS.hasMany',
      'belongsTo = DS.belongsTo'
    ]

  return {
    fragments: fragments

    fragmentize: (code) ->
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
  cs: 'coffee'
  em: 'ember'
  ecma: 'js'
  ls: 'live'

resolveCompilerAlias = (alias) ->
  compilerAliases[alias] or alias

commentTransform = (compiled, type) ->
  compileComment = "\n// compile fragment: #{type}\n"
  compileComment.concat compiled

createIterator = (compilers, mcOptions) ->

  transform = mcOptions.transformer or commentTransform

  (fragment, cb) ->
    type = resolveCompilerAlias fragment.type
    code = fragment.code

    compiled = transform compilers[type](code), type
    
    cb null, compiled

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

  async.concat(fragger.fragments, createIterator(compilers, mcOptions), (err, results) ->
    return next(err)  if (err)
    cb results.join('\n')
  )

module.exports = concatAll