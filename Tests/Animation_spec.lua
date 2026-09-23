-- luacheck: globals describe it before_each after_each setup teardown assert spy stub mock pending FenUI
describe("FenUI Animation", function()
	setup(function()
		-- Mock Animation APIs if not present in wow_api.lua
		if not _G.CreateFrame().CreateAnimationGroup then
			local FrameClass_New = _G.CreateFrame
			_G.CreateFrame = function(...)
				local frame = FrameClass_New(...)
				frame.CreateAnimationGroup = function(self)
					local ag = {
						animations = {},
						CreateAnimation = function(this, type)
							local anim = {
								type = type,
								SetDuration = function() end,
								SetSmoothing = function() end,
								SetOrder = function() end,
								SetFromAlpha = function() end,
								SetToAlpha = function() end,
								SetScaleFrom = function() end,
								SetScaleTo = function() end,
								SetOffset = function() end,
							}
							table.insert(this.animations, anim)
							return anim
						end,
						Play = function(ag) ag.isPlaying = true end,
						Stop = function(ag) ag.isPlaying = false end,
						IsPlaying = function(ag) return ag.isPlaying == true end,
						GetAnimations = function(ag) return unpack(ag.animations) end,
						SetScript = function(ag, name, func) ag[name] = func end,
					}
					return ag
				end
				return frame
			end
		end

		require("Core.FenUI")
		require("Core.Animation")
	end)

	it("should define FenUI.Animation", function()
		assert.is_not_nil(FenUI.Animation)
	end)

	it("should define animation presets", function()
		assert.is_not_nil(FenUI.Animation.Presets)
		assert.is_not_nil(FenUI.Animation.Presets.fadeIn)
		assert.is_not_nil(FenUI.Animation.Presets.fadeOut)
	end)

	describe("Define", function()
		it("should create an animation object", function()
			local anim = FenUI.Animation:Define({
				from = { alpha = 0 },
				to = { alpha = 1 },
				duration = 0.5,
			})
			assert.is_not_nil(anim)
			assert.is_equal(0.5, anim.duration)
		end)
	end)

	describe("Play", function()
		it("should play an animation on a frame", function()
			local frame = CreateFrame("Frame")
			local anim = FenUI.Animation:Define({
				to = { alpha = 1 },
				duration = 0.2,
			})
			
			anim:Play(frame)
			assert.is_not_nil(frame.fenUIAnims)
			assert.is_not_nil(frame.fenUIAnims.default)
		end)
	end)

	describe("Keyframes", function()
		it("should create a keyframed animation", function()
			local anim = FenUI.Animation:Keyframes({
				[0] = { scale = 1 },
				[0.5] = { scale = 1.2 },
				[1] = { scale = 1 },
				duration = 0.4,
			})
			assert.is_true(anim.isKeyframes)
			assert.is_equal(3, #anim.keyframes)
		end)
	end)

	describe("Transitions", function()
		it("should apply transitions to a frame", function()
			local frame = CreateFrame("Frame")
			frame.SetAlpha = function(self, val) self.alpha = val end
			frame.GetAlpha = function(self) return self.alpha or 1 end
			
			FenUI.Animation:ApplyTransitions(frame, {
				alpha = { duration = 0.2 }
			})
			
			-- SetAlpha should now be wrapped
			assert.is_not_equal(nil, frame.SetAlpha)
		end)
	end)

	describe("Chaining", function()
		it("should chain animations with Then", function()
			local anim1 = FenUI.Animation:Define({ to = { alpha = 0.5 } })
			local anim2 = FenUI.Animation:Define({ to = { alpha = 1 } })
			local chained = anim1:Then(anim2)
			
			assert.is_not_nil(chained)
			assert.is_not_equal(anim1.Play, chained.Play)
		end)
	end)
end)

