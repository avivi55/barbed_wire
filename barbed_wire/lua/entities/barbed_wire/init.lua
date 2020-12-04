--[[
* Hello Dear Dev, if you read this you just downloaded my addon.
* I must warn you, I am not the best coder, I tried to optimise it as I could. But it isn't perfect.
* if you are wondering why I use "? * ! +" in front of my commentary it is just the better commentary extention for VS Code
? if you have any problems with my addon you can contact me on steam or my github : "https://github.com/avivi55"
! It uses Fortification Props Model Pack "https://steamcommunity.com/sharedfiles/filedetails/?id=422672588"
]]

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/barbed_prop/lapland02_128.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth(1000)

    local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end

--* if you want to constrain a job to be able to use this functionality.
/*function ENT:Use( activator, caller )
	local job_command = caller:getJobTable().command
	if( job_command == ???)then --* ONLY IN DARK RP
		self:SetCreator( caller ) --+ allows any player who wants to move it to do it.
	end
end*/

function ENT:OnTakeDamage( dmg )
	print(dmg:GetDamageType())
	local melee_damage = (dmg:GetDamageType() == DMG_GENERIC or dmg:GetDamageType() == DMG_CLUB)
	local fire_damage = (dmg:GetDamageType() == 268435464 or dmg:GetDamageType() == DMG_BURN)
	local bullet_damage = (dmg:GetDamageType() == 8194 or dmg:GetDamageType() == DMG_BULLET) --+ magic fuckery
	local vehicle_damage = (dmg:GetDamageType() == DMG_DIRECT or dmg:GetDamageType() == DMG_BLAST or dmg:GetDamageType() == DMG_VEHICLE)

	if( melee_damage )then --+ deals more damage with melee wepons (knives and shovels)
		self:SetHealth(self:Health() -  math.random(200,500))

	elseif( bullet_damage )then --+ bullets are shit against barbed wire       logic
		self:SetHealth(self:Health() -  math.random(10,15))

	elseif( vehicle_damage )then --+ vehicles damage(vehicles explosions etc.) just fucking annihilates barbed wire
		self:SetHealth(0)

	elseif( fire_damage )then --+ fire go frrrrrooooooooo
		self:SetHealth(self:Health() -  math.random(30,70))
	end

	if( self:Health() <= 0 )then --+ fucking logic
		self:Remove()
	end
end

function ENT:Touch( ent )
	if( ent:IsPlayer() )then --+ enshures that who ever touches the barbed wire gets shreded into pieces
		if timer.TimeLeft( "barb_damage" ) == nil then
			self:EmitSound( "physics/metal/metal_chainlink_impact_hard".. math.random( 1, 3 ) .. ".wav" ) --+ nice metalic sound :^]
			ent:TakeDamage( math.random(5,10), self, self )
			timer.Create( "barb_damage", 0.5, 1, function() end ) --+ controles the interval of given damage
		end
	elseif( ent:IsVehicle() )then --+ just breaks if a vehicle runs "over" it
		self:Remove()
	end
end

function ENT:OnRemove()
	self:EmitSound("physics/wood/wood_box_break" .. math.random(1, 2) .. ".wav") --+ wood break sound, on barbed wire removal
end
