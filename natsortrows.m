function [B,ndx,dbg] = natsortrows(A,rgx,varargin)
% Natural-order / alphanumeric sort the atomic rows of an array.
%
% (c) 2014-2024 Stephen Cobeldick
%
% Sort text by character code and by number value. For a cell/string array:
% - SORTROWS <column> option is supported, selects the columns to sort by.
% - SORTROWS <direction> option is supported, specifies the sort directions.
% For a table/timetable array any string or cell-array-of-char-vector
% variables are sorted alphanumerically, all other types via SORT/SORTROWS.
% For a table/timetable the options above are supported and additionally:
% - SORTROWS 'RowNames' and <rowDimName> options are supported.
% - SORTROWS <vars> option is supported, selects the variables to sort by.
%
%%% Example:
% >> A = ["A2","X";"A10","Y";"A10","X","A1","X"];
% >> natsortrows(A)
% ans =
%     "A1"     "X"
%     "A2"     "X"
%     "A10"    "X"
%     "A10"    "Y"
%
%%% Syntax:
%  B = natsortrows(A)
%  B = natsortrows(A,rgx)
%  B = natsortrows(A,rgx,<options>)
% [B,ndx,dbg] = natsortrows(A,...)
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort any file-names or folder-names use NATSORTFILES (File Exchange 47434)
% To sort string/cells using custom sequences use ARBSORT (File Exchange 132263)
%
%% File Dependency %%
%
% NATSORTROWS requires the function NATSORT (File Exchange 34464). Extra
% optional arguments are passed directly to NATSORT. See NATSORT for case-
% sensitivity, sort direction, number format matching, and other options.
%
%% Examples %%
%
% >> Aa = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
% >> sortrows(Aa) % SORTROWS for comparison.
% ans =
%    'A'  '100'  'X'
%    'A'    '2'  'Y'
%    'A'   '20'  'X'
%    'B'   '10'  'X'
%    'B'    '2'  'X'
% >> natsortrows(Aa)
% ans =
%    'A'    '2'  'Y'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
% >> natsortrows(Aa,[],'descend')
% ans =
%     'B'  '10'  'X'
%     'B'   '2'  'X'
%     'A' '100'  'X'
%     'A'  '20'  'X'
%     'A'   '2'  'Y'
%
% >> sortrows(Aa,[2,-3]) % SORTROWS for comparison.
% ans =
%    'B'   '10'  'X'
%    'A'  '100'  'X'
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'A'   '20'  'X'
% >> natsortrows(Aa,[],[2,-3])
% ans =
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
% >> natsortrows(Aa,[],[false,true,true],{'ascend','descend'})
% ans =
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
% >> natsortrows(Aa,[],{'ignore','ascend','descend'})
% ans =
%    'A'    '2'  'Y'
%    'B'    '2'  'X'
%    'B'   '10'  'X'
%    'A'   '20'  'X'
%    'A'  '100'  'X'
%
% >> T = cell2table(Aa, 'VariableNames',{'V1','V2','V3'});
% >> natsortrows(T,[], [2,-3]) % TABLE
% ans =
%     V1      V2      V3
%     ___    _____    ___
%     'A'    '2'      'Y'
%     'B'    '2'      'X'
%     'B'    '10'     'X'
%     'A'    '20'     'X'
%     'A'    '100'    'X'
% >> natsortrows(T,[], {'V2','V3'},{'ascend','descend'}) % TABLE
% ans =
%     V1      V2      V3
%     ___    _____    ___
%     'A'    '2'      'Y'
%     'B'    '2'      'X'
%     'B'    '10'     'X'
%     'A'    '20'     'X'
%     'A'    '100'    'X'
%
% >> Ab = {'ABCD';'3e45';'67.8';'+Inf';'-12';'+9';'NaN'};
% >> sortrows(Ab) % SORTROWS for comparison.
% ans =
%    '+9'
%    '+Inf'
%    '-12'
%    '3e45'
%    '67.8'
%    'ABCD'
%    'NaN'
% >> natsortrows(Ab,'(+|-)?(NaN|Inf|\d+\.?\d*([eE](+|-)?\d+)?)')
% ans =
%    '-12'
%    '+9'
%    '67.8'
%    '3e45'
%    '+Inf'
%    'NaN'
%    'ABCD'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array of size MxN, with atomic rows to be sorted. Can be a string
%       array, or a cell array of character row vectors, or a categorical
%       array, or any other array type supported by NATSORT.
%     = Table of size MxN, with atomic rows to be sorted. Columns/variables
%       that are string, categorical, or cell of character row vectors are
%       sorted using NATSORT, all other column types are sorted using SORT.
% rgx = Optional regular expression to match number substrings.
%     = []** uses the default regular expression (see NATSORT).
% <options> can be supplied in any order:
%     = Logical vector indicating which columns of <A> to sort by.
%     = <column>: numeric vector where each integer specifies which columns
%       of <A> to sort by. Negative integers indicate a descending sort.
%     = <direction>: a cell array containing only the character vectors
%       'ascend', 'descend', and/or 'ignore'. The number of cells must match
%       the number of columns being sorted. The sign of <column> is ignored.
% <options> additionally supported for tables/timetables:
%     = 'RowNames' or <rowDimName> (the name of first dimension of
%       table <A>): sorts table <A> based on its row names.
%     = <vars>: a cell array containing the names (character row vectors)
%       of the timetable/table <A> variables to sort by.
% Any remaining <options> are passed directly to NATSORT.
%
%%% Outputs:
% B   = Array <A> with rows sorted into alphanumeric order.
% ndx = NumericVector, size Mx1. The row indices such that B = A(ndx,:).
% dbg = CellArray, size 1xN. Each cell contains the debug cell array for
%       one column of <A>. Helps debug the regular expression (see NATSORT).
%
% See also SORT SORTROWS NATSORTROWS_TEST NATSORT NATSORTFILES ARBSORT IREGEXP
% REGEXP COMPOSE STRING CATEGORICAL CELL2TABLE ARRAY2TABLE TABLE TIMETABLE CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
assert(ndims(A)<3,...
	'SC:natsortrows:A:NotMatrix',...
	'First input <A> must be a matrix (2D).') %#ok<ISMAT>
