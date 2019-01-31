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
time_since_last_message = 0;
messages_sent = 0;
last_message_received = "";
game_object = {};
rnd_str = randomString(32);

function love.load()
    server = host:connect("localhost:9521");
    host:service(100);
    game_object.client_id = rnd_str;
end

function love.update(dt)
    if server:state() == "connected" then
        connected_time = connected_time + dt;
        time_since_last_message = time_since_last_message + dt;

        local event = host:service();

        if event then
            if event.type == "receive" then
                response_object = json.decode(event.data);
                last_message_received = response_object.response_text or "";
            end
        end

        if time_since_last_message > 2 then

            game_object.message_type = 12;

            local go = json.encode(game_object);
            server:send(go);

            time_since_last_message = 0;
            messages_sent = messages_sent + 1;
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
    love.graphics.print("Time Since Last Message: " .. time_since_last_message, 50, 80);
    love.graphics.print("Last Message Received: " .. last_message_received, 50, 100);
    love.graphics.print("Client ID: " .. rnd_str, 50, 120);
end