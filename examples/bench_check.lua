-- Benchmark type checking.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

local n = ...
n = tonumber(n) or 1e7

local T = xtype.create("T")
local t = setmetatable({}, {xtype = T})

local a
for i=1,n do
  a = xtype.is(T, "xtype") and xtype.is(t, T) and xtype.is(i, "number")
end
assert(a)
