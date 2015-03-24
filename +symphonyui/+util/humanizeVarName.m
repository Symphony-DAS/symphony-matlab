% in:           out:
% myVariable    My Variable

function out = humanizeVarName(in)
    out = regexprep(in,  '([A-Z][a-z]+)', ' $1');
    out = regexprep(out, '([A-Z][A-Z]+)', ' $1');
    out = regexprep(out, '([^A-Za-z ]+)', ' $1');
    out = strtrim(out);
    
    % Capitalize
    idx = regexp([' ' out], '(?<=\s+)\S', 'start') - 1;
    out(idx) = upper(out(idx));
end

