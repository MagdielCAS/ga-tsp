%Retorna os filhos completos, sem repetições.
function [son1, son2]  = fillson(son1, son2,progen1,progen2, people, Cities)
    cont1 = 1;
    cont2 = 1;
    elected1 = zeros(1,Cities);
    elected2 = zeros(1,Cities);
    for a = 1:Cities
        this1 = people(progen1,a); %recebe a cidade 'a' do individuo 'progen(1)'
        if ~ismember(this1,son1) %verifica se a cidade já foi adicionada ao filho
            elected1(cont1) = this1; %guarda os cromossomos que faltam do filho 1
            cont1 = cont1+1;
        end 
        this2 = people(progen2,a); %recebe a cidade 'a' do individuo 'progen(1)'
        if ~ismember(this2,son2) %verifica se a cidade já foi adicionada ao filho
            elected2(cont2) = this2; %guarda os cromossomos que faltam do filho 2
            cont2 = cont2+1;
        end 
    end
    cont1 =1;
    cont2 =1;
    %Adiciona os cromossomos eleitos aos locais vazios de cada filho
    for a = 1:Cities
        if(son1(1,a)==0) %Verifica se tem cromossomo na posição a
            son1(1,a)=elected1(cont1);
            cont1=cont1+1;
        end
        if(son2(1,a)==0) %Verifica se tem cromossomo na posição a
            son2(1,a)=elected2(cont2);
            cont2=cont2+1;
        end
    end
end
