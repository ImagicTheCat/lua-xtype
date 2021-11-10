-- Test multifunction.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

do -- Test operators.
  local op_add = xtype.multifunction()
  local op_mul = xtype.multifunction()
  local op_eq = xtype.multifunction()

  local function build_type(t)
    local ins_mt = {
      xtype = t,
      __add = op_add,
      __mul = op_mul,
      __eq = op_eq
    }
    local type_mt = {
      xtype = "xtype",
      __call = function(t, v)
        return setmetatable({v = v}, ins_mt)
      end
    }
    return setmetatable(t, type_mt)
  end

  local Fruits = build_type(xtype.create("Fruits"))
  local Apples = build_type(xtype.create("Apples", Fruits))
  local Oranges = build_type(xtype.create("Oranges", Fruits))

  op_add:define(function(a, b) return Apples(a.v+b.v) end, Apples, Apples)
  op_add:define(function(a, b) return Oranges(a.v+b.v) end, Oranges, Oranges)
  op_add:define(function(a, b) return Fruits(a.v+b.v) end, Fruits, Fruits)
  op_mul:define(function(a, f) return Apples(a.v*f) end, Apples, "number")
  op_mul:define(function(a, f) return Oranges(a.v*f) end, Oranges, "number")
  op_mul:define(function(a, f) return Fruits(a.v*f) end, Fruits, "number")
  op_eq:define(function(a, b) return a.v == b.v end, Apples, Apples)
  op_eq:define(function(a, b) return a.v == b.v end, Oranges, Oranges)
  op_eq:define(function(a, b)
    return xtype.get(a) == xtype.get(b) and a.v == b.v
  end, Fruits, Fruits)

  local apples = Apples(5)
  local oranges = Oranges(5)
  -- checks
  assert(xtype.is(op_eq, "multifunction"))
  assert(xtype.get(op_eq) == "multifunction")
  assert(apples+apples == Apples(10))
  assert(op_add:call(apples, apples) == Apples(10)) -- alternative
  assert(op_add:resolve(Apples, Apples)(apples, apples) == Apples(10)) -- alternative
  assert(not (apples+oranges == Apples(10)))
  assert(apples+oranges == Fruits(10))
  assert(oranges+apples == Fruits(10))
  assert(apples*3 == Apples(15))
end
do -- Test resolution order.
  -- types
  local animal = xtype.create("animal")
  local dog = xtype.create("dog", animal)
  local cat = xtype.create("cat", animal)
  local chimera = xtype.create("chimera", cat, dog)
  -- multifunction
  local what = xtype.multifunction()
  what:define(function() return "animal" end, animal)
  what:define(function() return "cat" end, cat)
  what:define(function() return "dog" end, dog)
  what:define(function() return "chimera" end, chimera)
  local a = setmetatable({}, {xtype = chimera})
  -- checks
  assert(what(a) == "chimera")
  assert(what:call(a) == "chimera") -- alternative
  assert(what:resolve(chimera)(a) == "chimera") -- alternative
  what:define(nil, chimera)
  assert(what(a) == "cat")
  what:define(nil, cat)
  assert(what(a) == "dog")
  what:define(nil, dog)
  assert(what(a) == "animal")
  assert(what:call(a) == "animal") -- alternative
  assert(what:resolve(chimera)(a) == "animal") -- alternative
end
do -- Test generator.
  local unpack = table.unpack or unpack
  local count = xtype.multifunction()
  count:addGenerator(function(self, ...)
    local sign = {...}
    self:define(function() return #sign end, unpack(sign))
  end)
  -- checks
  assert(count() == 0)
  assert(count(1, 2, 3) == 3)
  assert(count("a", "b", "c") == 3)
  assert(count(nil, nil, nil) == 3)
  assert(count(1, nil, "c") == 3)
  -- check low-level API
  for hash, def in pairs(count.definitions) do
    assert(hash == count:hashSign(def.sign))
    assert(#def.sign == def.f())
  end
end
