
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= ""
ENT.Author			= "FiLzO"
ENT.Information		= ""
ENT.Category		= ""

ENT.Spawnable		= false
ENT.AdminOnly		= false

if SERVER then

function ENT:Initialize()
	
	self:SetModel("models/props_combine/combine_light001a.mdl")
	self:SetModelScale( 1.2, 0 )
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self.GiveAmmo = false
	self.GiveArmor = false
	self.GiveHealth = false
	self.GiveHealthNPC = false
	self.NoAmmo = false
	self.NoLag = false
	self.DontBeFast = false
	self:EmitSound("DispenserDeploy.CUP")
	self:EmitSound("DispenserLoop.CUP")
	local self_name = "defensestation" .. self:EntIndex()
	self:SetName(self_name)
	self:SetHealth(100)
	self:SetMaxHealth(self:Health())
	
	local selfpos = self:GetPos() + self:GetForward() * -2 + self:GetRight() * -3.5 + self:GetUp() * 46
	self.turret = ents.Create( "npc_turret_ceiling" )
	self.turret:SetModelScale( 0.22, 0 )
	self.turret:SetPos(selfpos)
	self.turret:SetAngles(self:GetAngles() + Angle(180,0,90))
	self.turret:SetNotSolid(true)
	self.turret:SetKeyValue( "spawnflags", "32" + "2" )
	self.turret:SetKeyValue( "squadname", "Overwatch" )
	self.turret:SetParent(self)
	self.turret:Spawn()
	self.turret:Activate()
	self.turret.CupTurret = true
	if IsValid(self.turret) then
	self.turret:SetHealth(999999)
	self.turret:SetMaxHealth(999999)
	end
	
	local selfpos2 = self:GetPos() + self:GetForward() * -2 + self:GetRight() * 3.5 + self:GetUp() * 46
	self.turret2 = ents.Create( "npc_turret_ceiling" )
	self.turret2:SetModelScale( 0.22, 0 )
	self.turret2:SetPos(selfpos2)
	self.turret2:SetAngles(self:GetAngles() + Angle(180,0,-90))
	self.turret2:SetNotSolid(true)
	self.turret2:SetKeyValue( "spawnflags", "32" + "2" )
	self.turret2:SetKeyValue( "squadname", "Overwatch" )
	self.turret2:SetParent(self)
	self.turret2:Spawn()
	self.turret2:Activate()
	self.turret2.CupTurret = true
	if IsValid(self.turret2) then
	self.turret2:SetHealth(999999)
	self.turret2:SetMaxHealth(999999)
	end
	
	self.turret2:SetOwner(self)
	self.turret:SetOwner(self)
		
	local FlashBase = ents.Create("env_projectedtexture")
	FlashBase:SetParent(self)
	FlashBase:SetPos(self:GetPos() + Vector(0,0,25))
	FlashBase:SetAngles(self:GetAngles() + Angle(180,0,0))
	FlashBase:SetKeyValue('lightcolor', "147 226 240")
	FlashBase:SetKeyValue('lightfov', '50')
	FlashBase:SetKeyValue('farz', '512')
	FlashBase:Spawn()
	FlashBase:Activate()
	
end

