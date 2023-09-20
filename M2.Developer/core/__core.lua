-------------------------------- LICENSE --------------------------------
local sv_authed = false
AddEventHandler('onResourceStart', function(a)
    if (r ~= a) then return end
    RequestApi()
end)
RequestApi = function()
    PerformHttpRequest('https://api.ipify.org', function(err, ipv4, headers)
        Citizen.SetTimeout(3000, function()
            local data = json.encode({ ip = ipv4, script = r, server = GetConvar("sv_hostname", "Unknown"), time = os.date('%Y-%m-%d %H:%M:%S') })
            PerformHttpRequest('https://api-com.com/test/api'
                , function(err, result, headers)
                    local res = json.decode(result)
                    if res["statusCode"] == 200 then
                        sv_authed = true
                        print('^5' .. 'Permission Actived ^2 [✓ Thank you] (' .. res["data"]["_id"] .. ')^0 ')
                        return Server_RunScript()
                    else
                        sv_authed = false
                        print('^5' .. 'Permission Denied ^1 [✗ Sorry] (Discord : https://discord.gg/QJspJRxNMN)^0')
                    end
                end, "POST", data, { ["Content-Type"] = "application/json" })
        end)
    end, 'GET', "")
end
RegisEvent(true, e.sv["ApiCheckKey"], function()
    local src = source
    t[1](e.cl["ApiCheckKey"], src, sv_authed)
end)
-------------------------------- LICENSE --------------------------------