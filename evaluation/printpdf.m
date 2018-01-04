function printpdf(fname)
%PRINTPDF Prints the current figure into a pdf document

hei = 8;
wid = 10;
set(gcf, 'Units','centimeters', 'Position',[0 0 wid hei]);
set(gcf, 'PaperPositionMode','auto');

set(gca, 'LooseInset', get(gca, 'TightInset'));
fname = [regexprep(fname, '^(.*)\.pdf$', '$1'), '.eps'];
print('-depsc', fname) ;
if ~system(['epstopdf ', fname])
  system(['rm ', fname]);
end
