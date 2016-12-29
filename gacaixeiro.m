%****Algorítimo Genético para solução do problema do caixeiro viajante****%

%Limpar cache
close all;
clear all;
clc;

%################################Parametros###############################%

N = 20;         %População
Cities = 6;      %Número de cidades
m = 0.01;        %Taxa de mutação
crossrate = 1;   %Taxa de crossover
genMax = 100;    %Limite de gerações
mutacao = 1;     %Mutação -> 1 = com mutação, 0 = sem mutação
elite = 1;       %Elistimo -> 1 = com elitismo, 0 = sem elitismo
crossover = 0;   %Método de crossover -> 0 = crossover discreto modificado, 1 = crossover PMX

%#################################Evolução################################%
% for N = 10:2:20 %Tamanho da população
%     for amostramc = 1:500 %amostras de monte carlo
%--------------------------Gerar população inicial------------------------%
        people = zeros(N,Cities);
        for i=1:N
            people(i,:) = randperm(Cities); %Gera individuo
        end
%-------------------------------------------------------------------------%
        gen=0;
        fitpeople = zeros(1,N);  %guarda o valor de fitness de cada indivíduo
        distpeople = zeros(1,N); %guarda a distância real para cada indivíduo
        while(gen<=genMax)
            maior(1) = 0; %valor fitness do melhor indivíduo
            maior(2) = 0; %índice do melhor indivíduo
            maximum=0;    %acumula o valor de fitness de todos os indivíduos
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
%--------------------------------Reprodução-------------------------------%
            %Selecionar progenitores pelo método da roleta
            sumrol = 0;               %acumula o valor da soma do último valor da roleta
            rolpercent = zeros(N,1);  %guarda a base da roleta
            for i = 1:N
               %Gera a base da roleta (espaços de acordo com o valor de fitness)
               rolpercent(i)=sumrol+fitpeople(i)/maximum;
               sumrol = rolpercent(i);
            end

            nextGen = zeros(N,Cities); %Inicializa a matriz da próxima geração
            for i = 1:N/2
    %------------------Escolha de dois progenitores------------------%
                %Roleta para o primeiro
                choice1 = rand(1);
                for a = 1:N
                    %Escolhe pelo método da roleta
                    if choice1 <= rolpercent(a)
                        progen(1)=a; %Guarda o índice do progenitor 1
                        break;
                    end
                end
                %Roleta para o segundo, garantindo que são diferentes
                verif =1;
                while verif == 1
                    choice2 = rand(1);
                    for a = 1:N
                        if choice2 <= rolpercent(a)
                            progen(2)=a; %Guarda o índice do progenitor 2
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
 %----------------------------Método discreto----------------------------%

                if (crossover == 0 && rand(1)<=crossrate)
                    select = randi([0 1],1,Cities); %gera um vetor binário aleatório de 1xNumCidades

                    %Mantem as caracteristicas onde 'select' é igual a 1 e zera as demais 
                    son(1,:) = people(progen(2),:).*select;
                    son(2,:) = people(progen(1),:).*select;
                end 
%-----------------Método PMX (partially matched crossover )--------------%
                if (crossover == 1 && rand(1)<=crossrate)
                    point1 = randi([1 6],1);      %Primeiro ponto de corte
                    point2 = randi([point1 6],1); %Segundo ponto de corte

                    son = zeros(2,Cities);
                    son(1,point1:point2) = people(progen(2),point1:point2);
                    son(2,point1:point2) = people(progen(1),point1:point2);
                end

%---------------------------------Mutação---------------------------------%
                if mutacao == 1
                    %Verifica cormossomo a cromossomo se há ou não mutação
                    for a = 1:Cities
                        verif = 1;
                        %Realiza a mutação no filho 1
                        if rand(1)<= m %muta com probabilidade m.
                            while(verif)
                                mutation = randi([1 6],1);
                                %Verifica se já existe o cromossomo no filho
                                if ~ismember(mutation,son(1,:))
                                    son(1,a)= mutation;
                                    verif = 0;
                                    break;
                                %Se o cromossomo de mutação é igual ao atual
                                elseif mutation==son(1,a) %Evita loop infinito
                                    verif = 0;
                                    break;
                                end
                            end
                        end
                        verif=1;
                        %Realiza a mutação no filho 2
                        if rand(1)<= m %muta com probabilidade m.
                            while(verif)
                                mutation = randi([1 6],1);
                                if ~ismember(mutation,son(2,:))
                                    son(2,a)= mutation;
                                    verif = 0;
                                    break;
                                %Se o cromossomo de mutação é igual ao atual
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
                %Completa os cromossomos do filho (sem repetições)
                [son(1,:),son(2,:)] = fillson(son(1,:),son(2,:),progen(1),progen(2),people,Cities);
%-----------------------------Próxima geração-----------------------------%
                %passa os filhos para próxima geração        
                nextGen(i*2-1,:)=son(1,:);
                nextGen(i*2,:)=son(2,:);
            end
            
%---------------------------------Elitismo--------------------------------%
            if elite == 1
                menor(1) = inf; %Fitness do pior indivíduo
                menor(2) = 0; %indice do pior indivíduo
                teste(1) = 0;
                teste(2) = 0;
                %Encontra o pior indivíduo
                for a = 1:N
                    [f d] = fitness(nextGen(a,:));
                    if(f<menor(1))
                       menor(1)=f;
                       menor(2)=a;
                    end
                end
                %Passa o melhor indivíduo para a próxima geração (substitui o pior)
                nextGen(menor(2),:) = people(maior(2),:);
            end
%-------------------------------------------------------------------------%
            %Substituir geração antiga
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
            legend(asd,'Piores individuos','Media dos indivíduos','Melhores indivíduos','Referencia','Location','Best')
            drawnow
        end    
%     end
% end

% gerplot = mean(geracao(:,10:2:20));
% plot(10:2:20,gerplot);
% xlabel('Tamanho da População');
% ylabel('Geração de Convergência');

% %Força Bruta
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