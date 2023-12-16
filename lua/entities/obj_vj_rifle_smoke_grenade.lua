-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_grenade_rifle"
ENT.PrintName		= "Rifle Grenade"
ENT.Author 			= "Zippy"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ENT.RadiusDamage = 40

local trail_lifetime = 1.5
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
    self:SetNoDraw(true)

    self.grenadeprop = ents.Create("prop_dynamic")
    self.grenadeprop:SetModel("models/weapons/ar2_grenade.mdl")
    self.grenadeprop:SetPos(self:GetPos())
    self.grenadeprop:SetAngles(self:GetAngles())
    self.grenadeprop:SetParent(self)
    self.grenadeprop:Spawn()

    util.SpriteTrail(self.grenadeprop, 0, Color(50,50,50), true, 12, 0, trail_lifetime, 0.008, "sprites/xbeam2")
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
    self.grenadeprop:SetAngles(self:GetVelocity():Angle())
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects()
    self:EmitSound("CUPsmokeExp.Play")
	local ExplosionLight1 = ents.Create("cup_smoke_nade")
    ExplosionLight1:SetPos(self:GetPos())
	ExplosionLight1:Spawn()
	ExplosionLight1:Activate()

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------