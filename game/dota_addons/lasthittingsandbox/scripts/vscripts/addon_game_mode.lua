if CSandbox == nil then
  _G.CSandbox = class({}) -- put CSandbox in the global scope
  --refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local
end

require( 'libraries/timers' )
require( "libraries/util" )
require( "functions" )

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end


-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CSandbox()
	GameRules.AddonTemplate:InitGameMode()
end

function CSandbox:InitGameMode()
	print( "Last Hitting Sandbox addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	Convars:RegisterCommand("sandbox_test_hero", function( cmd, sandbox_hero_name ) self:SpawnTestHero(sandbox_hero_name) end, "Spawn a hero.", FCVAR_CHEAT )
	Convars:RegisterCommand("sandbox_relocate_hero", function( cmd, playerId, x, y ) self:RelocateHeroXY(playerId, x, y) end, "Move the hero to X and Y coordinates.", FCVAR_CHEAT )
	Convars:RegisterCommand("sandbox_spawn_unit", function( cmd, unit_type, unit_team, location, waypoint) self:SpawnUnit(unit_type, unit_team, location, waypoint) end, "Spawn units of a specific type", FCVAR_CHEAT )
	Convars:RegisterCommand("sandbox_spawn_wave", function( cmd, team, n_melee, n_ranged, n_siege, n_wave, location, waypoint) self:SpawnWave(team, n_melee, n_ranged, n_siege, n_wave, location, waypoint) end, "Spawn a wave.", FCVAR_CHEAT )
	Convars:RegisterCommand("sandbox_clear_units", function( cmd ) self:ClearUnits() end, "Clear all units", FCVAR_CHEAT )
	Convars:RegisterCommand("sandbox_test_spawner", function( cmd, lane_name, n_wave ) self:Spawner(lane_name, n_wave) end, "Test a lane spawner", FCVAR_CHEAT )
end

-- Evaluate the state of the game
function CSandbox:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end