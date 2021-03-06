{map, concat, concatMap, difference, nub, union} = require './functional-helpers'
exports = module?.exports ? this

require './ember-runtime' unless Ember?

# TODO: make sure all the type signatures are correct

createNodes = (subclasses, superclasses = []) ->
  for own className, specs of subclasses then do (className) ->

    superclass = superclasses[0] ? ->
    isCategory = specs? and specs.length is 2
    params =
      if specs?
        switch specs.length
          when 0 then []
          when 1, 2 then specs[0]
      else null
    params ?= superclass::childNodes ? []

    klass = class extends superclass
      constructor:
        if isCategory then ->
        else ->
          for param, i in params
            this[param] = arguments[i]
          if @initialise?
            @initialise.apply this, arguments
          this
      className: className
      @superclasses = superclasses
    if specs?[0]? then klass::childNodes = specs[0]

    if isCategory then createNodes specs[1], [klass, superclasses...]
    exports[className] = klass

  return


# Note: nullable values are marked with `Maybe` in the type signature
# Note: primitive values are represented in lowercase
# Note: type classes are pluralised
createNodes
  Nodes: [
    []
    BinOps: [
      ['left', 'right']
      AssignOps: [
        ['assignee', 'expression']
        AssignOp: null # :: Assignables -> Exprs -> AssignOp
        ClassProtoAssignOp: null # :: ObjectInitialiserKeys -> Exprs -> ClassProtoAssignOp
        CompoundAssignOp: [['op', 'assignee', 'expression']] # :: string -> Assignables -> Exprs -> CompoundAssignOp
      ]
      BitOps: [
        null
        BitAndOp: null # :: Exprs -> Exprs -> BitAndOp
        BitOrOp: null # :: Exprs -> Exprs -> BitOrOp
        BitXorOp: null # :: Exprs -> Exprs -> BitXorOp
        LeftShiftOp: null # :: Exprs -> Exprs -> LeftShiftOp
        SignedRightShiftOp: null # :: Exprs -> Exprs -> SignedRightShiftOp
        UnsignedRightShiftOp: null # :: Exprs -> Exprs -> UnsignedRightShiftOp
      ]
      ComparisonOps: [
        null
        EQOp: null # :: Exprs -> Exprs -> EQOp
        GTEOp: null # :: Exprs -> Exprs -> GTEOp
        GTOp: null # :: Exprs -> Exprs -> GTOp
        LTEOp: null # :: Exprs -> Exprs -> LTEOp
        LTOp: null # :: Exprs -> Exprs -> LTOp
        NEQOp: null # :: Exprs -> Exprs -> NEQOp
      ]
      # Note: A tree of ConcatOp represents interpolation
      ConcatOp: null # :: Exprs -> Exprs -> ConcatOp
      ExistsOp: null # :: Exprs -> Exprs -> ExistsOp
      ExtendsOp: null # :: Exprs -> Exprs -> ExtendsOp
      InOp: null # :: Exprs -> Exprs -> InOp
      InstanceofOp: null # :: Exprs -> Exprs -> InstanceofOp
      LogicalOps: [
        null
        LogicalAndOp: null # :: Exprs -> Exprs -> LogicalAndOp
        LogicalOrOp: null # :: Exprs -> Exprs -> LogicalOrOp
      ]
      MathsOps: [
        null
        ExpOp: null # :: Exprs -> Exprs -> ExpOp
        DivideOp: null # :: Exprs -> Exprs -> DivideOp
        MultiplyOp: null # :: Exprs -> Exprs -> MultiplyOp
        RemOp: null # :: Exprs -> Exprs -> RemOp
        SubtractOp: null # :: Exprs -> Exprs -> SubtractOp
      ]
      OfOp: null # :: Exprs -> Exprs -> OfOp
      PlusOp: null # :: Exprs -> Exprs -> PlusOp
      Range: [['isInclusive', 'left', 'right']] # :: bool -> Exprs -> Exprs -> Range
      SeqOp: null # :: Exprs -> Exprs -> SeqOp
    ]

    Statements: [
      []
      Break: null # :: Break
      Continue: null # :: Continue
      Debugger: null # :: Debugger
      Return: [['expression']] # :: Maybe Exprs -> Return
      Throw: [['expression']] # :: Exprs -> Throw
    ]

    UnaryOps: [
      ['expression']
      BitNotOp: null # :: Exprs -> BitNotOp
      DeleteOp: null # :: MemberAccessOps -> DeleteOp
      DoOp: null # :: Exprs -> DoOp
      LogicalNotOp: null # :: Exprs -> LogicalNotOp
      NewOp: [['ctor', 'arguments']] # :: Exprs -> [Arguments] -> NewOp
      PreDecrementOp: null # :: Exprs -> PreDecrementOp
      PreIncrementOp: null # :: Exprs -> PreIncrementOp
      PostDecrementOp: null # :: Exprs -> PostDecrementOp
      PostIncrementOp: null # :: Exprs -> PostIncrementOp
      TypeofOp: null # :: Exprs -> TypeofOp
      UnaryExistsOp: null # :: Exprs -> UnaryExistsOp
      UnaryNegateOp: null # :: Exprs -> UnaryNegateOp
      UnaryPlusOp: null # :: Exprs -> UnaryPlusOp
    ]

    MemberAccessOps: [
      null
      StaticMemberAccessOps: [
        ['expression', 'memberName']
        MemberAccessOp: null # :: Exprs -> MemberNames -> MemberAccessOp
        NativeMemberAccessOp: null # :: Expres -> MemberNames -> NativeMemberAccessOp
        ProtoMemberAccessOp: null # :: Exprs -> MemberNames -> ProtoMemberAccessOp
        SoakedMemberAccessOp: null # :: Exprs -> MemberNames -> SoakedMemberAccessOp
        SoakedProtoMemberAccessOp: null # :: Exprs -> MemberNames -> SoakedProtoMemberAccessOp
      ]
      DynamicMemberAccessOps: [
        ['expression', 'indexingExpr']
        DynamicMemberAccessOp: null # :: Exprs -> Exprs -> DynamicMemberAccessOp
        DynamicProtoMemberAccessOp: null # :: Exprs -> Exprs -> DynamicProtoMemberAccessOp
        SoakedDynamicMemberAccessOp: null # :: Exprs -> Exprs -> SoakedDynamicMemberAccessOp
        SoakedDynamicProtoMemberAccessOp: null # :: Exprs -> Exprs -> SoakedDynamicProtoMemberAccessOp
      ]
    ]

    ChainedComparisonOp: [['expression']] # :: ComparisonOps -> ChainedComparisonOp

    FunctionApplications: [
      ['function', 'arguments']
      FunctionApplication: null # :: Exprs -> [Arguments] -> FunctionApplication
      SoakedFunctionApplication: null # :: Exprs -> [Arguments] -> SoakedFunctionApplication
    ]
    Super: null # :: Super

    Program: [['body']] # :: Maybe Exprs -> Program
    Block: [['statements']] # :: [Statement] -> Block
    Conditional: [['condition', 'consequent', 'alternate']] # :: Exprs -> Maybe Exprs -> Maybe Exprs -> Conditional
    ForIn: [['valAssignee', 'keyAssignee', 'target', 'step', 'filter', 'body']] # :: Maybe Assignable -> Maybe Assignable -> Exprs -> Exprs -> Maybe Exprs -> Maybe Exprs -> ForIn
    ForOf: [['isOwn', 'keyAssignee', 'valAssignee', 'target', 'filter', 'body']] # :: bool -> Assignable -> Maybe Assignable -> Exprs -> Maybe Exprs -> Maybe Exprs -> ForOf
    Switch: [['expression', 'cases', 'alternate']] # :: Maybe Exprs -> [SwitchCase] -> Maybe Exprs -> Switch
    SwitchCase: [['conditions', 'consequent']] # :: [Exprs] -> Maybe Expr -> SwitchCase
    Try: [['body', 'catchAssignee', 'catchBody', 'finallyBody']] # :: Exprs -> Maybe Assignable -> Maybe Exprs -> Maybe Exprs -> Try
    While: [['condition', 'body']] # :: Exprs -> Maybe Exprs -> While

    ArrayInitialiser: [['members']] # :: [ArrayInitialiserMembers] -> ArrayInitialiser
    ObjectInitialiser: [['members']] # :: [ObjectInitialiserMember] -> ObjectInitialiser
    ObjectInitialiserMember: [['key', 'expression', 'annotations']] # :: ObjectInitialiserKeys -> Exprs -> [Annotations] -> ObjectInitialiserMember
    Mixin: [['nameAssignee', 'body', 'mixins']] # :: Maybe Assignable -> Maybe Exprs -> [Mixin] -> Mixin
    Class: [['nameAssignee', 'parent', 'ctor', 'body', 'mixins', 'boundMembers']] # :: Maybe Assignable -> Maybe Exprs -> Maybe Exprs -> Maybe Exprs -> [ClassProtoAssignOp] -> [Mixin] -> Class
    Constructor: [['expression']] # :: Exprs -> Constructor
    Functions: [
      ['parameters', 'body']
      Function: null # :: [Parameters] -> Maybe Exprs -> Function
      BoundFunction: null # :: [Parameters] -> Maybe Exprs -> BoundFunction
      ComputedProperty: null # :: [Parameters] -> Maybe Exprs -> ComputedProperty
    ]
    DefaultParam: [['param', 'default']] # :: Parameters -> Exprs -> DefaultParam
    Annotations: [
      ['parameters']
      Volatile: null # :: [Parameters] -> Volatile
      Computed: null # :: [Parameters] -> Computed
      Observes: null # :: [Parameters] -> Observes
    ]
    Identifiers: [
      ['data']
      Identifier: null # :: string -> Identifier
      GenSym: null # :: string -> string -> GenSym
    ]
    Null: null # :: Null
    Primitives: [
      ['data']
      Bool: null # :: bool -> Bool
      JavaScript: null # :: string -> JavaScript
      Numbers: [
        null
        Int: null # :: float -> Int
        Float: null # :: float -> Float
      ]
      String: null # :: string -> String
    ]
    RegExps: [
      null
      RegExp: [['data', 'flags']] # :: string -> [string] -> RegExp
      HeregExp: [['expression', 'flags']] # :: Exprs -> [string] -> HeregExp
    ]
    This: null # :: This
    Undefined: null # :: Undefined

    Slice: [['expression', 'isInclusive', 'left', 'right']] # :: Exprs -> bool -> Maybe Exprs -> Maybe Exprs -> Slice

    Rest: [['expression']] # :: Exprs -> Rest
    Spread: [['expression']] # :: Exprs -> Spread
  ]


