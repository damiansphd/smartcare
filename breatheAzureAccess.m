clear; clc; close all;

tic

%setenv MW_WASB_SAS_TOKEN '?st=2019-11-18T10%3A30%3A12Z&se=2020-01-31T10%3A30%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=K2eIs8G3%2FCYtVlH0WoL2i0hbipfspb55XtY6NLEQNXA%3D';
setenv MW_WASB_SAS_TOKEN '?st=2020-02-10T13%3A58%3A17Z&se=2020-10-01T14%3A58%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=2rckL4bC5zqtSvtaYIaTsbkibfFN5gqAaqxWBAYPQdc%3D';
 
[clinicaldate, measdate, guidmapdate] = getLatestBreatheDates();
[basedir] = setBaseDir();
subfolder = 'DataFiles/ProjectBreathe';

fprintf('Getting list of measurement files from Azure for date %s\n', measdate)
mdir = sprintf('wasbs://avatardatadropprod@breatheprodstorageavatar.blob.core.windows.net/%s', measdate);
dirds = tabularTextDatastore(mdir, 'Delimiter', ',');
filelist = dirds.Files;
nfiles = size(filelist, 1);
fprintf('Total of %d files to download\n', nfiles);

for f = 1:nfiles
    location = filelist(f);
    fileds = tabularTextDatastore(location, 'Delimiter', ',');
    filename = erase(filelist{f}, sprintf('%s/', mdir));
    fprintf('%d of %d: Downloading %28s....', f, nfiles, filename);
    filename = sprintf('%s.csv', filename);
    fdata = readall(fileds);
    fprintf('%d Rows....', size(fdata, 1));
    writetable(fdata, fullfile(basedir, subfolder, filename));
    fprintf('Saving csv file\n');
end

%guidurl = 'https://onedrive.live.com/?authkey=%21Av%5FdzCbIxs8fdVk&id=4DB1BBA0C3BC9D88%211189&cid=4DB1BBA0C3BC9D88'
%https://onedrive.live.com/edit.aspx?cid=4db1bba0c3bc9d88&page=view&resid=4DB1BBA0C3BC9D88!1047&parId=4DB1BBA0C3BC9D88!1189&authkey=!Av_dzCbIxs8fdVk&app=Excel
%guidurl = 'https://1drv.ms/x/s!BIidvMOgu7FNiBcNigvgSV6II244?e=aykJENjKjE6tPCUlhfS1iA&at=9';
%guidurl = 'https://onedrive.live.com/view.aspx?resid=4DB1BBA0C3BC9D88!1047&ithint=file%2cxlsx&authkey=!Ag2KC-BJXogjbjg';
%options = weboptions('ContentType','text');
%guidmap = webread(guidurl, options);
%guidmap = readtable(guidurl);
%test = datastore(guidurl);
%urlwrite(guidurl,fullfile(basedir, subfolder, 'test.csv'));
%M=importdata(myFileName);