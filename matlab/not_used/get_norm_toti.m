function get_data(type,sel,i)
%
% selection file for the occupied angle bins
j = sel(i);
out = strcat('/data2/liaoh/new_with_covar_reduce_index_DHX_',type,'/big_tot_matlab/tot_',num2str(i,'%05d'));
p = load(out);
B = sum(p.toti,2);
out_head = strcat('covar/stats/norm_scovar_',type);
write_image_stack(out_head,j,full(B));
  
