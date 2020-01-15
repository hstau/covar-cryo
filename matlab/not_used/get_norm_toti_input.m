function get_data(type,toti,j)  
%
B = sum(toti,2);
out_head = strcat('covar/stats/norm_scovar_',type);
write_image_stack(out_head,j,full(B));
  
