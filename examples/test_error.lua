-- Test errors.
package.path = "src/?.lua;"..package.path
local xtype = require("xtype")

-- Expect an error.
local function check(f)
  local ok, err = pcall(f)
  assert(not ok)
  print("[checked]", err)
end

check(function() xtype.create() end)
check(function() xtype.create(5) end)

local mf = xtype.multifunction()
check(function() mf:define(function() end, nil) end)
check(function() mf:define(function() end, 1) end)
check(function() mf:define(nil, "number", nil, "number") end)
mf:define(function() end, "number", "number")
check(function() mf() end)
check(function() mf(5) end)
check(function() mf(5, 5, 5) end)
check(function() mf(5, "5") end)
mf:define(nil, "number", "number")
check(function() mf(5, 5) end)

