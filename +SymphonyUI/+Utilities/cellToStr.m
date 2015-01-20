function s = cellToStr(c)
    s = cellfun(@(x) [char(x) ', '], c, 'UniformOutput', false);
    s = cell2mat(s);
    s(end-1:end) = [];
end

