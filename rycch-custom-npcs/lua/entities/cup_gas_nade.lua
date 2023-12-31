
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "NeuroToxinNade"
ENT.Author			= "FiLzO"
ENT.Purpose			= "Can you feel Air Exchange?"
ENT.Category		= "Combine Units +PLUS+"

ENT.Spawnable		= true
ENT.AdminOnly		= true

ENT.EntitiesExcludedFromDamage = {"npc_combine_s","npc_metropolice","npc_cscanner","npc_manhack",
									"npc_stalker","npc_strider","npc_hunter","npc_helicopter","npc_combinegunship",
									"npc_combinedropship","npc_turret_floor","npc_turret_ceiling","npc_rollermine",
									"npc_vj_hunter2_z","npc_vj_mini_strider_synth_z","npc_vj_melee_hunter","npc_vj_combine_turret_z",
									"npc_vj_mortar_synth_z","npc_vj_synth_scanner_z","npc_vj_crabsynth2_z","npc_vj_vortigaunt_synth_z",
									"npc_vj_cremator_synth_z","npc_vj_assassin_synth_z","npc_vj_city_scanner_z","npc_vj_rollermine_z",
									"npc_vj_rollermine_explosive_z","obj_vj_hopper_mine_z","npc_assault_synth_custom","npc_vj_combineguard_z",
									"npc_vj_stalker_z","npc_vj_civil_protection_z","npc_vj_civil_protection_riot","npc_vj_civil_protection_elite_z",
									"npc_vj_civil_protection_dropshield","npc_vj_civil_protection_heavy","npc_vj_civil_protection_female","npc_vj_civil_protection_sniper",
									"npc_vj_overwatch_medic","npc_vj_overwatch_jumptrooper","npc_vj_overwatch_dome_shielder_elite","npc_vj_overwatch_synth",
									"npc_vj_overwatch_soldier_grunt","npc_vj_overwatch_soldier_z","npc_vj_overwatch_soldier_female","npc_vj_overwatch_soldier_turret",
									"npc_vj_overwatch_shotgunner_z","npc_vj_overwatch_sniper","npc_vj_overwatch_soldier_heavy","npc_vj_overwatch_soldier_elite",
									"npc_vj_overwatch_assassin_z","npc_vj_overwatch_assassin_melee","npc_vj_novaprospekt_shotgunner_z"
								}

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
	--Visable radius
	function ENT:TargetPlayer(ent)
		if IsValid(ent) then
			if ent:IsPlayer() and self:Visible(ent) and ent:GetPos():Distance(self:GetPos()) < 200 then
				if ent.wearsuit == true or ent.GASMASK_Equiped then return end
				--print("Took damage, gas mask condition", ent.GASMASK_Equiped)
				ent:TakeDamage(2, self, DMG_NERVEGAS)
			end
		end
	end
	--Damage radius
	function ENT:TargetNPC(ent)
		if IsValid(ent) then
			if self:Visible(ent) and ent:GetPos():Distance(self:GetPos()) < 170 then
				if table.HasValue(self.EntitiesExcludedFromDamage, ent:GetClass()) then return end
				ent:TakeDamage(1, self, DMG_NERVEGAS)
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

