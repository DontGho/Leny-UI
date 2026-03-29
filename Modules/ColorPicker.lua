local ColorPicker = {}
ColorPicker.__index = ColorPicker

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

print("UPDATED 3")
function ColorPicker.new(context: table)
	local self = setmetatable(context, ColorPicker)
	self.sliderDragging = false
	self.hsvDragging = false
	self._inputDown = false
	return self
end

function ColorPicker:updateAssetsColors()
	local color = Color3.fromHSV(self.H, self.S, self.V)
	self.HSV.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
	self.Submit.Background.BackgroundColor3 = color
	self.Hex.Text = color:ToHex()
	self.RGB.Text = string.format("%d, %d, %d", color.R * 255, color.G * 255, color.B * 255)
end

function ColorPicker:updateDragPositions()
	self.Slider.Drag.Position = UDim2.new(self.H, 0, 0.5, 0)
	self.HSV.Drag.Position = UDim2.new(self.S, 0, 1 - self.V, 0)
end

function ColorPicker:handleColorPicker()
	self:updateColor({ color = self.color })

	self.Slider.TextButton.MouseButton1Down:Connect(function()
		self.sliderDragging = true
		self._inputDown = true
	end)

	self.HSV.TextButton.MouseButton1Down:Connect(function()
		self.hsvDragging = true
		self._inputDown = true
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.sliderDragging = false
			self.hsvDragging = false
			self._inputDown = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not self._inputDown then
			return
		end

		local mousePos = UserInputService:GetMouseLocation()

		if self.sliderDragging then
			local percentX =
				math.clamp((mousePos.X - self.Slider.AbsolutePosition.X) / self.Slider.AbsoluteSize.X, 0, 1)
			self.H = percentX
			self.Slider.Drag.Position = UDim2.new(percentX, 0, 0.5, 0)
			self:updateAssetsColors()
		end

		if self.hsvDragging then
			local percentX = math.clamp((mousePos.X - self.HSV.AbsolutePosition.X) / self.HSV.AbsoluteSize.X, 0, 1)
			local percentY = math.clamp((mousePos.Y - self.HSV.AbsolutePosition.Y) / self.HSV.AbsoluteSize.Y, 0, 1)
			self.S = percentX
			self.V = 1 - percentY
			self:updateAssetsColors()
			self:updateDragPositions()
		end
	end)

	self.Hex.FocusLost:Connect(function()
		if string.match(self.Hex.Text, "^%x%x%x%x%x%x$") then
			self.H, self.S, self.V = Color3.fromHex(self.Hex.Text):ToHSV()
		end
		self:updateAssetsColors()
		self:updateDragPositions()
	end)

	self.RGB.FocusLost:Connect(function()
		local r, g, b = string.match(self.RGB.Text, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
		if r then
			r, g, b = math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255)
			self.H, self.S, self.V = Color3.fromRGB(r, g, b):ToHSV()
		end
		self:updateAssetsColors()
		self:updateDragPositions()
	end)

	self.Submit.TextLabel.TextButton.MouseButton1Down:Connect(function()
		local color = Color3.fromHSV(self.H, self.S, self.V)
		self.Background.BackgroundColor3 = color
		self.color = color
		self.submitAnimation()
		self.callback(color)
	end)

	self.Submit.TextLabel.MouseEnter:Connect(self.hoveringOn)
	self.Submit.TextLabel.MouseLeave:Connect(self.hoveringOff)
end

function ColorPicker:updateColor(options: table)
	self.color = options.color or Color3.fromRGB(255, 255, 255)
	self.H, self.S, self.V = self.color:ToHSV()
	self:updateAssetsColors()
	self:updateDragPositions()
	self.Background.BackgroundColor3 = self.color
	self.callback(self.color)
end

return ColorPicker