%
[nmr,nmc] = size(A);
ndx = 1:nmr;
dbg = cell(1,nmc);
%
dai = {'descend','ascend','ignore'};
iso = false;
ist = isa(A,'table') || isa(A,'timetable'); % istabular
chk = 'RowNames|SortNum';
%
varargin = cellfun(@nsr1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
%% Columns to Sort %%
%
ida = any(strcmpi(txt,'descend') | strcmpi(txt,'ascend') | strcmpi(txt,'ignore'));
%
xca = cellfun(@iscell,xtx); % direction
xbo = cellfun(@islogical,xtx); % column
xnu = cellfun(@isnumeric,xtx); % column
%
assert(nnz(xbo|xnu)<2,...
	'SC:natsortrows:column:Overspecified',...
	'The <column> option is over-specified: one logical or numeric vector is allowed.')
%
if any(xbo) % logical
	axc = find(xtx{xbo});
	assert(max(axc)<=nmc && isvector(xtx{xbo}),...
		'SC:natsortrows:column:IndexMismatchLogical',...
		'The <column> option must be a vector of logical indices into columns of <A>.')
elseif any(xnu) % numeric
	col = xtx{xnu};
	assert(isvector(col) && isreal(col) && all(~mod(col,1)) && all(col) && all(abs(col)<=nmc),...
		'SC:natsortrows:column:IndexMismatchNumeric',...
		'The <column> option must be a vector of subscript indices into columns of <A>.')
	aso = dai((3+sign(col))/2);
	iso = ~ida;
	axc = abs(col);
else
	axc = 1:nmc;
end
%
if ist % table
	prn = A.Properties.RowNames;
	pvn = A.Properties.VariableNames;
	pdn = A.Properties.DimensionNames(1);
	%
	chk = sprintf('|%s','SortNum',prn{:},pvn{:},pdn{:});
	chk = sprintf('RowNames%s',chk);
	%
	tvn = ismember(txt,pvn);
	trn = strcmpi(txt,'RowNames') | strcmpi(txt,pdn);
	%
	if any(trn) % sort by table row names
		assert(nnz(trn)<2,...
			'SC:natsortrows:RowNames:Overspecified',...
			'The "RowNames" or <rowDimName> option is over-specified, may be used once.')
		assert(~any(xca|xbo|xnu) && ~any(tvn),...
			'SC:natsortrows:RowNames:NotExclusive',...
			'The "RowNames" or <rowDimName> option cannot be combined with <column> or <var> options.')
		txt(trn) = [];
		if nargin>1
			nsrChkRgx(rgx,chk)
			txt = [{rgx},txt];
		end
		dbg = {[]};
		if numel(prn)
			if nargout<3 % faster:
				[~,ndx] = natsort(prn,txt{:},xtx{:});
			else % for debugging:
				[~,ndx,dbg] = natsort(prn,txt{:},xtx{:});
			end
		end
		ndx = ndx(:);
		B = A(ndx,:);
		return
	elseif any(tvn) % sort by one variable name
		assert(nnz(tvn)<2,...
			'SC:natsortrows:VariableName:Overspecified',...
			'To specify multiple variable names use a cell array of character vectors.')
		assert(~any(xca|xbo|xnu),...
			'SC:natsortrows:VariableName:NotExclusive',...
			'A variable name cannot be combined with <column> or <var> cell array options.')
		axc = find(strcmp(txt{tvn},pvn));
		txt(tvn) = [];
	elseif any(xca) % sort by <direction> and/or <vars>
		prd = false;
		prv = false;
		xnc = find(xca);
		for jj = 1:numel(xnc)
			sbc = xtx{xnc(jj)};
			assert(isvector(sbc),...
				'SC:natsortrows:option:CellNotVector',...
				'Optional cell arrays must be vectors.')
			assert(all(fnh(sbc)),...
				'SC:natsortrows:option:CellContentNotChar',...
				'Optional cell arrays must contain only character row vectors.')
			tmp = lower(sbc);
			if all(ismember(tmp,dai)) % <direction>
				assert(~prd && ~ida,...
					'SC:natsortrows:direction:Overspecified',...
					'The <direction> option is over-specified, may be used only once.')
				aso = tmp;
				iso = true;
				prd = true;
			else % <vars>
				assert(~prv,...
					'SC:natsortrows:vars:Overspecified',...
					'The <vars> option is over-specified, may be used only once.')
				assert(~any(xbo|xnu),...
					'SC:natsortrows:vars:NotExclusive',...
					'The <vars> option cannot be combined with <column> or RowName options.')
				axc = nan(size(sbc));
				for kk = 1:numel(sbc)
					tmp = strcmp(sbc{kk},pvn);
					assert(nnz(tmp)==1,...
						'SC:natsortrows:vars:UnrecognizedName',...
						'The <vars> option has an unrecognised variable name: "%s".',sbc{kk})
					axc(kk) = find(tmp);
				end
				prv = true;
			end
		end
		if prd
			assert(numel(aso)==numel(axc),...
				'SC:natsortrows:direction:NumberDirections',...
				'The <direction> cell array must specify one direction for each column to be sorted.')
		end
	end
elseif any(xca) % array
	assert(~ida && nnz(xca)<2,...
		'SC:natsortrows:direction:Overspecified',...
		'The <direction> option is over-specified, may be used only once.')
	aso = xtx{xca};
	iso = true;
	assert(isvector(aso),...
		'SC:natsortrows:direction:CellNotVector',...
		'The <direction> option cell array must be a vector.')
	assert(all(fnh(aso)),...
		'SC:natsortrows:direction:CellContentNotChar',...
		'The <direction> cell array must contain only character row vectors.')
	aso = lower(aso);
	assert(all(ismember(aso,dai)),...
		'SC:natsortrows:direction:NotAscendDescend',...
		'The <direction> cell array may contain only ''ascend'', ''descend'', and ''ignore''.')
	assert(numel(aso)==numel(axc),...
		'SC:natsortrows:direction:NumberDirections',...
		'The <direction> cell array must specify one direction for each column to be sorted.')
end
%
xtx(xca|xbo|xnu) = [];
%
if nargin>1
	nsrChkRgx(rgx,chk)
	txt = [{rgx},cell(1,+iso),txt];
end
%
%% Sort Matrices %%
%
for ii = numel(axc):-1:1
	axk = axc(ii);
	if iso % sort order:
		txt{2} = aso{ii};
	end
	if any(strcmpi(txt,'ignore'))
		continue
	elseif ist % table
		tmp = A{ndx,axk};
		if isa(tmp,'string')||iscell(tmp)&&all(fnh(tmp(:)))
			if size(tmp,2)==1
				if nargout<3 % faster:
					[~,idx] = natsort(tmp,txt{:},xtx{:});
				else % for debugging:
					[~,idx,gbd] = natsort(tmp,txt{:},xtx{:});
					[~,idb] = sort(ndx);
					dbg{axk} = gbd(idb,:);
				end
			else
				[~,idx] = natsortrows(tmp,txt{:},xtx{:});
			end
		else % numeric, logical, categorical, datetime, etc.
			isd = any(strcmpi(txt,'descend'));
			col = (1-2*isd).*(1:size(tmp,2));
			[~,idx] = sortrows(tmp,col);
		end
	else % char, string, cell of char vectors, categorical, datetime, etc.
		if nargout<3 % faster:
			[~,idx] = natsort(A(ndx,axk),txt{:},xtx{:});
		else % for debugging:
			[~,idx,gbd] = natsort(A(ndx,axk),txt{:},xtx{:});
			[~,idb] = sort(ndx);
			dbg{axk} = gbd(idb,:);
		end
	end
	ndx = ndx(idx);
end
%
ndx = ndx(:);
B = A(ndx,:);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortrows
function nsrChkRgx(rgx,chk)
chk = sprintf('^(%s)$',chk);
assert(~ischar(rgx)||isempty(regexpi(rgx,chk,'once')),...
	'SC:natsortrows:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided expression "%s" looks like an optional argument (inputs 3+).'],rgx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsrChkRgx
function arr = nsr1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsr1s2c