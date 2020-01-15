function test(prj, ind2, i, j)

addpath /guam.raid.home/liaoh/lib/matlab
 %
 da_s=compress_data_stack(prj,ind2,2);
 data1=da_s(j,:);
 data1(1:10)
 
 %
 data=reshape(prj(j,:),32,32);
 da=compress_data(data,ind2,2);
 da(1:10)