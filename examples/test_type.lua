-- Test type creation and inheritance.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

local being = xtype.create("being")
local animal = xtype.create("animal", being)
local mammal = xtype.create("mammal", animal)
local carnivorous = xtype.create("carnivorous")
local omnivorous = xtype.create("omnivorous")
local hominidae = xtype.create("hominidae", mammal, omnivorous)
local canidae = xtype.create("canidae", mammal, carnivorous)
local human = xtype.create("human", hominidae)
local dog = xtype.create("dog", canidae)
local chimera = xtype.create("chimera", human, dog)

local Nina = setmetatable({}, {xtype = human})
local Alexander = setmetatable({}, {xtype = dog})
local Chimera = setmetatable({}, {xtype = chimera})

assert(xtype.get(0) == "number")
assert(xtype.is(0, "number"))
assert(not xtype.is(0, "string"))
assert(xtype.get(being) == "xtype")
assert(xtype.of(being, being))

assert(xtype.of(animal, being))
assert(xtype.of(mammal, being))
assert(xtype.of(mammal, animal))
assert(xtype.of(canidae, mammal))
assert(xtype.of(canidae, being))
assert(xtype.of(canidae, carnivorous))
assert(xtype.of(dog, canidae))
assert(xtype.of(human, hominidae))
assert(not xtype.of(human, dog))

assert(xtype.is(Nina, human))
assert(xtype.is(Alexander, dog))
assert(xtype.is(Chimera, human))
assert(xtype.is(Chimera, dog))
