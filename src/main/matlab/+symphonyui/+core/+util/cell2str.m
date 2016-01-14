function s = cell2str(c)
    if ~iscellstr(c)
        error('Cell must be a cellstr');
    end
    if ~isrow(c) && ~iscolumn(c)
        error('Cell must be a row or column');
    end
    if isrow(c)
        s = ['{' strjoin(c, ',') '}'];
    elseif iscolumn(c)
        s = ['{' strjoin(c, ';') '}'];
    end
end

