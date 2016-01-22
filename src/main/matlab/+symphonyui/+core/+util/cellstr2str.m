function s = cellstr2str(c)
    if ~iscellstr(c)
        error('Cell must be a cellstr');
    end
    if ~isvector(c) && ~isempty(c)
        error('Cell must be a row or column');
    end
    if any(~cellfun(@isempty, strfind(c, ','))) || any(~cellfun(@isempty, strfind(c, ';')))
        error('Cell array of strings with '','' or '';'' characters are not supported');
    end
    if isrow(c)
        s = ['{' strjoin(c, ',') '}'];
    else
        s = ['{' strjoin(c, ';') '}'];
    end
end

