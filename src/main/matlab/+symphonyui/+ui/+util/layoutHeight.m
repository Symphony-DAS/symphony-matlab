% Calculates the total height of a layout.

function h = layoutHeight(l)
    h = sum(get(l, 'Heights')) + get(l, 'Spacing')*(numel(get(l, 'Heights'))-1);
end