{
  Nodes, Primitives, CompoundAssignOp, StaticMemberAccessOps, Range,
  ArrayInitialiser, ObjectInitialiser, NegatedConditional, Conditional,
  Identifier, ForOf, Functions, While, Mixin, Class, Block, NewOp, Bool,
  FunctionApplications, RegExps, RegExp, HeregExp, Super, Slice, Switch,
  Identifiers, SwitchCase, GenSym, ComputedProperty, ObjectInitialiserMember,
  Annotations, PostIncrementOp, PostDecrementOp, MemberAccessOp, This,
  AssignOp, SoakedMemberAccessOp
} = exports


Nodes.fromBasicObject = (obj) -> exports[obj.type].fromBasicObject obj
Nodes::listMembers = []
Nodes::toBasicObject = ->
  obj = { type: @className }
  if @line? then obj.line = @line
  if @column? then obj.column = @column
  if @raw?
    obj.raw = @raw
    if @offset?
      obj.range = [
        @offset
        @offset + @raw.length
      ]
  for child in @childNodes
    if child in @listMembers
      obj[child] = (p.toBasicObject() for p in this[child])
    else
      obj[child] = if this[child]? then this[child].toBasicObject()
  obj
Nodes::fold = (memo, fn) ->
  for child in @childNodes
    if child in @listMembers
      memo = (p.fold memo, fn for p in this[child])
    else
      memo = this[child].fold memo, fn
  fn memo, this
