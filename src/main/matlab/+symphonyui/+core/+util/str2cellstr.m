function c = str2cellstr(s)
    if isempty(s) || (s(1) ~= '{' || s(end) ~= '}')
        error('Expected string to start with ''{'' and end with ''}''');
    end
    s = s(2:end-1);
    if isempty(s)
        c = {};
    elseif ~isempty(strfind(s, ','))
        c = strsplit(s, ',');
    else
        c = strsplit(s, ';')';
    end
end

