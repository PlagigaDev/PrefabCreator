local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Studio = settings():GetService("Studio")

local root = script.Parent
local GUI = root.GUI
local MainGui: Frame = GUI.MainGui

local PrefabListHolder: Frame = MainGui.PrefabListHolder
local PrefabTemplate: Frame = PrefabListHolder.PrefabTemplate
local PrefabList: ScrollingFrame = PrefabListHolder.PrefabList

local Options: Frame = MainGui.Options
local AddPrefabButton: TextButton = Options.AddPrefab

local SearchFrame: Frame = MainGui.Search
local SearchBar: TextBox = SearchFrame.SearchBar

local toolbar = plugin:CreateToolbar("Prefab Plugin")
local prefabMenuButton = toolbar:CreateButton("Prefab Menu", "Open your Prefabs", "rbxassetid://4458901886")

local Theme = Studio.Theme

local mouse = plugin:GetMouse()
local pointCursor = "rbxasset://SystemCursors/PointingHand"
local normalCursor = "rbxasset://SystemCursors/Arrow"

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right,false,false,300,500,150,200)

local widgetGui = plugin:CreateDockWidgetPluginGui("Prefab Menu",widgetInfo)
widgetGui.Title = "Prefab Menu"

--#region ColorChange functions
local function changeTextColor(value: GuiBase)
	value.TextColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
end

local function changeBackGroundColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
end

local function changeButtonColor(value: GuiBase)
	value.BackgroundColor3 = Theme:GetColor(Enum.StudioStyleGuideColor.MainButton)
end

local function changeToPointIconOnHover(value: GuiBase)
	value.MouseEnter:Connect(function()
		mouse.Icon = pointCursor
	end)
	value.MouseLeave:Connect(function()
		mouse.Icon = normalCursor
	end)
end

local function changeColor()
	changeBackGroundColor(MainGui)
	
	for _, value in MainGui:GetDescendants() do
		if not value:IsA("GuiBase") then continue end
		changeBackGroundColor(value)
		if value:IsA("TextLabel") or value:IsA("TextBox") then
			changeTextColor(value)
		elseif value:IsA("TextButton") then
			changeTextColor(value)
			changeButtonColor(value)
			changeToPointIconOnHover(value)
		end
	end
end
--#endregion
changeColor()
MainGui.Parent = widgetGui

AddPrefabButton.MouseButton1Click:Connect(function()
	local selected: Instance = Selection:Get()
	if #selected > 1 then
		warn("You can only turn a single model instance into a prefab at once")
	end
	selected = selected[1]
	if selected and not selected:IsA("Model") then
		error("No model Selected. You must first select a model to add it")
		return
	end

	local PrefabModel: Model = selected:Clone()
	local PrefabListEntry: Frame = PrefabTemplate:Clone()
	PrefabListEntry.NameText.Text = PrefabModel.Name
	PrefabModel.Name = "Model"
	local modelView: ViewportFrame = PrefabListEntry.ModelView
	PrefabModel.Parent = modelView
	local cam: Camera = modelView.Camera
	modelView.CurrentCamera = cam
	local position, size = PrefabModel:GetBoundingBox()
	cam.CFrame = position * CFrame.new(position.LookVector * size.Z*2) * CFrame.new(position.UpVector * size.Y * .5)
	cam.CFrame = CFrame.lookAt(cam.CFrame.Position, position.Position)
	PrefabListEntry.Parent = PrefabList
	PrefabListEntry.Visible = true
end)

-- we just want to have the last open state set again
do 
	local isOn = plugin:GetSetting("WidgetEnabled") or false
	widgetGui.Enabled = isOn
	prefabMenuButton:SetActive(isOn)
end

prefabMenuButton.Click:Connect(function()
	local isOn = not widgetGui.Enabled
	prefabMenuButton:SetActive(isOn)
	widgetGui.Enabled = isOn
	plugin:SetSetting("WidgetEnabled", isOn)
end)


