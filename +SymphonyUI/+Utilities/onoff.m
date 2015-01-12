% Converts logicals to 'on'/'off'.

function output = onOff(input)
    if input
        output = 'on';
    else
        output = 'off';
    end
end