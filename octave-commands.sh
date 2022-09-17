#!/usr/bin/octave
pkg load statistics
pkg load io

arg_list = argv ();
C = csv2cell(strcat('../results',arg_list{1},'.csv'))

mkdir('.',strcat('../octave-results',arg_list{1}));
fid = fopen (strcat('../octave-results',arg_list{1},'/','functions.csv'), "a");
fprintf(fid, "Function\n")

for j= 5:columns(C)
  y = cell2mat(C(2:rows(C),j))
  X = [cell2mat(C(2:rows(C),1)),cell2mat(C(2:rows(C),2)),cell2mat(C(2:rows(C),3)),cell2mat(C(2:rows(C),4))]
  [B, BINT, R, RINT, STATS] = regress(y, X)
  Y = B(1)*X(:,1)+B(2)*X(:,2)+B(3)*X(:,3)+B(4)*X(:,4)
  res = [X(:,1),X(:,2),X(:,3),X(:,4),Y]
  
  fprintf(fid, "%s\n", strcat(C{1,j},' = ',mat2str(B(1)),'*delay + ',mat2str(B(2)),'*stdConcurrency + ',mat2str(B(3)),'*memmorySize + ',mat2str(B(4)),'*userMemmory'))
endfor
fclose (fid);
