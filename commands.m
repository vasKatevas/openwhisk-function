pkg load statistics
pkg load io
C = csv2cell( 'results.csv' )

for i= 1:4
  for j= 5:columns(C)
    y = cell2mat(C(2:rows(C),j))
    x = cell2mat(C(2:rows(C),i))
      [B, BINT, R, RINT, STATS] = regress(y, x)
    Y = BINT(1) + BINT(2)*x
    res = [x,Y]
    fl = {C{1,i},C{1,j}}
    #dlmwrite(strcat('octave-results/',C{2,i},'-',C{2,j},'.csv'),fl)
    fid = fopen (strcat('octave-results/',C{1,i},'-',C{1,j},'.csv'), "w");
    fprintf(fid, "%s,%s\n", fl'{:})
    fclose (fid);
    dlmwrite(strcat('octave-results/',C{1,i},'-',C{1,j},'.csv'),res,"-append")
  endfor
endfor


#for loop for each input and output combination 1-5 6-17
#This is how i will name the files strcat(Name,TopG,mat2str(i))
