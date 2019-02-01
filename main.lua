enet = require "enet";
json = require "json";

function randomString(length)
    charset = {}  do -- [0-9a-zA-Z]
        for c = 48, 57  do table.insert(charset, string.char(c)) end
        for c = 65, 90  do table.insert(charset, string.char(c)) end
        for c = 97, 122 do table.insert(charset, string.char(c)) end
    end

    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

host = enet.host_create();
server = {};

connected_time = 0;
time_since_last_ping = 0;
messages_sent = 0;
last_message_received = "";
last_message_type_sent = "";
client_id = "";
peers = {};

function love.load()
    server = host:connect("localhost:9521");
    event = host:service(100);
end

function love.update(dt)
    if server:state() == "connected" then
        connected_time = connected_time + dt;
        time_since_last_ping = time_since_last_ping + dt;

        local event = host:service();

        process_event(event);

        if time_since_last_ping > 5 then
            local request_message = {};

            request_message.client_id = client_id;
            request_message.message_type = "ping";

            send_to_server(request_message);

            time_since_last_ping = 0;
        end
    
        if connected_time > 100 then
            server:disconnect();
        end
    end
end

function love.draw()
    love.graphics.print("Status: " .. server:state(), 50, 20);
    love.graphics.print("Connected Time: " .. connected_time, 50, 40);
    love.graphics.print("Messages Sent: " .. messages_sent, 50, 60);
    love.graphics.print("Time Since Last Ping: " .. time_since_last_ping, 50, 80);
    love.graphics.print("Last Message Type Sent: " .. last_message_type_sent, 50, 100);
    love.graphics.print("Last Message Type Received: " .. last_message_received, 50, 120);
    love.graphics.print("Client ID: " .. client_id, 50, 140);
end

function process_event(event) 
    if event then
        if event.type == "receive" then
            response_object = json.decode(event.data);

            if response_object.type then
                if response_object.type == "addpeer" then
                    last_message_received = "addpeer";
                elseif response_object.type == "peermove" then
                    last_message_received = "peermove";
                elseif response_object.type == "pong" then
                    last_message_received = "pong";
                elseif response_object.type == "connect" then
                    last_message_received = "connect";
                    client_id = response_object.clientId;
                    peers = response_object.peers;

                    -- for key, value in pairs(peers) do
                    --     for subkey, subvalue in pairs(value) do
                    --         print(subkey);
                    --     end
                    -- end
                end
            else
                --last_message_received = response_object.response_text or "";
            end
        elseif event.data then 
            last_message_received = event.data;
        end
    end
end

function send_to_server(game_object) 

    if game_object and game_object.message_type then
        last_message_type_sent = game_object.message_type;
    end

    local go = json.encode(game_object);
    server:send(go);
    messages_sent = messages_sent + 1;
end