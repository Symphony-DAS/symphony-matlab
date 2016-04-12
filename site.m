function site()
    rootPath = fileparts(mfilename('fullpath'));
    sitePath = fullfile(rootPath, 'src', 'site');
    targetPath = fullfile(rootPath, 'target', 'site');
    
    markdownPath = fullfile(sitePath, 'markdown');
    
    markdownFiles = dir(fullfile(markdownPath, '*.md'));
    for i = 1:length(markdownFiles)
        markdown = markdownFiles(i);
        
        [~, name] = fileparts(markdown.name);
        
        input = fullfile(markdownPath, [name '.md']);
        output = fullfile(targetPath, [name '.html']);
        
        command = sprintf('pandoc -c bootstrap.min.css -s -f markdown_github "%s" -o "%s"', input, output);
        system(command);
        replace(output, '.md', '.html'); 
    end
    
    copyfile(fullfile(sitePath, 'info.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'helptoc.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'resources', 'css', 'bootstrap.min.css'), fullfile(targetPath));
end

function replace(file, expression, replacement)
    fid = fopen(file);
    text = fread(fid, inf, '*char')';
    fclose(fid);
    
    text = regexprep(text, expression, replacement);
    
    fid = fopen(file, 'w');
    fwrite(fid, text);
    fclose(fid);
end