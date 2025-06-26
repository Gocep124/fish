function kirimLaporanAquamarine(jumlah)
    local embed = {
        title = "🎣 Laporan Mancing",
        description = "**Berhasil mendapatkan Aquamarine!**",
        color = "65280",
        fields = {
            {
                name = "Jumlah Sekarang",
                value = tostring(jumlah),
                inline = true
            },
            {
                name = "Waktu",
                value = os.date("%Y-%m-%d %H:%M:%S"),
                inline = true
            }
        },
        footer = {
            text = "Gentahax Fishing Reporter"
        }
    }

    local webhook = {
        username = "Gentahax Bot",
        avatar_url = "https://i.imgur.com/YOUR_IMAGE.png", -- opsional
        content = "",
        useEmbeds = true,
        embeds = embed
    }

    sendWebhook(WEBHOOK_URL, webhook)
end

kirimLaporanAquamarine(20)
