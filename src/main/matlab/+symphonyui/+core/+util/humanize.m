% epochGroup => Epoch group
% epoch_group => Epoch group

function out = humanize(in)
    % To camelCase.
    out = regexprep(in, '_+(\w?)', '${upper($1)}');
    
    % Split words.
    out = regexprep(out, '([A-Z][a-z]+)', ' $1');
    out = regexprep(out, '([A-Z][A-Z]+)', ' $1');
    out = regexprep(out, '([^A-Za-z ]+)', ' $1');
    
    % To sentence case.
    out = strtrim(out);
    out(1) = upper(out(1));
    out(2:end) = lower(out(2:end));
end

