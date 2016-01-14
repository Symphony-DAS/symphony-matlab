classdef Example < symphonyui.core.Protocol
    
    properties
        double = pi                 % Standard MatLab type
        integer = int32(23)         % 32-bit integer value
        interval = int32(2)         % 32-bit integer value with an interval domain
        enumerated = int32(-1)      % 32-bit integer value with an enumerated domain
        logical = true              % Boolean value that takes either true or false
        doubleMatrix = []           % Matrix of standard MatLab type with empty initial value
        string = 'a sample string'  % Row vector of characters
        rowCellString = {'a', 'sample', 'string'}   % A row cell array whose every element is a string (char array)
        colCellString = {'a'; 'sample'; 'string'}   % A column cell array whose every element is a string (char array)
        selection = 'spring'        % Row vector of characters that can take any of the predefined set of values
        suggestion = 'banana'       % Row vector of characters that offers suggestions
        number = 1                  % Row vector of characters that can take any of the predefined set of values
        set = [true false true]     % Logical vector that serves an indicator of which elements from a universe are included in the set
        date = datestr(now)         % Row vector of characters that can take a date string
        tree = []                   % Row vector of characters that can take any of the predefined set of values
    end
    
    properties (Hidden)
    end
    
end

