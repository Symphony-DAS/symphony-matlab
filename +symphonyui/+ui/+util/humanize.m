% epochGroup => Epoch Group

function out = humanize(in)
    out = regexprep(in, '([A-Z][a-z]+)', ' $1');
    out = regexprep(out, '([A-Z][A-Z]+)', ' $1');
    out = regexprep(out, '([^A-Za-z ]+)', ' $1');
    out = strtrim(out);
end

