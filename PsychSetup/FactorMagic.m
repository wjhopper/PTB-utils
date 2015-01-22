function factor_cell_mat = factor_magic(nrow, factors)

factor_cell_mat = cell(nrow,size(factors,1));

for i=1:size(factors,1)
    nFactors = length(unique(factors{i,1}));
    if i > 1
        maxSize = max(cellfun(@numel,factors(1:i-1,2)));    %# Get the maximum vector size
        fcn = @(x) [x nan(1,maxSize-numel(x))];  %# Create an anonymous function
        rmat = cellfun(fcn,factors(1:i-1,2),'UniformOutput',false);  %# Pad each cell with NaNs
        vmat = vertcat(rmat{:});                  %# Vertically concatenate cells
        
        if size(vmat,1) > 1
            tmp_wghts = [];
            wghts = zeros(1,numel(vmat(2:end,:))*numel(vmat(1,:)));
            
            for col = 1:size(vmat,2)
                for row = 1:(size(vmat,1)-1)
                    if row <= 1
                        tmp_wghts = vmat(row,col)';
                    end 
                    tmp_wghts =  (tmp_wghts' * vmat(row+1,:))';
                    tmp_wghts = reshape(tmp_wghts,1,[]);
                end
            wghts = horzcat(wghts,tmp_wghts); %#ok<AGROW>
            end 
        else
            wghts = vmat;
        end

    else

        wghts = 1;
    end
    for x=1:length(wghts)
        for j=1:nFactors
            emptyCells = cellfun(@isempty,factor_cell_mat(:,i));
            start = find(emptyCells==1,1);  
            w = nrow*wghts(x);

            factor_cell_mat(start:(w*factors{i,2}(j))+(start-1),i) = repmat({factors{i,1}(j)},(w*factors{i,2}(j)),1);
        end
    end
end


% 
% factors = {[1,2],[.25,.75] ;
%     [1,2],[.5,.5] ;
%     [1,2,3],[1/3,1/3,1/3] }
% factor_magic(2,48,factors)

