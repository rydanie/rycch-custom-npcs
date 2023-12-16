
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "NeuroToxinNade"
ENT.Author			= "FiLzO"
ENT.Purpose			= "Can you feel Air Exchange?"
ENT.Category		= "Combine Units +PLUS+"

ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then

	function ENT:Initialize()
		self:SetModel("models/weapons/w_cup_dark.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )	
		self:SetColor( Color(25, 100, 0, 255) )
		local phys = self:GetPhysicsObject()	
		if (phys:IsValid()) then
			phys:Wake()
			phys:SetMaterial("metal")
		end	
		local self_name = "smokenade" .. self:EntIndex()
		self:SetName( self_name )
	end

	function ENT:TargetPlayer(ent)
		if IsValid(ent) then
			if ent:IsPlayer() and self:Visible(ent) and ent:GetPos():Distance(self:GetPos()) < 200 then
				if ent.wearsuit == true or ent.GASMASK_Equiped then return end
				--print("Took damage, gas mask condition", ent.GASMASK_Equiped)
				ent:TakeDamage(2, self, DMG_NERVEGAS)
			end
		end
	end

	function ENT:TargetNPC(ent)
		if IsValid(ent) then
			if self:Visible(ent) and ent:GetPos():Distance(self:GetPos()) < 200 then
				if ent:GetClass()=="npc_combine_s" or ent:GetClass()=="npc_metropolice" or ent:GetClass()=="npc_cscanner" or ent:GetClass()=="npc_manhack" or ent:GetClass()=="npc_stalker" or ent:GetClass()=="npc_strider" or ent:GetClass()=="npc_hunter" or ent:GetClass()=="npc_helicopter" or ent:GetClass()=="npc_combinegunship" or ent:GetClass()=="npc_combinedropship" or ent:GetClass()=="npc_turret_floor" or ent:GetClass()=="npc_turret_ceiling" or ent:GetClass()=="npc_rollermine" then return end
				ent:TakeDamage(2, self, DMG_NERVEGAS)
			end
		end
	end

	function ENT:Think()
		if self.TimerExplode == 1 then
			for k,v in pairs (ents.GetAll()) do
				if v:IsNPC() then
					self:TargetNPC(v)
				end
				if v:IsPlayer() then
					self:TargetPlayer(v)
				end
			end
			if self.Sound == nil or self.Sound == false then
				self.Sound = true
				self:EmitSound("CUPsmokeExp.Play")
				smoke = ents.Create("env_smoketrail")
				smoke:SetKeyValue("startsize","40000")
				smoke:SetKeyValue("endsize","100")
				smoke:SetKeyValue("spawnradius","100")
				smoke:SetKeyValue("minspeed","1")
				smoke:SetKeyValue("maxspeed","2")
				smoke:SetKeyValue("startcolor", "80 255 0") --"169 169 169"
				smoke:SetKeyValue("endcolor", "33 110 240")
				smoke:SetKeyValue("opacity","0.8")
				smoke:SetKeyValue("spawnrate","20")
				smoke:SetKeyValue("lifetime","5")
				smoke:SetPos(self:GetPos())
				smoke:SetParent(self)
				smoke:Spawn()
				smoke:Fire("kill","",20)
				self.Entity:Fire("kill","",20)
			end

		end
	end

	function ENT:PhysicsCollide(data,phys)
		timer.Simple(0.1, function()
			self.TimerExplode = 1
		end)
		if data.Speed > 50 then
			self:EmitSound("CUPsmokeHit.Play")
		end
	end
end

