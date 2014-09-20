fs = require 'fs'

{Preprocessor} = require './preprocessor'

{numberLines, humanReadable} = require './helpers'
{runMain} = require './run'
{concat, foldl} = require './functional-helpers'

selectinputSource = (options) ->
  if options.input?
    fs.realpathSync options.input 
  else
    options.cli and '(cli)' or '(stdin)'

module.exports = (input, options, err) ->
  throw err if err?
  result = null
  inputName = options.input ? (options.cli and 'cli' or 'stdin')
  inputSource = selectinputSource options

  input = input.toString()
  # strip UTF BOM
  if 0xFEFF is input.charCodeAt 0 then input = input[1..]

  # preprocess
  if options.debug
    try
      console.error '### PREPROCESSED CS ###'
      preprocessed = Preprocessor.process input, literate: options.literate
      console.error numberLines humanReadable preprocessed

  # switch outputter if needed!
  if options.fragmented
    fragmenter = require('./cli-fragmenter')
    fragments = fragmenter(input)

    # console.log 'fragments', fragments
    options.parts =
      prepend: fragments.js

    output = require('./cli-output')(options)
    input = fragments.ember
  else
    output = require('./cli-output')('', options)

  # parse
  parse = require './cli-parser'
  inputObj = 
    inputSource: inputSource
    input: input

  sourceObj = parse inputObj, output, options

  # js code gen
  if typeof sourceObj is 'object'
    # extend with inputObj
    sourceObj.inputName = inputName
    sourceObj.inputSource = inputSource

    jsCodeGen = require './cli-js-codegen'    
    jsCodeGen sourceObj, input, options
