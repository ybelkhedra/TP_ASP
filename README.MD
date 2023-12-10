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