## Contributing to EmberScript

### General recommendations

- Only make changes in the `/src` folder
- Most behavior changes are to be done in `compiler.coffee`
- Make sure the changed file compiles before you do an entire build
- Always make sure all tests pass before you do a pull request

### Running tests

```bash
$ make build -j
$ make test
```

All tests should pass (green)

### Debugging changes

For debugging changes in general, it is often easier to do it directly by examining output to stdout.
This way, any `console.log`s are displayed without the "pollution" of test suite output.

It is often useful to run ember-script with the `-j` switch, returning bare javascript (without function scope wrapper). Again to avoid "pollution" and keep it clean. 

Reading input directly from CLI (string)

```bash
$ make build -j
$ bin/ember-script -j --cli "a = 2"
```

Reading input from a file

```bash
$ make build -j
$ bin/ember-script -j --input sandbox/test-fragmented.em
```

### Architecture

bin/ember-script loads the `ember-runtime` and the `cli` in order to execute. The cli parses the cli commands, reads some input from a file or string and generates some output.

```javascript
#!/usr/bin/env node
require(require('path').join(__dirname, '..', 'lib', 'ember-runtime'));
require(require('path').join(__dirname, '..', 'lib', 'cli'));
```

### CLI architecture

`cli-exclusions`: attempts to resolve cli options where conflicts might occur.
`cli-fragmenter`: used to turn code into fragments that can be treated individually. 
`cli-help`: displays help on how to use cli
`cli-input-source-chooser`: determines how to read the input source (file, cli string, ...)
`cli-output`: writes the output to an output target (file, stdout, ...)
`cli-process-input`: processes the input using some strategy depending on options
`cli`: the main cli

The fragmenter is currently turned on by default but can be easily turned off in `cli.coffee`:

```coffeescript
# false to disable script fragments
options.fragmented = true
```

See more in [[Script-Fragmentation]]