
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= ""
ENT.Author			= "FiLzO"
ENT.Information		= ""
ENT.Category		= ""

ENT.Spawnable		= false
ENT.AdminOnly		= false
ENT.Occupied        = false

if SERVER then

function ENT:Initialize()
	
	self:SetModel("models/hunter/plates/plate.mdl")
	self:SetModelScale( 1.2, 0 )
	self:SetNoDraw(false)
	self:DrawShadow(false)
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	--self:SetMaterial("Models/effects/vol_light001")
	local self_name = "defensestation" .. self:EntIndex()
	self:SetName(self_name)
	
end

----------------------------------------

----------------------------------------
function ENT:Think()

end

function ENT:OnRemove()

end
end