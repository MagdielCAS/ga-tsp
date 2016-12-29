%Função que retorna a distancia total percorrida para passar por 6 cidades
%sem repetição 'd' e o valor de fitness 'f'. Recebe como entrada um vetor 
%'x' com a ordem de visita às cidades.
function [f, d]  = fitness( x )
    %Distancia das cidades
    dist = [0 100 35 90 30 25;
            100 0 25 65 90 45;
            35 25 0 15 80 40;
            90 65 15 0 50 35;
            30 90 80 50 0 38;
            25 45 40 35 38 0;];
    y = 0;
    for i = 1 : 5
        %Acumula a distancia entre as cidades adjacentes
        y = y + dist(x(i),x(i+1)); 
    end
    d = y;
    f = 1/y;
end