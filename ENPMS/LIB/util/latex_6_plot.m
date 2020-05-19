function latex_6_plot(DIR_PNGS,LATEX_FILENAME,LATEX_HEADER,LATEX_RELATIVE_PNG_PATH)

% Process the DFS0 and *.png files for inclusion on PDFs.
format compact
PNGFILES = [DIR_PNGS '*.png'];
VECPNG = ls(PNGFILES);                                      % list all files in DIRPNG with extension *.png
[num_pngs,~] = size(VECPNG);
noFIG = 3;                                                  % Set the number of image rows per latex page. Value can either be 2 or 3.

FID = fopen(LATEX_FILENAME,'w');

latex_print_begin(FID,LATEX_HEADER);

for i = 1:num_pngs
    m = mod(i,2);                                       % This variable has no usage within this or any other function/script. Consider revising, removing this variable completely.
    n = mod(i,3);
    
%    if m == 0; noFIG = 3; else; noFIG = 2; end  % This is not the correct
%    way to determine NoFIG. Need to deteremine a better method else just
%    default to a 2 column 3 row image layout
    
    if mod(i,6) == 1; latex_begin_new_page(FID); end                        % If this is the first image to be processed, begin the latex page design.
    
    [~,NAME,EXT] = fileparts(VECPNG(i,:));
    latex_print_pages_figures(m,n,FID,LATEX_RELATIVE_PNG_PATH,NAME,strtrim(EXT),noFIG);
    
    if ~mod(i,6) || i == num_pngs, latex_end_page(FID); end           % If the page has 6 total figures, or i is the last image in the list, end the latex page.
end

latex_print_end(FID)
fclose(FID);

end
