%****Algor�timo Gen�tico para solu��o do problema do caixeiro viajante****%

%Limpar cache
close all;
clear all;
clc;

%################################Parametros###############################%

N = 20;         %Popula��o
Cities = 6;      %N�mero de cidades
m = 0.01;        %Taxa de muta��o
crossrate = 1;   %Taxa de crossover
genMax = 100;    %Limite de gera��es
mutacao = 1;     %Muta��o -> 1 = com muta��o, 0 = sem muta��o
elite = 1;       %Elistimo -> 1 = com elitismo, 0 = sem elitismo
crossover = 0;   %M�todo de crossover -> 0 = crossover discreto modificado, 1 = crossover PMX

%#################################Evolu��o################################%
% for N = 10:2:20 %Tamanho da popula��o
%     for amostramc = 1:500 %amostras de monte carlo
%--------------------------Gerar popula��o inicial------------------------%
        people = zeros(N,Cities);
        for i=1:N
            people(i,:) = randperm(Cities); %Gera individuo
        end
%-------------------------------------------------------------------------%
        gen=0;
        fitpeople = zeros(1,N);  %guarda o valor de fitness de cada indiv�duo
        distpeople = zeros(1,N); %guarda a dist�ncia real para cada indiv�duo
        while(gen<=genMax)
            maior(1) = 0; %valor fitness do melhor indiv�duo
            maior(2) = 0; %�ndice do melhor indiv�duo
            maximum=0;    %acumula o valor de fitness de todos os indiv�duos
            for i=1:N
                [f, d] = fitness(people(i,:));
                fitpeople(i)=f;
                distpeople(i)=d;
                if(f>maior(1))
                    maior(1)=f;
                    maior(2)=i;
                end
                maximum = maximum+f;
            end
%--------------------------------Reprodu��o-------------------------------%
            %Selecionar progenitores pelo m�todo da roleta
            sumrol = 0;               %acumula o valor da soma do �ltimo valor da roleta
            rolpercent = zeros(N,1);  %guarda a base da roleta
            for i = 1:N
               %Gera a base da roleta (espa�os de acordo com o valor de fitness)
               rolpercent(i)=sumrol+fitpeople(i)/maximum;
               sumrol = rolpercent(i);
            end

            nextGen = zeros(N,Cities); %Inicializa a matriz da pr�xima gera��o
            for i = 1:N/2
    %------------------Escolha de dois progenitores------------------%
                %Roleta para o primeiro
                choice1 = rand(1);
                for a = 1:N
                    %Escolhe pelo m�todo da roleta
                    if choice1 <= rolpercent(a)
                        progen(1)=a; %Guarda o �ndice do progenitor 1
                        break;
                    end
                end
                %Roleta para o segundo, garantindo que s�o diferentes
                verif =1;
                while verif == 1
                    choice2 = rand(1);
                    for a = 1:N
                        if choice2 <= rolpercent(a)
                            progen(2)=a; %Guarda o �ndice do progenitor 2
                            if(progen(2)==progen(1))
                                verif = 1;
                            else
                                verif = 0;
                            end
                            break;
                        end
                    end
                end
%--------------------------------Cruzamento-------------------------------%
 %----------------------------M�todo discreto----------------------------%

                if (crossover == 0 && rand(1)<=crossrate)
                    select = randi([0 1],1,Cities); %gera um vetor bin�rio aleat�rio de 1xNumCidades

                    %Mantem as caracteristicas onde 'select' � igual a 1 e zera as demais 
                    son(1,:) = people(progen(2),:).*select;
                    son(2,:) = people(progen(1),:).*select;
                end 
%-----------------M�todo PMX (partially matched crossover )--------------%
                if (crossover == 1 && rand(1)<=crossrate)
                    point1 = randi([1 6],1);      %Primeiro ponto de corte
                    point2 = randi([point1 6],1); %Segundo ponto de corte

                    son = zeros(2,Cities);
                    son(1,point1:point2) = people(progen(2),point1:point2);
                    son(2,point1:point2) = people(progen(1),point1:point2);
                end

