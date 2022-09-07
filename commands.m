pkg load statistics
pkg load io
C = csv2cell( 'results.csv' )


for j= 5:columns(C)
  y = cell2mat(C(2:rows(C),j))
  X = [cell2mat(C(2:rows(C),1)),cell2mat(C(2:rows(C),2)),cell2mat(C(2:rows(C),3)),cell2mat(C(2:rows(C),4))]
  [B, BINT, R, RINT, STATS] = regress(y, X)
  Y = B(1)*X(:,1)+B(2)*X(:,2)+B(3)*X(:,3)+B(4)*X(:,4)
  res = [X(:,1),X(:,2),X(:,3),X(:,4),Y]
  
  fid = fopen (strcat('octave-results/',C{1,j},'.csv'), "a");
  fprintf(fid, "%s,%s,%s,%s,%s,Function\n", C{1,1},C{1,2},C{1,3},C{1,4},C{1,j})
  for i= 1:rows(res)
    fl = {C{1,j}}
    fprintf(fid, "%d,%d,%d,%d,%d,%s\n", res(i,1),res(i,2),res(i,3),res(i,4),res(i,5),strcat('y = ',mat2str(B(1)),'*delay + ',mat2str(B(2)),'*stdConcurrency + ',mat2str(B(3)),'*memmorySize + ',mat2str(B(4)),'*userMemmory'))
  endfor
  fclose (fid);
endfor
