/*--------------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Hornet"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"

if (CLIENT) then
	local Name = "Hornet"
	local LangName = "obj_bms_hornet"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/Items/AR2_Grenade.mdl"}--"models/weapons/w_hornet.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.MoveCollideType = MOVECOLLIDE_FLY_BOUNCE
ENT.RemoveOnHit = false -- Should it remove itself when it touches something? | It will run the hit sound, place a decal, etc.
ENT.DoesDirectDamage = true -- Should it do a direct damage when it hits something?
ENT.DirectDamage = 3.5 -- How much damage should it do when it hits something
ENT.DirectDamageType = DMG_BULLET--DMG_SLASH -- Damage type
ENT.CollideCodeWithoutRemoving = true -- If RemoveOnHit is set to false, you can still make the projectile deal damage, place a decal, etc.
ENT.DecalTbl_DeathDecals = {"SmallScorch"}
ENT.DecalTbl_OnCollideDecals = {"SmallScorch"} -- Decals that paint when the projectile collides with something | It picks a random one from this table
ENT.SoundTbl_Startup = {"weapons/rpg/shotdown.wav"}--"vj_bms_hornet/single.wav"}
ENT.SoundTbl_Idle = {"weapons/flaregun/burn.wav"}--{"vj_bms_hornet/buzz.wav"}
ENT.SoundTbl_OnCollide = {"physics/flesh/flesh_impact_bullet1.wav"}--{"vj_bms_hornet/bug_impact.wav"}

ENT.IdleSoundPitch = VJ_Set(50, 50)

-- Custom
ENT.MyEnemy = NULL
tracking = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
	phys:Wake()
	phys:SetMass(1)
	phys:SetBuoyancyRatio(0)
	phys:EnableDrag(false)
	phys:EnableGravity(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetModelScale( self:GetModelScale() * .50, 0 )
	timer.Simple(5,function() if IsValid(self) then self:Remove() end end)
	timer.Simple(1,function() tracking = false end)
	
	--util.SpriteTrail(self, 0, Color(255,math.random(50,200),0,120), true, 12, 0, 1, 0.04, "trails/smoke.vmt")--"sprites/vj_bms_hornettrail.vmt")
	util.SpriteTrail(self, 0, Color(206, 187, 168, 150), false, 1, 12, 5, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt")

	local sprite = ents.Create( "env_sprite" )
	sprite:SetKeyValue( "rendercolor","179 220 214" )
	sprite:SetKeyValue( "GlowProxySize","2.0" )
	sprite:SetKeyValue( "HDRColorScale","1.0" )
	sprite:SetKeyValue( "renderfx","14" )
	sprite:SetKeyValue( "rendermode","3" )
	sprite:SetKeyValue( "renderamt","240" )
	sprite:SetKeyValue( "disablereceiveshadows","0" )
	sprite:SetKeyValue( "mindxlevel","0" )
	sprite:SetKeyValue( "maxdxlevel","0" )
	sprite:SetKeyValue( "framerate","10.0" )
	sprite:SetKeyValue( "model","sprites/blueflare1.spr" )
	sprite:SetKeyValue( "spawnflags","0" )
	sprite:SetKeyValue( "scale","0.10" )
	sprite:SetPos( self:GetPos() )
	sprite:Spawn()
	sprite:SetParent(self)
	self:DeleteOnRemove(sprite)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()

	if IsValid(self.MyEnemy) then
		if self:GetPos():Distance(self.MyEnemy:GetPos()) <= 400 then tracking = true else tracking = false  end 
	end

	if IsValid(self.MyEnemy) and tracking == true then -- Homing Behavior
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:CalculateProjectile("Curve", self:GetPos(), self.MyEnemy:GetPos() + self.MyEnemy:OBBCenter() + self.MyEnemy:GetUp()*math.random(-20,20) + self.MyEnemy:GetRight()*math.random(-20,20), 1000))
			self:SetAngles(self:GetVelocity():GetNormal():Angle())
		end
		
	else
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:CalculateProjectile("Curve", self:GetPos(), self:GetPos() + self:GetForward()*math.random(60, 80)+ self:GetRight()*math.random(-3, 3) + self:GetUp()*math.random(-8, 4), 800))
			self:SetAngles(self:GetVelocity():GetNormal():Angle())
		end
	end

end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDoDamage(data,phys,hitent)
	if data.HitEntity:IsNPC() or data.HitEntity:IsPlayer() then
		self:SetDeathVariablesTrue(data,phys)
		self:Remove()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data, phys)
	local lastvel = math.max(data.OurOldVelocity:Length(), data.Speed) -- Get the last velocity and speed
	local newvel = phys:GetVelocity():GetNormal()
	lastvel = math.max(newvel:Length(), lastvel)
	local setvel = newvel * lastvel * 0.3
	phys:SetVelocity(setvel)
	self:SetAngles(self:GetVelocity():GetNormal():Angle())
	self:Remove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	effectdata:SetScale( 0.6 )
	util.Effect("StriderBlood",effectdata)
	ParticleEffect("antlion_gib_02_floaters", data.HitPos, Angle(0,0,0), nil)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2023 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/