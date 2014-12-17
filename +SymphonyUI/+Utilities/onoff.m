% Converts logicals to 'on'/'off'.

function output = onoff(input)
    if input
        output = 'on';
    else
        output = 'off';
    end
end