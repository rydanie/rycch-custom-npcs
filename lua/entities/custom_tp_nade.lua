
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Teleport Nade"
ENT.Author			= "FiLzO"
ENT.Purpose			= "Can you feel Air Exchange?"
ENT.Category		= "Combine Units +PLUS+"

ENT.Spawnable		= false
ENT.AdminOnly		= false

if SERVER then

function ENT:Initialize()
self:SetModel("models/weapons/tpnade.mdl")
self:SetMaterial("models/props_lab/xencrystal_sheet.vmt")
self:PhysicsInit( SOLID_VPHYSICS )
self:SetMoveType( MOVETYPE_VPHYSICS )
self:SetSolid( SOLID_VPHYSICS )
self:DrawShadow( false )
self:SetCollisionGroup( COLLISION_GROUP_WEAPON )	
self:SetOwner(self.Owner)
util.SpriteTrail(self, 0, Color(255,120,0,255), false, 12, 0, 0.5, 0, "trails/plasma.vmt");
local phys = self:GetPhysicsObject()	
if (phys:IsValid()) then
	phys:Wake()
	phys:SetMaterial("metal")
	--phys:SetMass(1000)
end	
local self_name = "smokenade" .. self:EntIndex()
self:SetName( self_name )
end

function ENT:EatThis(ent)
if IsValid(ent) then
if (ent:IsPlayer() or ent:IsNPC()) and self:Visible(ent) and ent:GetPos():Distance(self:GetPos()) <= 100 then
if ent:GetClass()=="npc_combine_s" or ent:GetClass()=="npc_metropolice" or ent:GetClass()=="npc_cscanner" or ent:GetClass()=="npc_manhack" or ent:GetClass()=="npc_stalker" or ent:GetClass()=="npc_strider" or ent:GetClass()=="npc_hunter" or ent:GetClass()=="npc_helicopter" or ent:GetClass()=="npc_combinegunship" or ent:GetClass()=="npc_combinedropship" or ent:GetClass()=="npc_turret_floor" or ent:GetClass()=="npc_turret_ceiling" or ent:GetClass()=="npc_rollermine" then return end
if ent.wearsuit == true then return end
local puff = ents.Create("env_entity_dissolver")
puff:SetKeyValue("dissolvetype", "2")
puff:SetKeyValue("magnitude","1")
puff:SetPos(ent:GetPos())
puff:SetOwner(self.Owner)
puff:Spawn()
local name = "Dissolving_"..self:EntIndex()..math.random(1,999)..ent:EntIndex()
ent:SetName(name)
puff:Fire("Dissolve",name,0)
puff:Fire("kill","",0.01)	
elseif (ent:IsPlayer() or ent:IsNPC()) and self:Visible(ent) and (ent:GetPos():Distance(self:GetPos()) <= 200 and ent:GetPos():Distance(self:GetPos()) > 100) then
if ent:GetClass()=="npc_combine_s" or ent:GetClass()=="npc_metropolice" or ent:GetClass()=="npc_cscanner" or ent:GetClass()=="npc_manhack" or ent:GetClass()=="npc_stalker" or ent:GetClass()=="npc_strider" or ent:GetClass()=="npc_hunter" or ent:GetClass()=="npc_helicopter" or ent:GetClass()=="npc_combinegunship" or ent:GetClass()=="npc_combinedropship" or ent:GetClass()=="npc_turret_floor" or ent:GetClass()=="npc_turret_ceiling" or ent:GetClass()=="npc_rollermine" then return end
if ent.wearsuit == true then return end
ent:TakeDamage(math.random(20,40), self.Owner, self)
end
end
end

function ENT:Think()
if self.TimerExplode == 1 then
if self.Sound == nil or self.Sound == false then
self.Sound = true
if IsValid(self.Owner) and self:GetVelocity():Length() < 20 and self:WaterLevel() <= 1 then
for k,v in pairs (ents.GetAll()) do
self:EatThis(v)
end

self.portal = ents.Create("env_citadel_energy_core")
self.portal:SetPos( self:GetPos() + Vector(0,0,40) )
self.portal:SetOwner( self.Owner )
self.portal:SetKeyValue( "scale", "5" )
--self.portal:SetParent(self)
self.portal:Spawn()
self.portal:Activate()
self.portal:Fire( "StartCharge", 0.1, 0 )
self.portal:Fire( "Stop","", 0.5 )

self.calleffect = EffectData()
self.calleffect:SetStart( self.Owner:GetPos() )
self.calleffect:SetOrigin( self.Owner:GetPos() )
self.calleffect:SetMagnitude(1)
self.calleffect:SetEntity( self.Owner )
util.Effect( "propspawn", self.calleffect )
self:EmitSound("SYNTHnade.CUP")
self.Owner:SetPos(self:GetPos() + Vector(0,0,5))
elseif (!IsValid(self.Owner)) or self:GetVelocity():Length() >= 20 or self:WaterLevel() > 1 then
self:EmitSound("SYNTHnadeNope.CUP")
end
self:Remove()
end

end
end

function ENT:PhysicsCollide(data,phys)
local nobounce = -data.Speed * data.HitNormal * -1 + (data.OurOldVelocity * -0)
phys:ApplyForceCenter(nobounce)
local phys = self:GetPhysicsObject()	
timer.Simple(2, function()
self.TimerExplode = 1
end)
if data.Speed > 50 then
if ( IsMounted( "ep2" ) ) then
end
self:EmitSound("CUPsmokeHit.Play")
end
end

end
