include("shared.lua")

local shldTypeNames = {"spartan", "elite"}

local shldClrs = {
	spartan = {
		r = 218,
		g = 185,
		b = 40
	},
	elite = {
		r = 51,
		g = 105,
		b = 219
	},
	custom = {
		r = 255,
		g = 255,
		b = 255
	}
}

function ENT:Initialize()
	self:DrawModel()
	self.ply = self:GetOwner()
	self:SetNextClientThink( CurTime() + 1 )
	self:AddEffects(EF_BONEMERGE)
end

--function ENT:AssociatePlayer(ply)
--	self.ply = self:GetOwner()
--
--	self:SetNextClientThink( CurTime() + 1 )
--end

local function ManageShieldFx(shield,ply,isAlive)
	shield.opcty = shield.opcty or 0
	shield.scale = shield.scale or 0
	shield.broke = shield.broke or false
	shield.recover = shield.recover or 0
	shield.particle = shield.particle or false
	shield.particleLoop = shield.particleLoop or 0

	--local shieldType = shldTypeNames["elite"]

	local lasthit = ply:GetNWFloat("shld.lastHit")
	local health = ply:GetNWFloat("shld.health")

	if health > 0 then
		shield.scale = -health/300*0.2+0.2
		shield.opcty = math.max((lasthit+(shield.scale*12) - CurTime())*255,0)
	elseif health <= 0 then
		shield.scale = shield.scale + RealFrameTime()*30
		shield.opcty = math.Clamp((lasthit+0.3 - CurTime())*250,0,255)
		shield.broke = true
	end


	if shield.recover+2 > CurTime() and shield.broke == false then
		shield.opcty = math.max((shield.recover + 2 - CurTime())*250,0)
	end

	local scale = shield.scale

	for i = 0, ply:GetBoneCount() - 1 do
		local name = ply:GetBoneName(i)

		if name ~= "__INVALIDBONE__" then
			if name == "ValveBiped.Bip01_Head1" then
				shield:ManipulateBoneScale(i, Vector(1.1+scale,1.1+scale,1.1+scale))
			else
				shield:ManipulateBoneScale(i, Vector(1.1+scale,1.1+scale,1.1+scale))
			end
		end
	end		
end

function ENT:Think()

	-- Remove the entity if player not longer exist
	if not IsValid(self.ply) then
		self:Remove()
		return
	end
	
	local ply = self.ply
	local model = ply:GetModel()

	if model ~= self:GetModel() then
		self:SetModel(model)
	end

	-- Check model bodygroups when respawning
	if IsValid(self.ply) and !self.bodygroupCheck then			
		for i=1, #ply:GetBodyGroups() do
			if ply:GetBodygroup(i) != self:GetBodygroup(i) then
				self:SetBodygroup(i,ply:GetBodygroup(i))
			end
		end
		self.bodygroupCheck = true
	end

	--local shldType = shldTypeNames["elite"]

	ManageShieldFx(self,ply,IsValid(self.ply))
		
	self:SetMaterial("models/alyx/emptool_glow")  --  models/props/cs_office/clouds 

	self:AddEffects(EF_BONEMERGE)
	self:SetPos(ply:GetPos())
	self:SetParent(ply)

	-- Stop drawing the model when opacity is 0
	if self.opcty > 0  then
		self:SetNoDraw(false)
	else
		self:SetNoDraw(true) 
	end

	--local clrs = shldClrs[shldType]

	--shldClrs.custom.enable = ply:GetNWBool("shld.clr.enable")
	--shldClrs.custom.r = ply:GetNWInt("shld.clr.r")
	--shldClrs.custom.g = ply:GetNWInt("shld.clr.g")
	--shldClrs.custom.b = ply:GetNWInt("shld.clr.b")

	-- self:SetColor(Color(clrs.r,clrs.g,clrs.b,254))
	self:SetColor(Color(254,254,254,math.min(self.opcty,254)))
	self:SetRenderMode(RENDERMODE_GLOW)

	if IsValid(self.ply) then
		self.bodygroupCheck = false
	end

	-- Force proceed to next frame (it isn't automatic for some reason)
	self:SetNextClientThink( CurTime() )
	return true
end