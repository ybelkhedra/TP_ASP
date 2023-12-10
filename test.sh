echo "En mettant r=1, o=5, z=2 et n=3, on doit obtenir qu'un seul objet livré. En effet, le premier objet sera livré à l'étape 2, puis il faut au moins deux autres étapes pour y revenir."
clingo logistique_V1.lp -c r=1 -c o=5 -c z=2 -c n=3 -V0 | tail -n 3 | head -n 2

echo "En rajoutant seulement une étape, on est censé pouvoir avoir deux objets livrés."
clingo logistique_V1.lp -c r=1 -c o=5 -c z=2 -c n=4 -V0 | tail -n 3 | head -n 2


echo "Supposons 2 robots et 10 objets, et qu'ils doivent livrer le maximum d'objets en 10 étapes. On devrait avoir 10 objets livrés car chacun d'eux peuvent alors livrer 5 objets."
clingo logistique_V1.lp -c r=2 -c o=10 -c z=5 -c n=10 -V0 | tail -n 3 | head -n 2