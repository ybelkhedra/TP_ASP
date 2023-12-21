# TP logistique Yamine Belkhedra

## Démarche pour une modélisation simplifiée

Dans un premier temps, j'ai cherché à définir les variables du problème, que j'ai identifiées comme étant les robots, les objets, les zones d'entrepôt et la zone de chargement.

```
robot(1..r).
objet(1..o).
zone(1..z).
zone_chargement(z).
etape(1..n).
```

Ensuite, j'ai réalisé un modèle simple qui permet seulement de déplacer les robots.

```
%estDans(ZONE, ROBOT, ETAPE) = Le robot ROBOT est dans la zone ZONE à l'étape ETAPE
1 {estDans(Z, R, 1) : zone(Z)} 1 :- robot(R). %on choisit les positions de départ des robots
1 {estDans(Z_next,R,I) : zone(Z_next), Z != Z_next} 1 :- estDans(Z,R,I-1), etape(I). %on fait se déplacer les robots dans des zones différentes à l'étape suivante
```

Ensuite, je rajoute le fait que chaque objet commence dans une zone :

```
1 {contient(O, Z) : zone(Z)} 1 :- objet(O). %chaque objet se trouve initialement dans une et une seule zone
:- contient(O, Z), zone_chargement(Z). %aucun objet n'est stocké dans la zone de chargement
```

Je fais en sorte que les robots puissent porter des objets et les ramener dans la zone de chargement, en faisant attention qu'un robot ne puisse porter qu'un objet à la fois au maximum à une étape donnée, et qu'un objet ne peut être porté au maximum qu'une seule fois en tout.

```
{porte(O, R, I)} 1 :- estDans(Z, R, I), contient(O, Z). %un robot peut ramasser un objet qui se trouve dans la zone dans laquelle il se trouve
:- {porte(O, R, I) : objet(O)} > 1, robot(R), etape(I). %un robot ne peut porter qu'un objet à la fois à une étape donnée
:- {porte(O, R, I) : robot(R), etape(I)} > 1, objet(O). %un objet ne peut être porté que par un seul robot
1 {estDans(Z, R, I) : zone_chargement(Z)} 1 :- porte(O, R, I-1), robot(R), objet(O), etape(I). %un robot qui porte un objet part dans la zone de chargement
```

On peut ensuite compter le nombre d'objets livrés et essayer de maximiser ce nombre :

```
nb_obj_livre(N) :- N = #count{O : porte(O, R, I-1), etape(I)}. %le nombre d'objets livrés est le nombre d'objets qui ont été portés avant la dernière étape

#maximize {N@1 : nb_obj_livre(N)}. %on maximise le nombre d'objets livrés
```

Ainsi, dans ma première modélisation, chaque mouvement de robot d'une zone à une autre constitue une étape, le fait de charger et de décharger un objet est une action instantanée.

## Résultats de la première modélisation

On peut lancer une exécution de mon code de la manière suivante :

```bash
clingo logistique_V1.lp -c r=5 -c o=10 -c z=5 -c n=5 -V0
```

avec r le nombre de robots, o le nombre d'objets, z le nombre de zones et n le nombre d'étapes. En sachant que la dernière zone est forcément la zone de chargement et qu'aucun objet n'y est stocké initialement.

Cette modélisation est très simplifiée car le nombre de zones de départ n'a aucune influence pour l'instant. En effet, le temps de trajet entre les zones est toujours égal à une étape. Ainsi, l'optimum est connu d'avance, le modèle se contente de trouver une solution où chaque robot livre un objet toutes les deux étapes. Le programme assigne un à chaque robot des objets qu'il devra livrer distincts de ses pairs.

## Deuxième modélisation

Pour une deuxième modélisation, je rajoute des temps de trajet entre les zones et la zone de chargement, qui sont différents les uns des autres. De plus, la société de livraison propose un abonnement payant qui permet de prioriser sa commande. Ainsi, les commandes se voient maintenant attribuer des points de priorité, qui peuvent représenter le fait d'avoir un abonnement ou non, ou si la commande a été faite il y a longtemps. Ainsi, on va cette fois chercher à accumuler le plus de points de priorité en un temps imparti. À priorité de livraison égale, l'entreprise va tout de même chercher à maximiser son nombre de livraisons. Le nombre d'objet, le nombre de zone, la position des objets, la distance entre les zones est cette fois fixé. La deuxième modélisation peut être lancé avec la commande suivante :
```bash
clingo logistique_V2.lp -c n=100 -c r=5 -V0
```

Le paramètre n représente le temps totale dont dispose les r robot(s). Si vous souhaitez modifier les autres paramètres, c'est possible en modifiant directement le fichier "logistique_V2.lp". Des commentaires y sont présents pour expliquer les changements par rapport à la V1.


## Résultats deuxième modélisation

