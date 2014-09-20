fs    = require 'fs'
path  = require 'path'

CoffeeScript = require './module'

module.exports = (sourceObj, output, options) ->
  jsAST     = sourceObj.jsAST
  sourceMap = sourceObj.sourceMap
  inputName = sourceObj.inputNam

  # js code gen
  try
    {code: js, map: sourceMap} = CoffeeScript.jsWithSourceMap jsAST, inputName, compact: options.minify
  catch e
    console.error (e.stack or e.message)
    process.exit 1

  # --js
  if options.js
    if options.sourceMapFile
      fs.writeFileSync options.sourceMapFile, "#{sourceMap}"
      sourceMappingUrl =
        if options.output
          path.relative (path.dirname options.output), options.sourceMapFile
        else
          options.sourceMapFile
      js = """
        #{js}

        //# sourceMappingURL=#{sourceMappingUrl}
      """
    output js
    return

  # --eval
  if options.eval
    CoffeeScript.register()
    process.argv = [process.argv[1], options.input].concat additionalArgs
    runMain input, js, jsAST, inputSource
    return