AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if IsValid(self:GetOwner()) then
		self:SetModel(self:GetOwner():GetModel())
	else
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	end
end