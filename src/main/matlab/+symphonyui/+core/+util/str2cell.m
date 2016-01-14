function c = str2cell(s)
    if isempty(s) || (s(1) ~= '{' && s(end) ~= '}')
        error('Expected string to start with ''{'' and end with ''}''');
    end
    s = s(2:end-1);
    if ~isempty(strfind(s, ','))
        c = strsplit(s, ',');
    else
        c = strsplit(s, ';')';
    end
end