Nodes::clone = ->
  ctor = ->
  ctor.prototype = @constructor.prototype
  n = new ctor
  n[k] = v for own k, v of this
  n
Nodes::instanceof = (ctors...) ->
  # not a fold for efficiency's sake
  superclasses = map @constructor.superclasses, (c) -> c::className
  for ctor in ctors when ctor::className in [@className, superclasses...]
    return yes
  no
Nodes::r = (@raw) -> this
Nodes::p = (@line, @column, @offset) -> this
Nodes::generated = no
Nodes::g = ->
  @generated = yes
  this


## Nodes that contain primitive properties

handlePrimitives = (ctor, primitives...) ->
  ctor::childNodes = difference ctor::childNodes, primitives
  ctor::toBasicObject = ->
    obj = Nodes::toBasicObject.call this
    for primitive in primitives
      obj[primitive] = this[primitive]
    obj

handlePrimitives Class, 'boundMembers'
handlePrimitives CompoundAssignOp, 'op'
handlePrimitives ForOf, 'isOwn'
handlePrimitives HeregExp, 'flags'
handlePrimitives Identifiers, 'data'
handlePrimitives Primitives, 'data'
handlePrimitives Range, 'isInclusive'
handlePrimitives RegExp, 'data', 'flags'
handlePrimitives Slice, 'isInclusive'
handlePrimitives StaticMemberAccessOps, 'memberName'
handlePrimitives ComputedProperty, 'chains'
handlePrimitives ObjectInitialiserMember, 'annotations'
handlePrimitives Annotations, 'parameters'

## Nodes that contain list properties

handleLists = (ctor, listProps...) -> ctor::listMembers = listProps

handleLists ArrayInitialiser, 'members'
handleLists Block, 'statements'
handleLists Functions, 'parameters'
handleLists FunctionApplications, 'arguments'
handleLists NewOp, 'arguments'
handleLists ObjectInitialiser, 'members'
handleLists Super, 'arguments'
handleLists Switch, 'cases'
handleLists SwitchCase, 'conditions'
handleLists Class, 'mixins'
handleLists Mixin, 'mixins'


