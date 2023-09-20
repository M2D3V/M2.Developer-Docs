ESX = exports['es_extended']:getSharedObject()
r = GetCurrentResourceName()
GetName = function(a, b) return string.format("%s:%s:%s", r, a, b) end
RegisEvent = function(b, a, c)
    if b then RegisterNetEvent(a) end
    AddEventHandler(a, c)
end
t = { TriggerClientEvent, TriggerServerEvent, RegisterNUICallback }
e = {}
e.sv = {
    ["ApiCheckKey"] = GetName("SV", "ApiCheckKey"),
    ["Rewards"] = GetName("SV", "Rewards"),
}
e.cl = {
    ["ApiCheckKey"] = GetName("CL", "ApiCheckKey"),
}
e.re = {
    ["Exit"] = "Exit",
}