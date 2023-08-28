function RL = grid_RLs(k, sig, mu)

ncells = numel(k(:,:,1));
k_vec  = reshape(k, [ncells,1,size(k,3)]);
s_vec  = reshape(sig, [ncells,1,size(sig,3)]);
m_vec  = reshape(mu, [ncells,1,size(mu,3)]);
RL = cell(ncells, 1);
for i = 1:ncells
    ki = k_vec(i,1,:);
    si = s_vec(i,1,:);
    mi = m_vec(i,1,:);
    rli = gevinv(1-1./(0:200), ki, si, mi);
    RL{i} = rli;
end

RL = reshape(cell2mat(RL), [size(k,1), size(k,2), numel(RL{1})]);

end