La deuxième modélisation a été initialisé de la manière suivante : 

    - Le nombre de robot est définit par l'utilisateur ;
    - Il y a 10 objets ;
    - Il y a 6 zones de chargement, la zone 6 correspond à la zone de chargement ;
    - L'emplacement des objets est : 
        - L'objet 1 se trouve dans la zone 5 ;
        - L'objet 2 se trouve dans la zone 2 ;
        - L'objet 3 se trouve dans la zone 3 ;
        - L'objet 4 se trouve dans la zone 4 ;
        - L'objet 5 se trouve dans la zone 5 ;
        - L'objet 6 se trouve dans la zone 4 ;
        - L'objet 7 se trouve dans la zone 3 ;
        - L'objet 8 se trouve dans la zone 3 ;
        - L'objet 9 se trouve dans la zone 2 ;
        - L'objet 10 se trouve dans la zone 5 ;
    - Les priorités des livraisons sont :
        - L'objet 1 doit être livré avec une priorité de 1 ;
        - L'objet 2 doit être livré avec une priorité de 1 ;
        - L'objet 3 doit être livré avec une priorité de 1 ;
        - L'objet 4 doit être livré avec une priorité de 5 ;
        - L'objet 5 doit être livré avec une priorité de 5 ;
        - L'objet 6 doit être livré avec une priorité de 5 ;
        - L'objet 7 doit être livré avec une priorité de 10 ;
        - L'objet 8 doit être livré avec une priorité de 10 ;
        - L'objet 9 doit être livré avec une priorité de 10 ;
        - L'objet 10 doit être livré avec une priorité de 20 ;
    -Les distances entre les zones et la zone de chargement sont :
        - La distance entre la zone 1 et 6 et 5 ;
        - La distance entre la zone 2 et 6 et 5 ;
        - La distance entre la zone 3 et 6 et 10 ;
        - La distance entre la zone 4 et 6 et 20 ;
        - La distance entre la zone 5 et 6 et 50 ;
    
Par cette initialisation, j'ai essayé de rendre la recherche de solution intéressante en faisant en sorte que le modèle doive trouver un compromis entre objets dont la priorité de livraisons est elevé mais qui se trouve loin de la zone ed chargement.

L'exécution du problème avec 5 robots et 100 pas de temps donne :

```
estLivreOTR(2,61,2) estLivreOTR(7,31,4) estLivreOTR(9,71,2) estLivreOTR(6,81,4) estLivreOTR(8,81,5) estLivreOTR(3,91,2) estLivreOTR(4,91,4) estLivreOTR(5,51,1) estLivreOTR(10,51,2) estLivreOTR(1,51,5) satisfacion_tot(78) nb_obj_livre(10)
Optimization: -78 -10
OPTIMUM FOUND`
```

Ainsi, la satisfaction totale est de 78 et les 10 objets ont été livrés.
On y lit que :
    - L'objet 1 a été livré au pas de temps 51 par le robot 5 ;
    - L'objet 2 a été livré au pas de temps 61 par le robot 2 ;
    - L'objet 3 a été livré au pas de temps 91 par le robot 2 ;
    - L'objet 4 a été livré au pas de temps 91 par le robot 4 ;
    - L'objet 5 a été livré au pas de temps 51 par le robot 1 ;
    - L'objet 6 a été livré au pas de temps 81 par le robot 4 ;
    - L'objet 7 a été livré au pas de temps 31 par le robot 4 ;
    - L'objet 8 a été livré au pas de temps 81 par le robot 5 ;
    - L'objet 9 a été livré au pas de temps 71 par le robot 2 ;
    - L'objet 10 a été livré au pas de temps 51 par le robot 2 ;

On est rassuré de constater que les robots ont livrés leurs objets à des temps différents. De plus, tous les robots ont été utilisé.

Expérimentalement, j'ai trouvé qu'il fallait au moins 51 pas de temps pour tous livrer avec 5 robots. On obtient la sortie suivante : 

```
estLivreOTR(2,11,4) estLivreOTR(8,31,3) estLivreOTR(3,51,3) estLivreOTR(9,51,4) estLivreOTR(6,51,4) estLivreOTR(4,41,4) estLivreOTR(7,11,3) estLivreOTR(1,51,1) estLivreOTR(5,51,2) estLivreOTR(10,51,5) satisfacion_tot(78) nb_obj_livre(10)
Optimization: -78 -10
OPTIMUM FOUND
```
qui signifie que :
    - L'objet 1 a été livré au pas de temps 51 par le robot 5 ;
    - L'objet 2 a été livré au pas de temps 11 par le robot 4 ;
    - L'objet 3 a été livré au pas de temps 51 par le robot 3 ;
    - L'objet 4 a été livré au pas de temps 91 par le robot 4 ;
    - L'objet 5 a été livré au pas de temps 51 par le robot 1 ;
    - L'objet 6 a été livré au pas de temps 51 par le robot 4 ;
    - L'objet 7 a été livré au pas de temps 31 par le robot 4 ;
    - L'objet 8 a été livré au pas de temps 31 par le robot 3 ;
    - L'objet 9 a été livré au pas de temps 51 par le robot 4 ;
    - L'objet 10 a été livré au pas de temps 51 par le robot 2 ;