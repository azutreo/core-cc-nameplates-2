local RootGroup = script:GetCustomProperty("RootGroup"):WaitForObject()

local UserInterface = script:GetCustomProperty("UserInterface"):WaitForObject()
local NameplatesPanel = UserInterface:GetCustomProperty("NameplatesPanel"):WaitForObject()

local PlayerHeadTemplate = script:GetCustomProperty("PlayerHeadTemplate")

local NameplateTemplate = RootGroup:GetCustomProperty("Template")

local OFFSET = RootGroup:GetCustomProperty("Offset")

local playerNameplates = {}

local function CreateNameplate(player)
	local panel = World.SpawnAsset(NameplateTemplate, {
		parent = NameplatesPanel
	})
	panel.name = player.name

	panel.visibility = Visibility.INHERIT

	table.insert(playerNameplates, {
		player = player,
		panel = panel
	})
end

local function UpdatePlayerNameplatePosition(playerNameplate)
	local player = playerNameplate.player

	local playerEquipment = player:GetEquipment()

	local headEquipment
	for _, equipment in pairs(playerEquipment) do
		if equipment.name == "ChatBubbles_Head" then
			headEquipment = equipment
			break
		end
	end

	if not headEquipment then
		return
	end

	local cube = headEquipment:GetCustomProperty("Cube"):WaitForObject()

	local screenPosition = UI.GetScreenPosition(cube:GetWorldPosition() + Vector3.New(0, 0, OFFSET))

	local panel = playerNameplate.panel
	panel.x = screenPosition.x
	panel.y = screenPosition.y
end

local function OnPlayerJoined(player)
	local equipment = World.SpawnAsset(PlayerHeadTemplate)
	equipment:Equip(player)

	CreateNameplate(player)
end

local function OnPlayerLeft(player)
	if not playerNameplates[player] then
		return
	end

	playerNameplates[player].panel:Destroy()
	playerNameplates[player] = nil
end

function Tick()
	for _, playerNameplate in ipairs(playerNameplates) do
		UpdatePlayerNameplatePosition(playerNameplate)
	end
end

Game.playerJoinedEvent:Connect(OnPlayerJoined)
Game.playerLeftEvent:Connect(OnPlayerLeft)