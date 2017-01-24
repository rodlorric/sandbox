

function CSandbox:SpawnTestHero(hero_name)
	if hero_name == nil then
		hero_name = "npc_dota_hero_wisp"
	end
   PlayerResource:ReplaceHeroWith( 0, hero_name, 0, 0)
end

function CSandbox:RelocateHeroXY(x_coord, y_coord, playerId)
	if x_coord == nil then
		x_coord = 0
	end
	if y_coord == nil then
		y_coord = 0
	end
	if playerId == nil then
		playerId = 0
	end
	caster = PlayerResource:GetSelectedHeroEntity(playerId)
	vPos = Vector(x_coord, y_coord, 0)
	FindClearSpaceForUnit( caster, vPos, true )
	PlayerResource:SetCameraTarget(playerId, caster)
	Timers:CreateTimer(0.1, function()
		PlayerResource:SetCameraTarget(playerId, nil)
	end)
end

function CSandbox:SpawnUnit(unit_type, unit_team, location, waypoint)
	if unit_type == nil then
		unit_type = "npc_dota_creep_goodguys_melee"
	end

	if unit_team == nil then
		unit_team = PlayerResource:GetTeam(0)
		unit_team = unit_team == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
	else
		unit_team = tonumber(unit_team)
	end

	if location == nil then
		location = Vector(0, 0, 0)
	end
	print("unit_type")
	print(unit_type)
	print("location")
	print(location)
	print("unit_team")
	print(unit_team)
	return CreateUnitByName(unit_type, location, true, nil, nil, unit_team)
end

function CSandbox:SpawnWave(team, n_melee, n_ranged, n_siege, n_wave, location, waypoint)
	if team == nil then
		team = DOTA_TEAM_GOODGUYS
	else
		team = tonumber(team)
	end

	if n_melee == nil then
		n_melee = 3
	else
		n_melee = tonumber(n_melee)
	end

	if n_ranged == nil then
		n_ranged = 1
	else
		n_ranged = tonumber(n_ranged)
	end

	if n_siege == nil then
		n_siege = 0
	else
		n_siege = tonumber(n_siege)
	end

	time = nil
	if n_wave == nil then
		n_wave = 1
	else
		n_wave = tonumber(n_wave)
		time = (n_wave * 30) - 30
	end

	if location == nil then
		location = Vector(0, 0, 0)
	end

	for i = 1, (n_melee + n_ranged + n_siege) do
		team_name = (team == DOTA_TEAM_GOODGUYS and "good" or "bad") .. "guys_"
		if i <= (n_melee + n_ranged) then
			unit_type = "npc_dota_creep_" .. team_name .. (i <= n_melee and "melee" or "ranged")
		else
			unit_type = "npc_dota_" .. team_name .. "siege"
		end
		unit = self:SpawnUnit(unit_type, team, location, nil)

		wave_split = (n_wave - 1) / 15
		stat_multiplier = math.floor(wave_split) -- every 07:30 minutes
		if unit:IsCreep() and unit:IsRangedAttacker() then
			unit:SetBaseDamageMin(unit:GetBaseDamageMin() + (2 * stat_multiplier))
			unit:SetBaseDamageMax(unit:GetBaseDamageMax() + (2 * stat_multiplier))
		else
			unit:SetBaseDamageMin(unit:GetBaseDamageMin() + (1 * stat_multiplier))
			unit:SetBaseDamageMax(unit:GetBaseDamageMax() + (1 * stat_multiplier))
		end
		unit:SetMaxHealth(unit:GetMaxHealth() + (12 * stat_multiplier))
		unit:SetHealth(unit:GetMaxHealth())
		unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() + (2 * stat_multiplier))
		unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() + (2 * stat_multiplier))
	end
end

function CSandbox:Spawner(lane_name, n_wave)
	local point = nil
	local waypoint = nil

	if lane_name == nil then
		lane_name = "mid"
	end

	if n_wave == nil then
		n_wave = 1
	else
		n_wave = tonumber(n_wave)
	end

	for i=2,3 do --radiant and dire
	    --point = Entities:FindByName( nil, "npc_dota_spawner_" .. (i == 2 and "good" or "bad") .. "_" .. lane_name .."_staging"):GetAbsOrigin()			
	    --waypoint = Entities:FindByName(nil, "lane_" .. lane_name .. "_pathcorner_" .. (i == 2 and "good" or "bad") .. "guys_1")
		--if waypoint then
		if n_wave < 33 then
			n_melee = 3
			n_ranged = 1
			n_siege = n_wave % 7 == 0 and 1 or 0
		elseif n_wave >= 33 and n_wave < 63 then
			n_melee = 4
			n_ranged = 1
			n_siege = n_wave % 7 == 0 and 1 or 0
		elseif n_wave >= 63 and n_wave < 93 then
			n_melee = 5
			n_ranged = 1
			n_siege = n_wave % 7 == 0 and 1 or 0
		else 
			n_melee = 6
			n_ranged = 3
			n_siege = n_wave % 7 == 0 and 2 or 0
		end
		--(team, n_melee, n_ranged, n_siege, n_wave, location, waypoint)
		self:SpawnWave(i, n_melee, n_ranged, n_siege, n_wave, point, waypoint)
		--end
	end
	--wave = wave + 1
end

function CSandbox:ClearUnits()
	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, 
										Vector( 0, 0, 0 ), 
										nil, 
										FIND_UNITS_EVERYWHERE, 
										DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
										DOTA_UNIT_TARGET_ALL, 
										DOTA_UNIT_TARGET_FLAG_NONE, 
										FIND_ANY_ORDER, false )) do
		if not unit:IsTower() and not unit:IsHero() then
			UTIL_Remove( unit )
		end
	end

	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_GOODGUYS, 
									Vector( 0, 0, 0 ), 
									nil, 
									FIND_UNITS_EVERYWHERE, 
									DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
									DOTA_UNIT_TARGET_ALL, 
									DOTA_UNIT_TARGET_FLAG_NONE, 
									FIND_ANY_ORDER, false )) do
		if not unit:IsTower() and not unit:IsHero() then
			UTIL_Remove( unit )
		end
	end
end