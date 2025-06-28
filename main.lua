local fishlist = {
    3000, 3026, 3030, 3038, 3032, 3034, 3036,
    3814, 4958, 3024, 7744, 5538, 5580, 5542,
    5574, 5548, 5552
}

local url = "https://discord.com/api/webhooks/1388038660548722770/8YFn7DB-o4uO2B0f1Wcrv0TzXFXy-Bk5c_vrbbPCtQhHwjp2baKi0LS0dehsHyobbTbg"
local action = "POST"
local headers = { ["Content-Type"] = "application/json" }

local fishs = {}
local queue = {}
local trashFlag = 0

-- Buat list nama ikan dari ID
for _, fishid in pairs(fishlist) do
    fishs[getItemByID(fishid).name] = fishid
end

-- Trash ikan
local function trashQewe()
    for name, fishesID in pairs(queue) do
        logToConsole("Trashing " .. name)
        sendPacket(2, "action|trash\n|itemID|" .. fishesID)
        trashFlag = name
        break
    end
end

-- Hitung bait ngambang
function countFloatingBait(itemID)
    local total = 0
    for _, obj in pairs(getWorldObject()) do
        if obj.id == itemID then
            total = total + obj.amount
        end
    end
    return total
end

-- Hitung bait di inventory
function countInventoryBait(itemID)
    for _, item in pairs(getInventory()) do
        if item.id == itemID then
            return item.amount
        end
    end
    return 0
end

-- Kirim Webhook Aquamarine
function sendWeb(jumlah)
    local growid = getLocal().name:gsub("`%d", "") or "Unknown"
    local world = getWorld().name or "Unknown"
    local ping = getLocal().ping or 0
    local bait = countFloatingBait(3012) + countInventoryBait(3012)
    local user = "986952172577116182"
    local time = os.date("%Y-%m-%d %I:%M %p")

    local payload = [[
{
  "username": "Fish Bot",
  "embeds": [
    {
      "content": "<@]] .. user .. [[>",
      "title": "Kamu Dapet Aquamarine!!",
      "description": "<:flnub:1260065723611353150> GrowID: ]] .. growid .. [[\n<:WorldList:1156644357135409262> World: ]] .. world .. [[\n<:gtonline:1270673063318392913> Ping: ]] .. ping .. [[ ms\n<:aquastone:879814692342755338> Aqua: ]] .. jumlah .. [[\n\n<:Shinyflashything:664931239093862430> Bait: ]] .. bait .. [[",
      "color": 65280,
      "footer": {
        "text": "GOCEP || ]] .. time .. [["
      }
    }
  ]
}
]]
    makeRequest(url, action, headers, payload, 5000, function(code, response)
        doLog("📡 Status: " .. tostring(code))
    end)
end

AddHook("OnVarlist", "fishy", function(text)
    if text[0] == "OnConsoleMessage" then
        local original = text[1]
        local message = original:lower()
        if message:find("aquamarine") then
            local jumlah = 0
            for _, item in pairs(getInventory()) do
                if item.id == 6986 then
                    jumlah = item.amount
                    break
                end
            end
            logToConsole("[AQUA] Kamu dapat Aquamarine! Jumlah: " .. jumlah)
            sendWeb(jumlah)
        end
        if message:find("you caught") or (message:find("collected") and message:find("lb")) then
            local fish = original:match("you caught a ([%a%s]+)!") or original:match("you caught an ([%a%s]+)!") or original:match("(%a+)!") or original:match(" (%a+).")
            if fish and fishs[fish] then
                logToConsole(fish .. " added to the queue")
                queue[fish] = fishs[fish]
                if trashFlag == 0 then
                    trashQewe()
                end
            else
                logToConsole((fish or "??") .. " not on the list")
            end
            return true
        end
    end
    if text[0] == "OnDialogRequest" then
        local itemID = tonumber(text[1]:match("|itemID|(%d+)"))
        if itemID then
            local name = getItemByID(itemID).name
            if fishs[name] then
                local count = text[1]:match("you have (%d+)")
                sendPacket(2, ("action|dialog_return\ndialog_name|trash_item\nitemID|%s|\ncount|%s"):format(itemID, count))
                logToConsole(trashFlag .. " removed from the queue")
                queue[trashFlag], trashFlag = nil, 0
                trashQewe()
                return true
            end
        end
    end
end)
