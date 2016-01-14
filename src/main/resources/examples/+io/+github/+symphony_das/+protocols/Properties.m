classdef Properties < symphonyui.core.Protocol
    
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
        tree = '[]'                 % Row vector of characters that can take any of the predefined set of values
    end
    
    properties (Hidden)
        intervalType = symphonyui.core.PropertyType('int32', 'scalar', [0 6])
        enumeratedType = symphonyui.core.PropertyType('int32', 'scalar', {int32(-1), int32(0), int32(1)})
        doubleMatrixType = symphonyui.core.PropertyType('denserealdouble', 'matrix')
        selectionType = symphonyui.core.PropertyType('char', 'row', {'spring', 'summer', 'fall', 'winter'})
        suggestionType = symphonyui.core.PropertyType('char', 'row', {'banana', 'apple', 'pear', 'kiwi', '...'})
        numberType = symphonyui.core.PropertyType('denserealdouble', 'row', {1, 2, 3, 4})
        setType = symphonyui.core.PropertyType('logical', 'row', {'A', 'B', 'C'})
        dateType = symphonyui.core.PropertyType('char', 'row', 'datestr')
        treeType = symphonyui.core.PropertyType('char', 'row', struct('folder1', {{'item1', 'item2'}}, 'folder2', {{'item1', 'item2'}}))
    end
    
end

