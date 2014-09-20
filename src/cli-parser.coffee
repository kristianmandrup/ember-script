CoffeeScript = require './module'
{Optimiser} = require './optimiser'

cscodegen = try require 'cscodegen'
escodegen = try require 'escodegen'
esmangle = try require 'esmangle'

module.exports = (inputObj, output, options) ->
  inputSource = inputObj.inputSource
  input = inputObj.input
  
  # parse
  try
    result = CoffeeScript.parse input,
      optimise: no
      raw: options.raw or options.sourceMap or options.sourceMapFile or options.eval
      inputSource: inputSource
      literate: options.literate
  catch e
    console.error e.message
    process.exit 1
  if options.debug and options.optimise and result?
    console.error '### PARSED CS-AST ###'
    console.error inspect result.toBasicObject()

  # optimise
  if options.optimise and result?
    result = Optimiser.optimise result

  # --parse
  if options.parse
    if result?
      output inspect result.toBasicObject()
      return
    else
      process.exit 1

  if options.debug and result?
    console.error "### #{if options.optimise then 'OPTIMISED' else 'PARSED'} CS-AST ###"
    console.error inspect result.toBasicObject()

  # cs code gen
  if options.cscodegen
    try result = cscodegen.generate result
    catch e
      console.error (e.stack or e.message)
      process.exit 1
    if result?
      output result
      return
    else
      process.exit 1

  # compile
  jsAST = CoffeeScript.compile result, bare: options.bare

  # --compile
  if options.compile
    if jsAST?
      output inspect jsAST
      return {
        jsAST: jsAST
      }
    else
      process.exit 1

  if options.debug and jsAST?
    console.error "### COMPILED JS-AST ###"
    console.error inspect jsAST

  # minification
  if options.minify
    try
      jsAST = esmangle.mangle (esmangle.optimize jsAST), destructive: yes
    catch e
      console.error (e.stack or e.message)
      process.exit 1

  if options.sourceMap
    # source map generation
    try sourceMap = CoffeeScript.sourceMap jsAST, inputName, compact: options.minify
    catch e
      console.error (e.stack or e.message)
      process.exit 1
    # --source-map
    if sourceMap?
      output "#{sourceMap}"
      return {
        sourceMap: sourceMap
        jsAST: jsAST
      }
    else
      process.exit 1
