function factor_cell_mat = FactorMagic(varargin)
ip = inputParser;
addRequired(ip,'nTrials', @isnumeric);
addParamValue(ip,'factors', {struct()}, @(x) iscell(x) && all(cellfun(@isstruct,x)));
addParamValue(ip,'nFactors',@isnumeric);
parse(ip,varargin{:}); 
nTrials = ip.Results.nTrials;
factors = ip.Results.factors;
nFactors = ip.Results.nFactors; %#ok<NASGU>

nesteds = cellfun( @(x) any(strcmp('nested', fieldnames(x))), factors,'Unif',false);
deltas =diff([nesteds{:}]);

if any(deltas >0) && sum(deltas) ==1
    overcount = length(deltas)- find(deltas==1);
elseif any(deltas ~=0) && sum(deltas) ~= 1 
    overcount = sum(abs(find(deltas==1) - find(deltas == -1) -1));
elseif all(deltas ==0)
    overcount = 0;
end

nFactors = numel(factors) - overcount;
factor_cell_mat = cell(nTrials,nFactors);
col_is_numeric=false(1,size(factor_cell_mat,2));
% wghts= zeros(numel(factors), max(cellfun(@(x) numel(x.levels), factors)));
for i=1:numel(factors)
    f = factors{i};
    n = length(f.levels);
    
    if all(cellfun(@isnumeric,f.levels))
        col_is_numeric(i) = true;
    end
    
    if ~strcmp('weights',fieldnames(f))
        f.weights=repmat(1/n,1,n);
        factors{i}.weights=repmat(1/n,1,n);
    end
    
    if i == 1 && ~any(strcmp('nested',fieldnames(f)))
        wghts=f.weights; %#ok<*AGROW>
    elseif i > 1 && ~any(strcmp('nested',fieldnames(f)))
        what = cellfun(@(x) x.weights,factors(1:i),'Unif',false); % get the actual weights out of the cell array of structs
        tmp_wghts = CombVec(what{end:-1:1}); % get all the possible combinations       
        cols = prod(cellfun(@(x) numel(x.levels), factors(1:i-1))); % gets the right number of columns for the weight matrix
        wghts = reshape(prod(tmp_wghts,1), [ cols, i]);
    elseif i > 1 && any(strcmp('nested',fieldnames(f)))
        a = cellfun(@(x) x.levels,factors(1:i-1),'Unif',false); % a is all the possible levels 
        c = cellfun(@(x) any(strcmp('nested',fieldnames(x))), factors(1:i-1),'Unif',false); % use c to ignore any previously nested factors
        b = cellfun(@(x) any(strcmp(f.nested{:},x)), a,'Unif',0); % b tells you which struct to get the weights out, based on which factor has the nesting level
        what = cellfun(@(x) x.weights,factors(1:i),'Unif',false);
        nest_wghts = factors{[b{:}]}.weights;
        nest_wghts = nest_wghts(strcmp(f.nested{:},factors{[b{:}]}.levels));
        tmp_wghts = CombVec(f.weights, nest_wghts, what{1:find([b{:}])-1});
%         cols = prod(cellfun(@(x) numel(x.levels), factors(~[b{:}]))); 
        cols = prod(cellfun(@(x) numel(x.levels), factors([c{:}]==[b{:}])));% gets the right number of columns for the weight matrix
        wghts = reshape(prod(tmp_wghts,1), cols,[]);
    end

    levels = repmat(f.levels',numel(wghts)/numel(f.levels),1);
    w = nTrials*reshape(wghts,numel(wghts),1);
    
    if any(strcmp('nested',fieldnames(f)))
        within = f.nested{:};
        if isnumeric(within)
            places = find([factor_cell_mat{col_is_numeric}] == within);
        elseif ischar(within)
            places = find(strcmp(factor_cell_mat(:,~col_is_numeric(1:i-1)),within));
        end
        
        start =1;
        for x=1:length(levels)
            nReps = ceil(w(x));
            stop = start+nReps - 1 ;
            factor_cell_mat(places(start):places(stop),find([b{:}])+1) = repmat(levels(x),nReps,1);
            start =  stop+1;
        end
    else 
        start =1;
        for x=1:length(levels)
            nReps = ceil(w(x));
            stop = start+nReps;
            factor_cell_mat(start:stop-1,i) = repmat(levels(x),nReps,1);
            start = stop;
        end
    end
    

    
end

