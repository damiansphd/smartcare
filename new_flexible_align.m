function [final, plp, plp2, hstg, qualete] = new_flexible_align(normcube, dubiousproblem, max_offset, align_wind, run_mode)

%run_mode = 'new';
basedir = './';
subfolder = 'Plots';

model22 = zeros(2,max_offset+align_wind,4);
plp = zeros(4,max_offset+align_wind);
plp2 = zeros(4,max_offset+align_wind);
[a b] = size(dubiousproblem);
hstg = zeros(4,a,max_offset);
qualete = 0;
for z=1:a
    add_to_mean(z);
end
for k = 1:4
    for dd=1:max_offset+align_wind
        plp(k,dd)=  model22(1,dd,k)/model22(2,dd,k);
    end
end

pnt = 1;
% 
%computation
%
cnt = 0;
ok = 0;
while 1
    remove_from_mean(pnt);
    %check safety
    ok = 1;
    for i=1:max_offset+align_wind
        for j=1:4
            if model22(2,i,j) < 3
                ok = 0;
            end
        end
    end
    if ok == 1
        best = best_fit(pnt);
    else
        best = dubiousproblem.offset(pnt);
    end
    
    if best ~= dubiousproblem.offset(pnt)
        dubiousproblem.offset(pnt) = best;
        cnt = cnt+1;
    end
    add_to_mean(pnt);
        
    pnt = pnt+1;
    if pnt > a
        pnt = pnt - a;
        if cnt == 0
           % disp('DONE');
            break;
        else
           %disp(cnt);
            cnt = 0;
        end
    end
end

%computing the objective function
for i=1:a
    remove_from_mean(i);
    qualete = qualete + distance(i, dubiousproblem.offset(i), 0);
    add_to_mean(i);
end



final = zeros(1,a);
for u=1:a 
    final(u) = dubiousproblem.offset(u);
end

for k = 1:4
    for dd=1:max_offset+align_wind
        plp2(k,dd)=  model22(1,dd,k)/model22(2,dd,k);
    end
end

f = figure;
if f.Number == 1
    append = 'Zero Offset Start';
else
    append = sprintf('Random Start %d', f.Number-1);
end
if run_mode == 'new'
    prefix = 'New';
else
    prefix = 'Old';
end
p = uipanel('Parent',f,'BorderType','none'); 
% p.Title = ['Objective function = ',num2str(qualete)]; 
p.Title = sprintf('%s Data - %s - ErrFcn = %6.1f', prefix, append, qualete);
p.TitlePosition = 'centertop'; 
p.FontSize = 16;
p.FontWeight = 'bold'; 
    subplot(3,2,1,'Parent',p)
        plot([-1*(max_offset+align_wind):-1], plp(1,:), 'color', 'blue')
        xlim([-50 0]);
        ylim([-2.5 0.5])
        hold on;
        plot([-1*(max_offset+align_wind):-1], plp2(1,:), 'color', 'red');
        hold off;
        title('Activity normalised')
    subplot(3,2,2,'Parent',p)
        plot([-1*(max_offset+align_wind):-1], plp(2,:),'color', 'blue')
        xlim([-50 0]);
        ylim([-2.5 0.5])
        hold on;
        plot([-1*(max_offset+align_wind):-1], plp2(2,:), 'color', 'red');
        hold off;
        title('Cough normalised')
    subplot(3,2,3,'Parent',p)
        plot([-1*(max_offset+align_wind):-1], plp(3,:),'color', 'blue')
        xlim([-50 0]);
        ylim([-2.5 0.5])
        hold on;
        plot([-1*(max_offset+align_wind):-1], plp2(3,:), 'color', 'red');
        hold off;
        title('FEV1 normalised')
    subplot(3,2,4,'Parent',p)
        plot([-1*(max_offset+align_wind):-1], plp(4,:),'color', 'blue')
        xlim([-50 0]);
        ylim([-2.5 0.5])
        hold on;
        plot([-1*(max_offset+align_wind):-1], plp2(4,:), 'color', 'red');
        hold off;
        title('Wellness normalised')
    subplot(3,2,[5 6],'Parent',p)
        histogram(final)
        xlim([-0.5 24.5]);
        ylim([0 50]);
        title('Histogram')


filename = sprintf('%s Data - %s - Err Function.png', prefix, append);
saveas(f,fullfile(basedir, subfolder, filename));
%saveas(f,['summary',num2str(num),'.png']);

function [] = remove_from_mean( x )
    shift = dubiousproblem.offset(x);
    for v=1:max_offset+align_wind-shift
        for w = 1:4
            if dubiousproblem.Start(x)-v <= 0
                continue;
            end
            if ~isnan( normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-v,w))
                model22(1,(max_offset+align_wind+1)-shift-v,w) = model22(1,(max_offset+align_wind+1)-shift-v,w) - normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-v,w);
                model22(2,(max_offset+align_wind+1)-shift-v,w) = model22(2,(max_offset+align_wind+1)-shift-v,w) -1;
            end
        end
    end
    
end



function [] = add_to_mean( x )
    shift = dubiousproblem.offset(x);
    for v=1:max_offset+align_wind-shift
        for w = 1:4
            if dubiousproblem.Start(x)-v <= 0
                continue;
            end
            if ~isnan( normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-v,w))
                model22(1,(max_offset+align_wind+1)-shift-v,w) = model22(1,(max_offset+align_wind+1)-shift-v,w) + normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-v,w);
                model22(2,(max_offset+align_wind+1)-shift-v,w) = model22(2,(max_offset+align_wind+1)-shift-v,w) +1;
            end
        end
    end
end

%calculate the cost of gluing
function [dist] = distance( x , off, updatehistogram)
    dist = 0;
    
    for p=1:align_wind
        for q=1:4
            if dubiousproblem.Start(x)-p <= 0
                continue;
            end
            if ~isnan(normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-p,q))
                dist = dist + ( model22(1,(max_offset+align_wind+1)-p-off,q)/model22(2,(max_offset+align_wind+1)-p-off,q) - normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-p,q))^2;
                if (updatehistogram == 1)
                    hstg(q,x,off+1) = hstg(q,x,off+1)+( model22(1,(max_offset+align_wind+1)-p-off,q)/model22(2,(max_offset+align_wind+1)-p-off,q) - normcube(dubiousproblem.ID(x),dubiousproblem.Start(x)-p,q))^2;
                    % fprintf('hstg(%d,%d,%d) = %d \n',q,x,off+1,hstg(q,x,off+1));
                else
                   %fprintf('calculating distance for %d, %d, %d but not updating hstg\n', x, p, q);
                end
            end
        end
    end
    
end


%compute the best offset
function [laus] = best_fit( red )
    for zz=1:4
        for qq=1:max_offset
            hstg(zz,red,qq) = 0;
        end
    end
    laus = 0;
    mini = 1000000;
    for r=0:max_offset-1
        curr = distance(red,r, 1);
        if curr < mini
            laus = r;
            mini = curr;
        end
    end
end
end