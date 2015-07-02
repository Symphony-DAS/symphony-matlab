function p = screenCenter(w, h)
    s = get(0, 'ScreenSize');
    sw = s(3);
    sh = s(4);
    x = (sw - w) / 2;
    y = (sh - h) / 2;
    p = [x y w h];
end

