local config = import("micro/config")
local shell = import("micro/shell")
local os = import("os")

-- Specify the path to your OpenRouter API key file
local key_path = os.Getenv("HOME") .. "/.openrouter.key"

-- Function to read the API key from a file
local function get_api_key()
    local ok, file = pcall(io.open, key_path, "r")
    if not ok or not file then
        return nil, "API key file not found: " .. key_path
    end
    local key = file:read("*a")
    file:close()
    return key:gsub("%s+", ""), nil
end

-- Main GPT request command
function askgpt(bp)
    local selection = bp.Buf:GetSelection()
    if selection == "" then
        micro.InfoBar():Message("Please select some text to send to GPT.")
        return
    end

    local api_key, err = get_api_key()
    if not api_key then
        micro.InfoBar():Error(err)
        return
    end

    local escaped_input = selection:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n")
    local payload = string.format([[
    {
        "model": "deepseek/deepseek-chat-v3-0324:free",
        "messages": [
            {
                "role": "user",
                "content": "%s"
            }
        ]
    }
    ]], escaped_input)

    local cmd = string.format([[
        curl -s -X POST https://openrouter.ai/api/v1/chat/completions \
        -H "Authorization: Bearer %s" \
        -H "Content-Type: application/json" \
        -H "HTTP-Referer: https://your-app-name.com" \
        -H "X-Title: MicroAI" \
        -d '%s'
    ]], api_key, payload)

    local output, err = shell.RunCommand(cmd)

    if output == "" then
        micro.InfoBar():Error("No response from API: " .. tostring(err))
        return
    end

    local response = output:match([["content"%s*:%s*"([^"]+)]])
    if response then
        bp.Buf:Insert(-1, "\n\nGPT Response:\n" .. response .. "\n")
        micro.InfoBar():Message("Done: response inserted.")
    else
        micro.InfoBar():Error("Failed to extract response: " .. output)
    end
end

-- Register the command in micro editor
function init()
    config.MakeCommand("ask", askgpt, config.NoComplete)
end
