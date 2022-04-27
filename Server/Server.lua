
TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VORP = exports.vorp_core:vorpAPI()
RegisterServerEvent("DiscordBot:playerDied")
AddEventHandler("DiscordBot:playerDied", function(msg,Weapon)
    local _source = source
    local webhook = Config.deathlog
    local title = "💀 Deaths"
    local message
                    
    if Weapon ~= nil then
         message = msg.." Weapon: ***"..Weapon.."*** "
    else
         message = msg.." "
    end
    SendWebhookMessage(webhook, title, message, text, color)
end)

function SendWebhookMessage(webhook, title, message, text, color)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        embeds = {
            {
                ["color"] = Config.webhookColor,
                ["author"] = {
                    ["name"] = Config.name,
                    ["icon_url"] = Config.logo
                },
                ["title"] = title,
                ["description"] = message,
                ["footer"] = {
                    ["text"] = "VORP Logs" .. " • " .. os.date("%x %X %p"),
                    ["icon_url"] = Config.footerLogo,

                },
            },

        },
        avatar_url = Config.Avatar
    }), {
        ['Content-Type'] = 'application/json'
    })
end 

function GetPlayerDetails(source)
    local ids = ExtractIdentifiers(source)

    if Config.discordID then
        if ids.discord then
            _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "").."> `("..ids.discord:gsub("discord:", "")..")`"
        else
            _discordID = "\n**Discord ID:** N/A"
        end
    else
        _discordID = ""
    end

    if GetConvar("steam_webApiKey", "false") ~= 'false' then
        if Config.steamName then
            if ids.steam then
                _steamID ="\n**Steam ID:** `" ..ids.steam.."`"
            else
                _steamID = "\n**Steam ID:** N/A"
            end
        else
            _steamID = ""
        end

        if Config.steamUrl then
            if ids.steam then
                _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16)..""
            else
                _steamURL = "\n**Steam URL:** N/A"
            end
        else
            _steamURL = ""
        end
    else
        _steamID = ""
        _steamURL = ""
        TriggerEvent('Prefech:JD_logs:errorLog', 'You need to set a steam api key in your server.cfg for the steam identifiers to work!.')
    end

	if Config.license then
        if ids.license then
            _license ="\n**License:** `" ..ids.license.."`"
        else
            _license = "\n**License:** N/A"
        end
    else
        _license = ""
    end

    if Config.license2 then
        if ids.license2 then
            _license2 ="\n**License 2:** `" ..ids.license2.."`"
        else
            _license2 = "\n**License 2:** N/A"
        end
    else
        _license2 = ""
    end

    if Config.IP then
        if ids.ip then
            _ip ="\n**IP:** " ..ids.ip:gsub("ip:", "")
        else
            _ip = "\n**IP:** N/A"
        end
    else
        _ip = ""
    end

    return _discordID.._steamID.._steamURL.._license.._license2.._ip
end


AddEventHandler('playerDropped', function(reason)
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local isdead = Character.isdead  
    if isdead and Config.combatlog then
        local webhook = Config.leaving
        local title = "📤 Leaving"
        Player_Details = GetPlayerDetails(source)

        message = "***"..GetPlayerName(source) .. "*** Combat logged \n**"..Player_Details
        SendWebhookMessage(webhook, title, message, text, color)
        isdead = nil
    else
        local webhook = Config.leaving
        local title = "📤 Leaving"
        Player_Details = GetPlayerDetails(source)

        message = "***"..GetPlayerName(source) .. "*** is leaving. **Reason: "..reason.." \n**"..Player_Details
        SendWebhookMessage(webhook, title, message, text, color)
        isdead = nil
    end
end)

AddEventHandler('playerJoining', function(reason)
    local webhook = Config.joining
    local title = "📥 Joins"
    Player_Details = GetPlayerDetails(source)  

    message = "***"..GetPlayerName(source) .. "*** is Joining"..Player_Details
    SendWebhookMessage(webhook, title, message, text, color)
end)


function GetIdentity(source, identity)
    local num = 0
    local num2 = GetNumPlayerIdentifiers(source)

    if GetNumPlayerIdentifiers(source) > 0 then
        local ident = nil
        while num < num2 and not ident do
            local a = GetPlayerIdentifier(source, num)
            if string.find(a, identity) then ident = a end
            num = num + 1
        end
        return ident;
    end
end

function ExtractIdentifiers(source)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)

        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "ip:") then
            identifiers['ip'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        elseif string.find(id, "xbl:") then
            identifiers['xbl'] = id
        elseif string.find(id, "live:") then
            identifiers['live'] = id
        elseif string.find(id, "fivem:") then
            identifiers['fivem'] = id
        end
    end

    return identifiers
end