classdef Test < symphonyui.core.Protocol
    
    properties
        double = pi                 % Standard Matlab type
        single = pi                 % Single-precision floating point number
        integer = int32(23)         % A 32-bit integer value
        interval = int32(2)         % A 32-bit integer value with an interval domain
        enumerated = int32(-1)      % A 32-bit integer value with an enumerated domain
        logical = true              % A Boolean value that takes either true or false
        doubleMatrix = []           % Matrix of standard MatLab type with empty initial value
        string = 'a sample string'  % A row vector of characters
        rowcellstr = {'a sample string', 'spanning multiple', 'lines'}  % A row cell array whose every element is a string (char array)
        colcellstr = {'a sample string'; 'spanning multiple'; 'lines'}  % A column cell array whose every element is a string (char array)
        selection = 'spring'        % A row vector of characters that can take any of the predefined set of values
        number = 1                  % A row vector of characters that can take any of the predefined set of values
        set = [true false true]     % A logical vector that serves an indicator of which elements from a universe are included in the set
    end
    
    properties (Hidden)
        intervalType = symphonyui.core.PropertyType('int32', 'scalar', [0 6])
        enumeratedType = symphonyui.core.PropertyType('int32', 'scalar', {int32(-1), int32(0), int32(1)})
        doubleMatrixType = symphonyui.core.PropertyType('denserealdouble', 'matrix')
        selectionType = symphonyui.core.PropertyType('char', 'row', {'spring', 'summer', 'fall', 'winter'})
        numberType = symphonyui.core.PropertyType('denserealdouble', 'row', {1, 2, 3, 4})
        setType = symphonyui.core.PropertyType('logical', 'row', {'A', 'B', 'C'})
    end
    
    methods
    end
    
end

