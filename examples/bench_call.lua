-- Benchmark multifunction call.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

local n = ...
n = tonumber(n) or 1e6

local add = xtype.multifunction()
add:define(function(a,b) return a+b end, "number", "number")

local a = 0
for i=1,n do
  a = add(a, 1)
end
assert(a == n)
