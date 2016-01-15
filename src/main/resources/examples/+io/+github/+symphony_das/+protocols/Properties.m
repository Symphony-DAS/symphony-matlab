classdef Properties < symphonyui.core.Protocol
    
    properties
        double = pi                 % Standard MatLab type
        integer = int32(23)         % 32-bit integer value
        interval = int32(2)         % 32-bit integer value with an interval domain
        enumerated = int32(-1)      % 32-bit integer value with an enumerated domain
        logical = true              % Boolean value that takes either true or false
        doubleMatrix = [1, 2]       % Matrix of standard MatLab type
        string = 'a sample string'  % Row vector of characters
        set = {'a', 'set'}          % Row cell array whose every element is a string (char array)
        selection = 'spring'        % Row vector of characters that can take any of the predefined set of values
        suggestion = 'banana'       % Row vector of characters that offers suggestions
        number = 1                  % Row vector of characters that can take any of the predefined set of values
        date = datestr(now)         % Row vector of characters that can take a date string
        tree = '[>, item1]'         % Row vector of characters that can take any of the predefined set of values
    end
    
    properties (Hidden)
        intervalType = symphonyui.core.PropertyType('int32', 'scalar', [0 6])
        enumeratedType = symphonyui.core.PropertyType('int32', 'scalar', {int32(-1), int32(0), int32(1)})
        doubleMatrixType = symphonyui.core.PropertyType('denserealdouble', 'matrix')
        stringType = symphonyui.core.PropertyType('char', 'row')
        setType = symphonyui.core.PropertyType('cellstr', 'row', {'a', 'set', 'of', 'strings'})
        selectionType = symphonyui.core.PropertyType('char', 'row', {'spring', 'summer', 'fall', 'winter'})
        suggestionType = symphonyui.core.PropertyType('char', 'row', {'banana', 'apple', 'pear', 'kiwi', '...'})
        numberType = symphonyui.core.PropertyType('denserealdouble', 'row', {1, 2, 3, 4})
        dateType = symphonyui.core.PropertyType('char', 'row', 'datestr')
        treeType = symphonyui.core.PropertyType('char', 'row', struct('folder1', {{'item1', 'item2'}}, 'folder2', {{'item1', 'item2'}}, 'item1', []))
    end
    
end

