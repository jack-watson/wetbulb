function [params, confints] = monthlyGParetoFit(A)

nmonths  = round(size(A,3)/30);
maxvals  = zeros(size(A,1),size(A,2),nmonths);
gpparams = zeros(nmonths,2);
gpci     = zeros(nmonths,4);

for i = 1:nmonths
    
    if i == 1 % start case
        start = 1;
    else
        start = i*30;
    end
    
    if start + 30 > size(A,3)
        continue
    end
    
    mon = A(:,:,start:start+30);
    mvi = max(mon,[],3);
    maxvals(:,:,i) = mvi;
    
    [paramest, paramci] = gpfit(reshape(mvi, [numel(mvi),1]) + 1e-12);
    gpparams(i,:) = paramest;
    gpci(i,:)     = reshape(paramci, [1 4]);
    
end

params = gpparams;
confints = gpci;

end

