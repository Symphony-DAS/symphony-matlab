function s = cellToStr(c, delimiter)
    if ~iscell(c)
        c = {c};
    end
    if nargin < 2
        delimiter = ', ';
    end

    s = cellfun(@(x) [char(x) delimiter], c, 'UniformOutput', false);
    s = cell2mat(s);
    s(end-length(delimiter)+1:end) = [];
end

