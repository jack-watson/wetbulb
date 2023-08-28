function tf = isffield(S, fieldname)

% isffield: "is filled field", for lack of a better term

% simple helper function that (A) checks if struct has field fieldname,
% and (B) checks if S.fieldname is non-empty. If both of these conditions
% are true, tf = isffield() returns true. Otherwise, returns false.

tf = isfield(S, fieldname) && ~isempty(S.(fieldname));

end