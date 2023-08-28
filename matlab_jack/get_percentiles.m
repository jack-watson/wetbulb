function pct = get_percentiles(A, pctile)

pct = zeros(size(A(:,:,1)));
for yi = 1:size(A,1)
    for xi = 1:size(A,2)
        series = reshape(A(yi,xi,:), [], 1, 1);
        pi = prctile(series, pctile);
        pct(yi,xi) = pi;
    end
end

end