
################################################################################
module "General assertions"
################################################################################

test "Hello Test", () ->
  ok 1 == 1, "Passed!"


################################################################################
module "Template generating"
################################################################################

test "Constructor passing and storage and modification", () ->
  t1 = 'foo' : 23
  t2 = 'bar' : 42
  
  c = cs(t1)
  deepEqual(c(), t1, "Template assigned to generator stays untouched")
  
  c.template = t2
  deepEqual(c(), t2, "Template modification are reflected after recall")



test "Template", () ->
  deepEqual(
    cs({
      'foo' : 42
      'bar' : 23
    })(),
    {
      'foo' : 42
      'bar' : 23
    },
    "Result is the same as the template")



test "Template with nested structure", () ->
  deepEqual(
    cs({
      'foo' :
        'value' : 42
      'bar' : 
        'value' : 23
    })(),
    {
      'foo' :
        'value' : 42
      'bar' : 
        'value' : 23
    },
    "Nested structures are handled")
  


test "Template with functions", () ->
  deepEqual(
    cs({
      'foo' : 42
      'bar' : () -> 23
    })(),
    {
      'foo' : 42
      'bar': 23
    },
    "Function is evaluated")
  
  deepEqual(
    cs({
      'foo' : 42
      'bar' : () -> () -> () -> 23
    })(),
    {
      'foo' : 42
      'bar': 23
    },
    "Function is evaluated recursively")
  
  deepEqual(
    cs({
      'foo' : { 'value' : 42 }
      'bar' : () -> { 'value' : 23 }
    })(),
    {
      'foo' : { 'value' : 42 }
      'bar': { 'value' : 23 }
    },
    "Function returning structure is evaluated")
  
  deepEqual(
    cs({
      'foo' : [ 23, 42 ]
      'bar' : () -> [ 42, 23 ]
    })(),
    {
      'foo' : [ 23, 42 ]
      'bar': [ 42, 23 ]
    },
    "Function returning array is evaluated")



test "Template with Arrays", () ->
  deepEqual(
    cs({
      'foo' : [
        42 
        23
      ]
    })(),
    {
      'foo' : [
        42 
        23
      ]
    },
    "Arrays are handled correctly")
  
  deepEqual(
    cs({
      'foo' : [
        { 'value' : 42 } 
        { 'value' : 23 }
      ]
    })(),
    {
      'foo' : [
        { 'value' : 42 } 
        { 'value' : 23 }
      ]
    },
    "Arrays of structures are handled correctly")
  
  deepEqual(
    cs({
      'foo' : [
        () -> 42 
        () -> 23
      ]
    })(),
    {
      'foo' : [
        42 
        23
      ]
    },
    "Arrays of functions are handled correctly")



################################################################################
module "Logical functions"
################################################################################

test "Function 'if'", () ->
  equal cs(cs.if true,  'foo', 'bar')(), 'foo', "Result comes from the if template"
  equal cs(cs.if false, 'foo', 'bar')(), 'bar', "Result comes from the else template"
  
  equal cs(cs.if (() -> true),  (() -> 'foo'), (() -> 'bar'))(), 'foo', "Functions are evaluated for condition and if template"
  equal cs(cs.if (() -> false), (() -> 'foo'), (() -> 'bar'))(), 'bar', "Functions are evaluated for condition and else template"



test "Function 'filter'", () ->
  deepEqual(
    cs(cs.filter ((key, value) -> true), { 
      'foo' : 42
      'bar' : 23
    })(),
    { 
      'foo' : 42
      'bar' : 23
    },
    "Filter emits all values"
  )
  
  deepEqual(
    cs(cs.filter ((key, value) -> false), { 
      'foo' : 42
      'bar' : 23
    })(),
    {
    },
    "Filter emits no values"
  )
  
  deepEqual(
    cs(cs.filter ((key, value) -> key == 'foo'), { 
      'foo' : 42
      'bar' : 23
    })(),
    { 
      'foo' : 42
    },
    "Filter emits the foo value"
  )



################################################################################
module "Big structure"
################################################################################
test "Big structure", () ->
  filters = [
    {
      'name' : 'foo'
      'value' : 42
    }
    {
      'name' : 'bar'
      'value' : 23
    }
  ]
  
  t = cs({
    'query' :
      'match_all' : {}
    'filter' : cs.if((() -> filters.length > 0),
      {
        'and' : 'juchuu'
      },
      {
        'or' : 'ouch'
      }
    )
    'from' : 0
    'size' : 50
    'sort' : []
  })
  
  equal t().filter.and, 'juchuu'
  
  filters.length = 0
  
  console.log t()
  
  equal t().filter.or, 'ouch'