function c = strToCell(s)
    c = strsplit(s, '[,;]+', 'DelimiterType', 'RegularExpression');
    c = strtrim(c);
end

