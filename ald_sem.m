clc,clear
% Nastavení velikosti pole
size = 10;

% Nastavení dlaždic, 
dlazdice = [[1,1,1,1];[0,1,0,0];[1,1,0,0];[1,0,0,1];[0,0,1,1]];

% Inicializace polí
possible = ones(size+2,size+2,length(dlazdice));
possible(:,[1,end],:) = 100; % Číslo pro pole se kterými se již nepracuje
possible([1,end],:,:) = 100;

result = zeros(size+2,size+2);
result(1:end,[1,end]) = -1;
result([1,end],1:end) = -1;

% Příprava obrazů k vykreslení
obrazy=zeros(length(dlazdice),3,3);
for i = 1:length(dlazdice)
    obrazy(i,:,:)=[0,dlazdice(i,1),0;dlazdice(i,4),1,dlazdice(i,2);0,dlazdice(i,3),0];
end

% Nastavení prvního bloku (koordinát x, koordinát y, dlaždice #) 
[result, possible] = firstblock(5,5,1,possible,result,dlazdice);

% Inicializace pro backtracking
trycount = 0;
iteration = 1;
results(:,:,iteration)=result;
possibles(:,:,:,iteration)=possible;

while(true)
    % Odkomentovat pro postupné vykreslování
    %draw(result,obrazy);
    %pause

    % Vyplnění všech determinovaných polí
    if (ismember(1,sum(possible,3)))
        [coord1,coord2] = find(1 == sum(possible,3));
        [~,res] = ismember(1,possible(coord1(1),coord2(1),:));
        result(coord1(1),coord2(1)) = res;
        possible = check(coord1(1),coord2(1),possible,result,dlazdice);
    % Najde (náhodné) pole s nejméně možnostmi a vyplní ho náhodnou možnou dlazdici
    else
        iteration=iteration+1;
        [coord1,coord2] = find(min(min(sum(possible,3))) == sum(possible,3));
        %r = randi(length(coord1)); 
        r = 1; % Záměna r na randi vytváří hezčí obrazce, avšak u size>10 vede k problémům s backtrackingem
        mozne_dlazdice = find(possible(coord1(r),coord2(r),:)==1);
        hodnotnota_dlazdice = mozne_dlazdice(randi(length(mozne_dlazdice)));
        result(coord1(r),coord2(r)) = hodnotnota_dlazdice;
        possible = check(coord1(r),coord2(r),possible,result,dlazdice);
        if trycount ~=0
            trycount =trycount-1;
        end
        results(:,:,iteration)=result;
        possibles(:,:,:,iteration)=possible;
    end
    % Kontrola, jestli nejsou pole bez moznych dlazdic
    if (ismember(0,sum(possible,3)))
        iteration = iteration-1;
        trycount= trycount+3;
        if(trycount>10)
            iteration=iteration-floor(trycount/10);
        end
        result = results(:,:,iteration);
        possible = possibles(:,:,:,iteration);
    end
    % Kontrola, jestli není result dokončený
    if(~ismember(0,result))
        break;
    end
end
draw(result,obrazy);

% Funkce vykreslení
function [] = draw(result,obrazy)
    result = result(2:end-1,2:end-1);
    out = zeros(length(result),length(result));
    for i = 1:3:length(result)*3
        for j = 1:3:length(result)*3
            if(result(ceil(j/3),ceil(i/3))==0)
                out(j:j+2,i:i+2) = [0,0,0;0,0,0;0,0,0];
            else 
                out(j:j+2,i:i+2) = obrazy(result(ceil(j/3),ceil(i/3)),:,:);
            end
        end
    end
    imagesc(out)
end

% Funkce pro manuální nastavení bloku
function [result, possibles] = firstblock(x,y,num,possibles,result,dlazdice)
    result(x+1,y+1) = num;
    possibles = check(x+1,y+1,possibles,result,dlazdice);
end

% Funkce pro odstranění nemožných možností
function [possibles] = check(x,y,possibles,result,dlazdice)
    possibles(x,y,:) = 100;
    for i = 1:length(dlazdice)
        if 100 ~= possibles(x-1,y,i) && (dlazdice(result(x,y),1) ~= dlazdice(i,3))
            possibles(x-1,y,i)=0;
        end
        if 100 ~= possibles(x,y+1,i) && (dlazdice(result(x,y),2) ~= dlazdice(i,4))
            possibles(x,y+1,i)=0;
        end
        if 100 ~= possibles(x+1,y,i) && (dlazdice(result(x,y),3) ~= dlazdice(i,1))
            possibles(x+1,y,i)=0;
        end
        if 100 ~= possibles(x,y-1,i) && (dlazdice(result(x,y),4) ~= dlazdice(i,2))
            possibles(x,y-1,i)=0;
        end
    end     
end