## Nodes with special behaviours

Block.wrap = (s) -> new Block(if s? then [s] else []).r(s.raw).p(s.line, s.column)

Class::initialise = ->
  @boundMembers ?= []
  @name = new GenSym 'class'
  if @nameAssignee?
    # TODO: factor this out, as it's useful elsewhere: short object literal members, NFEs from assignee, etc.
    @name = switch
      when @nameAssignee.instanceof Identifier
        new Identifier @nameAssignee.data
      when @nameAssignee.instanceof StaticMemberAccessOps
        new Identifier @nameAssignee.memberName
      else @name
Class::childNodes.push 'name'

Mixin::initialise = ->
  @name = new GenSym 'mixin'
  if @nameAssignee?
    # TODO: factor this out, as it's useful elsewhere: short object literal members, NFEs from assignee, etc.
    @name = switch
      when @nameAssignee.instanceof Identifier
        new Identifier @nameAssignee.data
      when @nameAssignee.instanceof StaticMemberAccessOps
        new Identifier @nameAssignee.memberName
      else @name
Mixin::childNodes.push 'name'

ObjectInitialiser::keys = -> map @members, (m) -> m.key
ObjectInitialiser::vals = -> map @members, (m) -> m.expression

RegExps::initialise = (_, flags) ->
  @flags = {}
  for flag in ['g', 'i', 'm', 'y']
    @flags[flag] = flag in flags
  return

PostIncrementOp::initialise = ->
  @expression.isAssignment = true

PostDecrementOp::initialise = ->
  @expression.isAssignment = true


## Dependency Inference

Nodes::dependentKeys = (scope={}) ->
  chains = []
  for childName in @childNodes when this[childName]?
    if childName in @listMembers
      for member in this[childName]
        chains = chains.concat member.dependentKeys(scope)
    else
      child = this[childName]
      chains = chains.concat child.dependentKeys(scope)
  chains

This::dependentKeys = (scope={}) ->
  [[]]

MemberAccessOp::dependentKeys = (scope={}) ->
  memberName = @memberName
  @expression.dependentKeys(scope).map (c) ->
    c.push(memberName)
    c
SoakedMemberAccessOp::dependentKeys = MemberAccessOp::dependentKeys

# Compile a list of methods which are used to infer an @each dependency
enumerableMethods = Ember.Set.create()
enumerableMethods.addObjects(Ember.Enumerable.keys())
enumerableMethods.addObjects(Ember.Array.keys())
enumerableMethods.addObjects(Ember.MutableArray.keys())
enumerableMethods.addObjects(Ember.MutableEnumerable.keys())

FunctionApplications::dependentKeys = (scope={}) ->
  res = @function.dependentKeys(scope)
  if @function.instanceof(MemberAccessOp) || @function.instanceof(SoakedMemberAccessOp)
    # pop the function name
    res = res.map (c) ->
      c.pop()
      c
    # Add @each dependency if enumerable method
    if enumerableMethods.contains(@function.memberName)
      res = res.map (c) ->
        c.push('@each')
        c

  for argument in @arguments
    argument.dependentKeys(scope).map (c) ->
      res.push(c)
  res

Block::dependentKeys = (scope={}) ->
  res = []
  newScope = Ember.copy(scope)
  for key in newScope
    newScope[key] = Ember.copy(newScope[key])
  @statements.forEach (s) -> res = res.concat(s.dependentKeys(scope))
  for key in scope
    scope[key] = scope[key].concat(newScope[key])
  res

AssignOp::dependentKeys = (scope={}) ->
  res = @expression.dependentKeys(scope)
  if @assignee.instanceof(Identifier)
    scope[@assignee.data] = (scope[@assignee.data] || []).concat(res)
  res

Identifier::dependentKeys = (scope={}) ->
  Ember.copy(scope[@data]) || []



## Syntactic nodes

# Note: This only represents the original syntactic specification as an
# "unless". The node should be treated in all other ways as a Conditional.
# NegatedConditional :: Exprs -> Maybe Exprs -> Maybe Exprs -> NegatedConditional
class exports.NegatedConditional extends Conditional
  constructor: -> Conditional.apply this, arguments

# Note: This only represents the original syntactic specification as an
# "until". The node should be treated in all other ways as a While.
# NegatedWhile :: Exprs -> Maybe Exprs -> NegatedWhile
class exports.NegatedWhile extends While
  constructor: -> While.apply this, arguments

# Note: This only represents the original syntactic specification as a "loop".
# The node should be treated in all other ways as a While.
# Loop :: Maybe Exprs -> Loop
class exports.Loop extends While
  constructor: (body) -> While.call this, (new Bool true).g(), body
