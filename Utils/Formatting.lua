--------------------------------------------------------------------------------
-- FenUI.Utils.Formatting
-- FenUI-specific formatting utilities (standalone, no external dependencies).
--------------------------------------------------------------------------------

local Utils = FenUI.Utils

--- Formats a duration in seconds to "Xm Ys" or more robust formats.
--- Uses WoW's SecondsFormatter when available.
---@param seconds number
---@param useRoyal boolean? If true, tries to use Midnight SecondsFormatter
---@return string formatted
function Utils:FormatDuration(seconds, useRoyal)
	if seconds == nil then
		return ""
	end

	if useRoyal and self.Cap and self.Cap.HasSecondsFormatter then
		if not self.formatter then
			self.formatter = _G.CreateSecondsFormatter()
			if self.formatter then
				self.formatter:SetMinimumComponents(1)
			end
		end
		if self.formatter then
			return self.formatter:Format(seconds)
		end
	end

	-- Standard formatting
	if seconds >= 3600 then
		return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
	elseif seconds >= 60 then
		return string.format("%dm %ds", math.floor(seconds / 60), math.floor(seconds % 60))
	end
	return string.format("%.1fs", seconds)
end

--- Sanitizes text for Blizzard SetText calls, handling AceLocale 'true' values.
---@param text any
---@param fallback string?
---@return string|number sanitized
function Utils:SanitizeText(text, fallback)
	if text == true then
		return fallback or ""
	end
	if text == nil then
		return fallback or ""
	end
	-- Blizzard SetText accepts strings and numbers
	if type(text) == "string" or type(text) == "number" then
		return text
	end
	return tostring(text)
end

--- Formats a value for display, handling tables with color codes.
--- Secret detection uses WoW's issecretvalue API when available.
---@param value any The value to format
---@param options table? {fields: string[], plain: boolean, maxDepth: number, maxItems: number}
---@return string formatted
function Utils:FormatValue(value, options)
	options = options or {}
	local maxDepth = options.maxDepth or 3
	local maxItems = options.maxItems or 20

	-- Use WoW's issecretvalue API if available (Midnight+)
	local function isSecret(val)
		if _G.issecretvalue then
			local ok, secret = pcall(_G.issecretvalue, val)
			return ok and (secret == true)
		end
		return false
	end

	local function serialize(val, depth)
		if val == nil then
			return "nil"
		end

		local valIsSecret = isSecret(val)
		local secretTag = valIsSecret and (options.plain and " (SECRET)" or " |cffaa00ff(SECRET)|r") or ""

		if type(val) == "table" then
			if next(val) == nil then
				return "{...}" -- Handle empty table
			end

			if depth >= maxDepth then
				return options.plain and "{...}" or "|cff888888{...}|r"
			end

			local parts = {}
			if not options.plain then
				table.insert(parts, "{")
			end

			local count = 0
			for k, v in pairs(val) do
				count = count + 1
				if count > maxItems then
					table.insert(parts, "  ...")
					break
				end

				local fieldSecret = isSecret(v)
				local fieldSecretTag = fieldSecret and (options.plain and " (SECRET)" or " |cffaa00ff(SECRET)|r") or ""
				table.insert(parts, string.format("  .%s = %s%s", tostring(k), serialize(v, depth + 1), fieldSecretTag))
			end

			if not options.plain then
				table.insert(parts, "}")
				return table.concat(parts, "\n")
			else
				return string.format("{\n%s\n  }", table.concat(parts, "\n"))
			end
		end

		return string.format("%s%s", tostring(val), secretTag)
	end

	return serialize(value, 0)
end
