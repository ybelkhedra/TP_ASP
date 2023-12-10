%description du problème
robot(1..r).
objet(1..o).
zone(1..z).
zone_chargement(z).
etape(1..n).


%règles


1 {estDans(Z, R, 1) : zone(Z)} 1 :- robot(R). %on choisit les positions de departs des robots
1 {contient(O, Z) : zone(Z)} 1 :- objet(O). %chaque objet se trouve initialement dans une et une seule zone
:- contient(O, Z), zone_chargement(Z). %aucun objet est stockée dans la zone de chargement

1 {estDans(Z_next,R,I) : zone(Z_next), Z != Z_next} 1 :- estDans(Z,R,I-1), etape(I). %on fait se deplacer les robots dans des zones differentes a l'etape suivante

{porte(O, R, I)} 1 :- estDans(Z,R,I), contient(O,Z). %un robot peut ramasser un objet qui se trouve dans la zone dans laquelle il se trouve
:- {porte(O,R,I): objet(O)} > 1, robot(R), etape(I). % un robot ne peut porter qu'un objet à la fois a une etape donnée
:- {porte(O, R, I): robot(R), etape(I)} > 1, objet(O). % un objet ne peut etre porté que par un seul robot
1 {estDans(Z, R, I) : zone_chargement(Z)} 1 :- porte(O,R,I-1), etape(I). %un robot qui porte un objet part dans la zone de chargement

estLivre(O, I) :- porte(O,R,I-1), etape(I). %un objet est livré si il est porté par un robot et qu'il reste une étape après

nb_obj_livre(N) :- N = #count{O : estLivre(O, _)}. % le nombre d'objets livrés est le nombre d'objets qui ont été porté avant la dernire etape

#maximize {N@1 : nb_obj_livre(N)}. %on maximise le nombre d'objets livrés

%#show estDans/3. 
%#show contient/2.
%#show porte/3.
#show estLivre/2.