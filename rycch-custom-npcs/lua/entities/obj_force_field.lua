AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
    end
end

function ENT:Initialize()
    self:SetModel( "models/hunter/tubes/tube4x4x2d.mdl" )
    self:SetMoveType( MOVETYPE_NOCLIP )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WORLD ) 
    self:SetRenderMode(RENDERGROUP_TRANSLUCENT)
    self:SetMaterial('models/props_combine/portalball001_sheet')
end

function ENT:Think() 
    self:SetAngles(Angle(0,0,0))
    self:SetPos(self:GetParent():GetPos()+Vector(0,0,50))
end

local forceShieldImpactSounds = {
    [1] = "weapons/physcannon/superphys_small_zap1.wav",
    [2] = "weapons/physcannon/superphys_small_zap2.wav",
    [3] = "weapons/physcannon/superphys_small_zap3.wav",
    [4] = "weapons/physcannon/superphys_small_zap4.wav"
}

    
function ENT:OnTakeDamage( dmginfo )
    local damage = dmginfo:GetDamage()
    self:EmitSound(forceShieldImpactSounds[math.random(1,4)], 85)
end