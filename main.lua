enet = require "enet";
host = enet.host_create();
server = {};

connected_time = 0;
time_since_last_message = 0;
messages_sent = 0;
last_message_received = "";

function love.load()
    server = host:connect("localhost:9521");
    host:service(100);
end

function love.update(dt)
    if server:state() == "connected" then
        connected_time = connected_time + dt;
        time_since_last_message = time_since_last_message + dt;

        local event = host:service();

        if event then
            if event.type == "receive" then
                last_message_received = event.data;
            end
        end

        if time_since_last_message > 2 then
            server:send("Test message");
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
end