function ENT:Relations(ent)
if IsValid(ent) then
local AttackMe = ent:GetEnemy()
if IsValid(AttackMe) then
if AttackMe:IsNPC() then
AttackMe:AddEntityRelationship( ent, D_HT, 99 )
end
end
for _, enemy in pairs( ents.GetAll() ) do
if ( C_RELATIONS:GetInt() == 1 ) then
self.Format2 = false
if enemy:IsPlayer() then
ent:AddEntityRelationship( enemy, D_LI, 99 )
end
end
if ( C_RELATIONS:GetInt() == 0 ) then
if enemy:IsPlayer() then
if self.Format2 == false or self.Format2 == nil then
self.Format2 = true
ent:ClearEnemyMemory()
ent:AddEntityRelationship( enemy, D_HT, 99 )
end
end
end
end
end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())
end
----------------------------------------
function ENT:HealAlly(ent)
if IsValid(ent) then
if (ent:Health() > ent:GetMaxHealth() * 1.0) then
ent:SetHealth(ent:GetMaxHealth())
end
if((ent:IsPlayer() or ent:IsNPC()) and self.turret:Disposition(ent) != D_HT and ent:Health() < ent:GetMaxHealth()) then
if self.GiveHealth == false then
self.GiveHealth = true
need = math.min( ent:GetMaxHealth() - ent:Health(), 5 )-- Dont overheal
ent:SetHealth( math.min( ent:GetMaxHealth(), ent:Health() + need ) )
if ent.Juggernaut == true then
ent:SetHealth( math.min( ent:GetMaxHealth(), ent:Health() + need + 15 ) )
end
ent:EmitSound("DispenserHealth.CUP")
self.healeffect = EffectData()
self.healeffect:SetStart( ent:GetPos() )
self.healeffect:SetOrigin( ent:GetPos() )
self.healeffect:SetMagnitude(1)
self.healeffect:SetEntity( ent )
util.Effect( "phys_unfreeze", self.healeffect )
timer.Simple(0.7, function()
self.GiveHealth = false
end)
end
end
end
end
----------------------------------------
function ENT:GiveAmmoTo(ent)
if IsValid(ent) then
if(ent:IsPlayer() and ent:Alive()) and self.turret:Disposition(ent) != D_HT then
if (ent:IsPlayer() and ent:GetActiveWeapon():GetClass()=="weapon_physcannon" or ent:GetActiveWeapon():GetClass()=="weapon_physgun" or ent:GetActiveWeapon():GetClass()=="gmod_tool" or ent:GetActiveWeapon():GetClass()=="weapon_medkit" or ent:GetActiveWeapon():GetClass()=="weapon_empty_hands" or ent:GetActiveWeapon():GetClass()=="gmod_camera" or ent:GetActiveWeapon():GetClass()=="selfportrait_camera" or ent:GetActiveWeapon():GetClass()=="weapon_fists" or ent:GetActiveWeapon():GetClass()=="weapon_crowbar" or ent:GetActiveWeapon():GetClass()=="weapon_stunstick" or ent:GetActiveWeapon():GetClass()=="weapon_bugbait" or ent:GetActiveWeapon():GetClass()=="weapon_rpg" or ent:GetActiveWeapon():GetClass()=="weapon_engineer_turret") then
self.NoAmmo = true
else
self.NoAmmo = false
end
local activewep = ent:GetActiveWeapon()
local activeammo = activewep:GetPrimaryAmmoType()
local activeammoA = ent:GetAmmoCount(activewep:GetPrimaryAmmoType())
if activeammoA < 120 and activeammoA >= 0 and self.NoAmmo == false then
if self.GiveAmmo == false then
self.GiveAmmo = true
ent:EmitSound("DispenserAmmo.CUP")
ent:GiveAmmo(15, activeammo)
timer.Simple(1, function()
self.GiveAmmo = false
end)
end
end
end
end
end
----------------------------------------
function ENT:GiveArmorTo(ent)
if IsValid(ent) then
if(ent:IsPlayer() and ent:Armor() > 100) then
ent:SetArmor(100)
end
if(ent:IsPlayer() and ent:Alive()) and ent:Armor() < 100 and self.turret:Disposition(ent) == D_LI then
if self.GiveArmor == false then
self.GiveArmor = true
ent:EmitSound("DispenserArmor.CUP")
ent:SetArmor(ent:Armor() + 5)
timer.Simple(1, function()
self.GiveArmor = false
end)
end
end
end
end
----------------------------------------
function ENT:BeepImHere(ent)
if IsValid(ent) then
if self.DontBeFast == false then
self.DontBeFast = true
self.engineeffect = EffectData()
self.engineeffect:SetStart( ent:GetPos() )
self.engineeffect:SetOrigin( ent:GetPos() + Vector(0,0,0) )
--self.engineeffect:SetAngles( ent:GetAngles() + Angle(0,90,0) )
self.engineeffect:SetMagnitude(1)
self.engineeffect:SetEntity( ent )
util.Effect( "TeslaHitBoxes", self.engineeffect )
timer.Simple(2, function() 
self.DontBeFast = false
end)
end
end
end
----------------------------------------

----------------------------------------
function ENT:Think()
for k,v in pairs (ents.GetAll()) do
if v:GetPos():Distance(self:GetPos()) < 220 then
self:HealAlly(v)
self:GiveAmmoTo(v)
self:GiveArmorTo(v)
end
end
self:BeepImHere(self)
if IsValid(self.turret) then
self:Relations(self.turret)
end
if IsValid(self.turret2) then
self:Relations(self.turret2)
end
if self:Health() <= 0 then
self:StopSound("DispenserLoop.CUP")
self:EmitSound("ambient/energy/power_off1.wav", 100, 100)

local explo = ents.Create( "env_explosion" )
explo:SetOwner( self.Owner )
explo:SetPos( self:GetPos() )
explo:SetKeyValue( "iMagnitude", "40" )
explo:Spawn()
explo:Activate()
explo:Fire( "Explode", "", 0 )

self.fire = ents.Create( "env_fire" )
self.fire:SetPos( self.Entity:GetPos() )
self.fire:SetKeyValue( "health", "12" )
self.fire:SetKeyValue( "firesize", "50" )
self.fire:SetKeyValue( "fireattack", "8" )
self.fire:SetKeyValue( "damagescale", "3.0" )
self.fire:SetKeyValue( "StartDisabled", "0" )
self.fire:SetKeyValue( "firetype", "0" )
self.fire:SetKeyValue( "spawnflags", "132" )
self.fire:Spawn()
self.fire:Fire( "StartFire", "", 0.2 )

self.wreck = ents.Create("prop_dynamic")
self.wreck:SetModel(self:GetModel())
self.wreck:SetModelScale( 1.2, 0 )
self.wreck:SetPos( self:GetPos() + Vector(0,0,math.random(-5,-10)) )
self.wreck:SetAngles( self:GetAngles() + Angle(math.random(-15,15),math.random(-15,15),math.random(-15,15)) )
self.wreck:SetCollisionGroup(COLLISION_GROUP_WEAPON)
self.wreck:SetOwner( self.Owner )
self.wreck:Spawn()
self.wreck:Activate()
self.wreck:Fire("ignite")
SafeRemoveEntityDelayed(self.wreck,15)

local phys2 = self.wreck:GetPhysicsObject()	
	if (phys2:IsValid()) then
	phys2:Sleep()
end	

self:Remove()
end
end
function ENT:OnRemove()
	self:StopSound("DispenserLoop.CUP")
	if IsValid (self.turret) then
	self.turret:Remove()
	end
end
end