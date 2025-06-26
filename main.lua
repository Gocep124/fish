local fishlist = {
    3000, 3026, 3030, 3038, 3032, 3034, 3036,
    3814, 4958, 3024, 7744, 5538, 5580, 5542,
    5574, 5548, 5552
}

local WEBHOOK_URL = "https://discord.com/api/webhooks/1387872978775183462/v1P3CYjneUAp9bQCFpiQC_BiZHoQ-Ki9mNhBPneYgHL0_Sem1pkAmxc9AJIpZaqRoMml"

local fishs = {}
local queue = {}
local trashFlag = 0

for _, fishid in pairs(fishlist) do
    fishs[getItemByID(fishid).name] = fishid
end

local function trashQewe()
    for name, fishesID in pairs(queue) do
        logToConsole("Trashing " .. name)
        sendPacket(2, "action|trash\n|itemID|" .. fishesID)
        trashFlag = name
        break
    end
end

function kirimLaporan(jumlah)
Webhook = {}
Webhook.username = "Webhook"
Webhook.avatar_url = "https://i.imgur.com/4M34hi2.png"
Webhook.content = "Text message. Up to 2000 characters."
Webhook.useEmbeds = true
Webhook.embeds = {
    {
        author = {
            name = "GentaReport",
            url = "https://www.reddit.com/r/cats/",
            icon_url = "https://i.imgur.com/R66g1Pe.jpg"
        },
        title = "Aquamarine",
        url = "https://google.com/",
        description = "Text message. You can use Markdown here. *Italic* **bold** __underline__ ~~strikeout~~ [hyperlink](https://google.com) `code`",
        color = 15258703,
        fields = {
            {
                name = "Backpack: ",
                value = jumlah,
                inline = true
            },
            {
                name = "Time: ",
                value = os.date("%Y-%m-%d %H:%M:%S"),
                inline = true
            },
            {
                name = "World: ",
                value = getWorld().name
            },
            {
                name = "Thanks!",
                value = "You're welcome :wink:"
            }
        },
        thumbnail = {
            url = "https://upload.wikimedia.org/wikipedia/commons/3/38/4-Nature-Wallpapers-2014-1_ukaavUI.jpg"
        },
        image = {
            url = "https://upload.wikimedia.org/wikipedia/commons/5/5a/A_picture_from_China_every_day_108.jpg"
        },
        footer = {
            text = "Woah! So cool! :smirk:",
            icon_url = "https://i.imgur.com/fKL31aD.jpg"
        }
    }
}
    sendWebhook(WEBHOOK_URL, Webhook)
end

AddHook("OnVarlist", "fishy", function(text)
    if text[0] == "OnConsoleMessage" then
        local message = text[1]:lower()
        
        if message:find("you caught") or (message:find("collected") and message:find("lb")) then
            local fish = text[1]:match("(%a+)!") or text[1]:match(" (%a+).")
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

        if message:find("you caught") and message:find("aquamarine") then
            local jumlah = 0
            for _, item in pairs(getInventory()) do
                if item.id == 6986 then
                    jumlah = item.amount
                    break
                end
            end
            logToConsole("[AQUA] Kamu dapat Aquamarine! Jumlah: " .. jumlah)
            kirimLaporan(jumlah)
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
