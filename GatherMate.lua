local Routes = LibStub("AceAddon-3.0"):GetAddon("Routes", 1)
if not Routes then return end

local SourceName = "GatherMate"

do
	-- disable if the addon is not enabled, or
	-- disable if there is a reason why it can't be loaded ("MISSING" or "DISABLED")
	local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(SourceName)
	if not enabled or (reason ~= nil) then return end
end

local L = LibStub("AceLocale-3.0"):GetLocale("Routes")
local LN = LibStub("AceLocale-3.0"):GetLocale("GatherMateNodes", true)
local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()

------------------------------------------
-- setup
if type(Routes.plugins) ~= "table" then Routes.plugins = {} end
if type(Routes.plugins[SourceName]) ~= "table" then Routes.plugins[SourceName] = {} end
local source = Routes.plugins[SourceName]

------------------------------------------
-- functions
local function IsActive()
	-- Can we gather data?
	return GatherMate and true
end
source.IsActive = IsActive

local amount_of = {}
local function Summarize( data, zone )
	for db_type, db_data in pairs(GatherMate.gmdbs) do
		-- reuse table
		for k in pairs(amount_of) do amount_of[k] = nil end
		-- only look for data for this currentzone
		if db_data[GatherMate.zoneData[BZ[zone]][3]] then
			-- count the unique values (structure is: location => itemID)
			for _,node in pairs(db_data[GatherMate.zoneData[ BZ[zone] ][3] ]) do
				amount_of[node] = (amount_of[node] or 0) + 1
			end
			-- XXX Localize these strings
			-- store combinations with all information we have
			for node,count in pairs(amount_of) do
				local translatednode = GatherMate.reverseNodeIDs[node]
				data[ ("%s;%s;%s;%s"):format(SourceName, db_type, node, count) ] = ("%s - %s - %d"):format(L[SourceName..db_type], translatednode, count)
			end
		end
	end
	return data
end
source.Summarize = Summarize

-- returns the english name for the node so we can store it was being requested
-- also returns the type of db for use with auto show/hide route
local translate_db_type = {
	["Herb Gathering"] = "Herbalism",
	["Mining"] = "Mining",
	["Fishing"] = "Fishing",
	["Extract Gas"] = "ExtractGas",
}
local function AppendNodes( node_list, zone, db_type, node_type )
	if type(GatherMate.gmdbs[db_type]) == "table" then
		node_type = tonumber(node_type)

		-- Find all of the notes
		for loc, t in pairs(GatherMate.gmdbs[db_type][ GatherMate.zoneData[ BZ[zone] ][3] ]) do
			-- And are of a selected type - store
			if t == node_type then
				tinsert( node_list, loc )
			end
		end

		-- return the node_type for auto-adding
		local translatednode = GatherMate.reverseNodeIDs[node_type]
		for k, v in pairs(LN) do
			if v == translatednode then
				return k, translate_db_type[db_type] -- get the english name
			end
		end
	end
end
source.AppendNodes = AppendNodes

local function AddHook()
	-- Hook calls for adding a node
end
source.AddHook = AddHook

local function RemoveHook()
	-- Hook calls for deleting of a node
end
source.RemoveHook = RemoveHook

-- vim: ts=4 noexpandtab
