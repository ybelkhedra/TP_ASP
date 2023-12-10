%description du problème
robot(1..r).
objet(1..10).
zone(1..6).
zone_chargement(6).
temps(1..n). %on considère cette fois un temps, les robots disposent de n minutes pour livrer les objets

%On définit les distances par rapport à la zone de chargement seulement
distance(1,6,5).
distance(2,6,5).
distance(3,6,10).
distance(4,6,20).
distance(5,6,50).
% distance(1,6,5).
% distance(2,6,5).
% distance(3,6,5).
% distance(4,6,5).
% distance(5,6,5).
distance(X,Y,T) :- X != Y, distance(Y,X,T). %on considère que les temps de parcours sont symétriques

%on définit les priorités des zones  de chargement
priorite(1,1).
priorite(2,1).
priorite(3,1).
priorite(4,5).
priorite(5,5).
priorite(6,5).
priorite(7,10).
priorite(8,10).
priorite(9,20).
priorite(10,20).


%on définit l'emplacement initial des objets
contient(1,5).
contient(2,2).
contient(3,3).
contient(4,4).
contient(5,5).
contient(6,4).
contient(7,3).
contient(8,3).
contient(9,2).
contient(10,5).

%règles

1 {estDans(Z, R, 1) : zone(Z)} 1 :- robot(R). %on choisit les positions de departs des robots

{estDans(Z_next,R,I) : zone_chargement(Z_next), Z != Z_next} 1 :- distance(Z, Z_next, T), temps(I), estDans(Z,R,I-T). %on fait se deplacer un robort vers la zone de chargement
{estDans(Z_next,R,I) : zone(Z_next), Z != Z_next} 1 :- distance(Z, Z_next, T), temps(I), estDans(Z,R,I-T), zone_chargement(Z). %on fait se deplacer les robots depuis la zone de chargement vers les autres zones
:- estDans(Z1,R,I), estDans(Z2,R,I), Z1 != Z2. %un robot ne peut pas etre dans deux zones differentes a la meme etape

{porte(O, R, I)} 1 :- estDans(Z,R,I), contient(O,Z). %un robot peut ramasser un objet qui se trouve dans la zone dans laquelle il se trouve
:- {porte(O,R,I): objet(O)} > 1, robot(R), temps(I). % un robot ne peut porter qu'un objet à la fois a un temps donné
:- {porte(O, R, I): robot(R), temps(I)} > 1, objet(O). % un objet ne peut etre porté que par un seul robot
1 {estDans(Z, R, I) : zone_chargement(Z)} 1 :- temps(I), estDans(Z_, R, I-T), distance(Z_, Z, T), porte(O,R,I-T). %un robot qui porte un objet part dans la zone de chargement s'il lui reste du temps

estLivre(O, I) :- temps(I), estDans(Z_, R, I-T), distance(Z_, Z, T), porte(O,R,I-T). %un objet est livré si il est porté par un robot et qu'il lui reste le temps d'aller vers la zone de chargement

nb_obj_livre(N) :- N = #count{O : estLivre(O, _)}. % le nombre d'objets livrés est le nombre d'objets qui ont été porté avant la dernire etape
satisfacion_tot(S) :- S = #sum{P,O : priorite(O,P), estLivre(O, _)}. %la satisfaction totale est la somme des priorités des objets livrés

#maximize {N@1 : nb_obj_livre(N)}. %on maximise le nombre d'objets livrés
#maximize {S@2 : satisfacion_tot(S)}. %on maximise la satisfaction totale en priorité

% #show distance/3.
% #show estDans/3.
% #show contient/2.
% #show porte/3.
#show estLivre/2.
#show nb_obj_livre/1.
#show satisfacion_tot/1.