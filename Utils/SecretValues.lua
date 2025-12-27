--------------------------------------------------------------------------------
-- FenUI.Utils.SecretValues
-- Midnight (12.0) secret value detection and guards.
--------------------------------------------------------------------------------

local Utils = FenUI.Utils

--- Check if a value is a Midnight secret value.
---@param value any
---@return boolean isSecret
function Utils:IsValueSecret(value)
	if not self.IS_MIDNIGHT then
		return false
	end
	if value == nil then
		return false
	end

	-- Official checker
	if _G.issecretvalue then
		local ok, secret = pcall(_G.issecretvalue, value)
		return ok and (secret == true)
	end

	-- Fallback: Check types that can be secret
	local t = type(value)
	if t ~= "number" and t ~= "string" and t ~= "userdata" and t ~= "table" then
		return false
	end

	-- Robust fallback: pcall a blocked operation
	local ok = pcall(function()
		local _ = tostring(value)
	end)

	return not ok
end

--- Counts secret values within a table (shallow or recursive).
---@param tbl table
---@param recursive boolean?
---@return number count
function Utils:CountSecrets(tbl, recursive)
	local count = 0
	if not tbl or type(tbl) ~= "table" then
		return 0
	end

	for _, v in pairs(tbl) do
		if self:IsValueSecret(v) then
			count = count + 1
		elseif recursive and type(v) == "table" then
			count = count + self:CountSecrets(v, true)
		end
	end
	return count
end