%---------------------------------Muta��o---------------------------------%
                if mutacao == 1
                    %Verifica cormossomo a cromossomo se h� ou n�o muta��o
                    for a = 1:Cities
                        verif = 1;
                        %Realiza a muta��o no filho 1
                        if rand(1)<= m %muta com probabilidade m.
                            while(verif)
                                mutation = randi([1 6],1);
                                %Verifica se j� existe o cromossomo no filho
                                if ~ismember(mutation,son(1,:))
                                    son(1,a)= mutation;
                                    verif = 0;
                                    break;
                                %Se o cromossomo de muta��o � igual ao atual
                                elseif mutation==son(1,a) %Evita loop infinito
                                    verif = 0;
                                    break;
                                end
                            end
                        end
                        verif=1;
                        %Realiza a muta��o no filho 2
                        if rand(1)<= m %muta com probabilidade m.
                            while(verif)
                                mutation = randi([1 6],1);
                                if ~ismember(mutation,son(2,:))
                                    son(2,a)= mutation;
                                    verif = 0;
                                    break;
                                %Se o cromossomo de muta��o � igual ao atual
                                elseif mutation==son(2,a) %Evita loop infinito
                                    verif = 0;
                                    break;
                                end
                            end
                        end
                    end
                end
    %----------------------------------------------------------------%


%------------------------Completa  filhos---------------------------------%
                %Completa os cromossomos do filho (sem repeti��es)
                [son(1,:),son(2,:)] = fillson(son(1,:),son(2,:),progen(1),progen(2),people,Cities);
%-----------------------------Pr�xima gera��o-----------------------------%
                %passa os filhos para pr�xima gera��o        
                nextGen(i*2-1,:)=son(1,:);
                nextGen(i*2,:)=son(2,:);
            end
            
%---------------------------------Elitismo--------------------------------%
            if elite == 1
                menor(1) = inf; %Fitness do pior indiv�duo
                menor(2) = 0; %indice do pior indiv�duo
                teste(1) = 0;
                teste(2) = 0;
                %Encontra o pior indiv�duo
                for a = 1:N
                    [f d] = fitness(nextGen(a,:));
                    if(f<menor(1))
                       menor(1)=f;
                       menor(2)=a;
                    end
                end
                %Passa o melhor indiv�duo para a pr�xima gera��o (substitui o pior)
                nextGen(menor(2),:) = people(maior(2),:);
            end
%-------------------------------------------------------------------------%
            %Substituir gera��o antiga
            people = nextGen;
            gen=gen+1;

            converge(gen)= min(distpeople);
            mediana(gen)= mean(distpeople);
            piores(gen) = max(distpeople);
            
%             if(converge(gen) == 130 || gen==genMax)
%                 geracao(amostramc,N) = gen;
%                 break;
%             end
            title('Convergencia');
            hold on;
            asd(1) = plot(piores,'mx:');
            asd(2) = plot(mediana,'b*:');
            asd(3) = plot(converge,'rp:');
            asd(4) = plot(ones(1,genMax)*130,'c-');
            legend(asd,'Piores individuos','Media dos indiv�duos','Melhores indiv�duos','Referencia','Location','Best')
            drawnow
        end    
%     end
% end

% gerplot = mean(geracao(:,10:2:20));
% plot(10:2:20,gerplot);
% xlabel('Tamanho da Popula��o');
% ylabel('Gera��o de Converg�ncia');

% %For�a Bruta
% cont=0;
% x = perms([1 2 3 4 5 6]);
% [y d] = fitness(x(1,:));
% for i= 1:length(x(:,1))
%    [y1 d1] = fitness(x(i,:));
%    if(d1<d)
%        d=d1;
%        y = y1;
%    end
%    if(d1 == 130)
%        cont=cont+1;
%        a(cont,:)=x(i,:);
%    end
% end