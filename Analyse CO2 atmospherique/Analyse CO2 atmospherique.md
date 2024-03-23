#  Science des données du changement climatique: étude du CO2 atmosphérique

Ce TP porte sur l'évolution du dioxyde de carbone (CO2) atmosphérique. Ce TP utilise des données historiques à long terme, comparé au précédent. 

Nous allons travailler avec des données historiques et publiques de CO2 atmosphérique. Je remercie Pierre Poulain (Université Paris-Cité) pour l'idée et les sources afin de monter ce TP.

## Unité de mesure

Lors de la mesure des gaz, le terme *concentration* est utilisé pour décrire la quantité de gaz par volume dans l'air. Les deux unités de mesure les plus courantes sont les parties par million (ppm) et la concentration en pourcentage. Toutes nos données utilisent les parties par million comme unité de mesure.
Les parties par million (abrégées ppm) représentent le [rapport](https://www.co2meter.com/fr-fr/blogs/news/15164297-co2-gas-concentration-defined) d'un gaz par rapport à un autre. Par exemple, 1 000 ppm de CO2 signifie que si vous pouviez compter un million de molécules de gaz, 1 000 d'entre elles seraient du dioxyde de carbone et 999 000 molécules seraient d'autres gaz.

## Chargment des librairies



```
import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path
from urllib.request import urlretrieve
import urllib.parse
from scipy import stats
import numpy as np
```

## Les données atmosphériques récentes

#### Introduction

Nous allons nous intéresser aux données sur le dioxyde de carbone (CO2) atmosphérique recueillies au Mauna Loa Observatory. Elles fournissent l'un des ensembles de données les plus emblématiques et précieux pour surveiller les changements dans la composition atmosphérique. Situé sur l'île d'Hawaï, le Mauna Loa Observatory est perché à une altitude élevée, à environ 3 400 mètres au-dessus du niveau de la mer. Les mesures de CO2 ont débuté en 1958 sous la direction du Dr Charles David Keeling, et c'est le célèbre "Keeling Curve" qui en résulte, une courbe montrant l'augmentation régulière des concentrations de CO2 au fil du temps. Les données sont collectées en prélevant des échantillons d'air à diverses altitudes pour minimiser les influences locales et en analysant ces échantillons par spectroscopie infrarouge.

L'histoire de l'ensemble de données du Mauna Loa est essentielle pour comprendre le changement climatique. Les mesures de Keeling ont d'abord confirmé la tendance à la hausse à long terme des concentrations de CO2, soulignant le rôle humain dans l'augmentation des émissions de gaz à effet de serre. Les données de Mauna Loa sont régulièrement mises à jour et continuent d'être une référence cruciale pour évaluer l'efficacité des politiques de réduction des émissions et comprendre l'ampleur du défi du changement climatique.

Les méthodes de mesure de Keeling au Mauna Loa ont été tellement influentes qu'elles ont conduit à la création du [Programme d'observation de l'atmosphère](https://gml.noaa.gov/) de la NOAA (National Oceanic and Atmospheric Administration) en 1974, qui étend le réseau mondial de surveillance des gaz à effet de serre. Ainsi, le Mauna Loa Observatory et son ensemble de données historiques continuent d'être un pilier dans l'étude des changements climatiques et de sensibilisation mondiale.

Aujourd'hui, la zone de recherche de ce programme a été étendue et il mesure la distribution atmosphérique et les tendances des trois principaux moteurs à long terme du changement climatique, le dioxyde de carbone (CO2), le méthane (CH4) et le protoxyde d'azote (N2O), ainsi que le monoxyde de carbone (CO), qui est un indicateur important de la pollution de l'air.

#### Analyse de données

**Question**: D'après le cours et selon vous, en quoi est-ce important de surveiller l'évolution du CO2 atmosphérique?     
Pour faciliter la correction, rédigez vos réponses en vert à l'aide du conteneur HTML `span style="color:green` utilisé comme dans la cellule ci-dessous.

<span style="color:green">
    
VOTRE REPONSE ICI:
- Il est important de mesurer le Co2 atmopspherique car c'est un gaz a effet de serre qui augmente le forcage radiatif. Ainsi, avec sa mesure on estimer l'augmentation du forcage radiatif et donc le rechauffement climatique actuel et a venir.

Le jeu de données est stocké sous format texte sur le site du [GML](https://gml.noaa.gov/dv/site/?program=ccgg&active=1). Il utilise des espaces comme séparateur et comporte 20 colonnes pour 593 lignes. Il contient un code de site, qui fait référence à l'observatoire où les données ont été enregistrées, la date, de l'année jusqu'à la seconde près, l'enregistrement du CO2 et d'autres attributs des mesures.

Ci-dessous voici comment télécharger les données (l'observatoire est codé par les 3 lettres mlo):



```
filename = f"co2_mlo_surface-insitu_1_ccgg_MonthlyData.txt"
url = f"https://gml.noaa.gov/aftp/data/trace_gases/co2/in-situ/surface/txt/{filename}"
if not Path(filename).is_file():
   urlretrieve(url, filename)
```

1. Chargez le jeu de données dans la table `df_mlo`. Filtrez les données et conservez uniquement les colonnes suivantes: *year*, *month*, *datetime*, *time_decimal*, *value*.




```
columns = ['year', 'month', 'datetime', 'time_decimal', 'value']

df_mlo = pd.read_csv(filename, sep=' ', comment='#', usecols=columns)
# display(df_mlo)
```

2. Comment sont indiquées les valeurs manquantes ? Ouvrez le fichier avec un lecteur de fichier texte et lisez les commentaires. Y a t il des données manquantes dans le jeu de données ? Indiquez les avec des `NA`. Quelles sont les valeurs minimales et maximales du jeu de données ?



```
df_mlo = pd.read_csv(filename, sep=' ', comment='#', usecols= columns , na_values=-999.99)
display(df_mlo)
```


```
df_mlo.describe()
```

<span style="color:green">
    
Votre réponse ici: 
- Les valeur manquantes sont indiqués par le nombre -999.99 (meme si dans la description il y a marqué que les valeurs manquantes doivent etre indiquées par -999.999 )
- Oui il y a des données manquantes, car on voit que dans les premiere lignes de la colonne value on a des -999.99
- Remplacement des -999.99 par des NaN 
- La valeur minimale de la colonne value est 327.3 et la valeur maximale est 420.97
3. Pour lisser les enregistrements de CO2, calculez par la méthode des fenetres glissantes (de 11 valeurs centrées et un pas de 1) le CO2 moyen de chaque mois. Ajoutez une colonne `value_rollmean` contenant cette information.

*Explications:* Ce nombre 11 a été choisi pour recentrer la valeur moyenne sur l'ensemble de l'année, éliminant ainsi la variabilité saisonnière. À n'importe quel moment, le CO2 enregistré est ajusté par les valeurs du cycle saisonnier le plus proche, comprenant ainsi quatre saisons.



```
df_mlo['value_rollmean'] = df_mlo['value'].rolling(window=11, min_periods=1, center=True).mean()
```

4. Décrivez maintenant votre jeu de données:



```
df_mlo.describe()
```


```
# il reste 4 NaN dans value_rollmean
df_mlo.head(5)
```

<span style="color:green">
Votre réponse ici

5. Faites une représentation graphique des enregistrements de CO2 de 1973 jusqu'à maintenant, a-t-on bien lissé les données avec les fenetres glissantes ?
- Oui, les données sont bien lissés mais il reste 4 NaN au debut value_rollmean, on va par la suite les retirer pour les effectuer l'apprentissage machine



```
#votre code ici
plt.plot(df_mlo['time_decimal'], df_mlo['value'], label= 'CO2 mesuré')
plt.plot(df_mlo['time_decimal'], df_mlo['value_rollmean'], label= 'Moyenne mobile sur 11 mois du CO2 mesuré')

plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.legend()
plt.show()
```

<span style="color:green">
Votre réponse ici

6. Faites maintenant des prédictions jusqu'en 2050. Quel(s) type(s) de regressions avez vous choisi et pourquoi ? Représentez vos résultats sur une figure. Discutez des valeurs de CO2 qu'on s'attend à atteindre en 2050 et des limites de vos prédictions.




```
# ON retire les lignes avec des NaN dans la colonne value_rollmean(dans df_mlo il y en a 4)
df_mlo = df_mlo.dropna(axis=0, subset=['value_rollmean'])

# df_mlo = df_mlo.dropna(axis=0)
display(df_mlo)
```


```
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline

X = df_mlo[['time_decimal']].values
y = df_mlo['value_rollmean']

modele = make_pipeline(PolynomialFeatures(2), LinearRegression())
modele.fit(X, y) 

annees_futures = np.array(range(2023, 2050)).reshape(-1, 1)
predictions = modele.predict(annees_futures)
```


```
plt.plot(df_mlo['time_decimal'], df_mlo['value_rollmean'], label= 'Moyenne mobile sur 11 mois du CO2 mesuré')
plt.plot(annees_futures, predictions, label= 'Prediction 2023-2050')

plt.legend()
plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.show()
```

<span style="color:green">
    
Votre réponse ici :
- j'ai choisi une regression polynomiale pour mieux coller a nos donner qu'une regression lineaire.
- Notre prediction nous indique qu'on s'aprocherait en 2050 d'une concentration en CO2 proche de 500 ppm.
- La limite de notre prediction est qu'elle se base sur les données passées et ne prends donc pas en compte les changements qui pourraient etre mis en place pour reduire nos emissions aujourd'hui et a l'avenir. (ou les changements qui pourraient les augmenter ...)

## Les données de paléoclimatologie : estimation du CO2 historique

#### Introduction

Les données paléoclimatiques sur les concentrations passées de dioxyde de carbone (CO2), offrent une perspective historique sur les variations naturelles des niveaux de CO2 sur de vastes échelles de temps. La méthode la plus directe pour étudier les variations passées de la concentration atmosphérique de CO2 avant les mesures continues de CO2 atmosphérique, consiste à analyser l'air extrait de carottes de glace appropriées ([Siegenthaler et al., 2005](https://doi.org/10.1594/PANGAEA.728135)).

La mesure de la composition gazeuse est directe : emprisonnées dans les carottes de glace profondes se trouvent de minuscules bulles d'air ancien que nous pouvons extraire et analyser à l'aide de spectromètres de masse (https://www.scientificamerican.com/article/how-are-past-temperatures/).

En examinant les données paléoclimatiques en parallèle avec les mesures contemporaines, nous allons évaluer l'impact des activités humaines sur l'augmentation récente des concentrations de CO2. 

#### Des années 1000 à 2004

En 2010, les données sur le CO2 préindustriel ont été estimées à l'aide de deux carottes de glace. Les mesures pour Law Dome (LD) et Dronning Maud Land (DML) étaient suffisantes pour obtenir des estimations lissées, avec des splines sur 50 ans, de l'évolution du CO2 entre 1000 et 2004 ([Frank et al., 2010](https://pubmed.ncbi.nlm.nih.gov/20110999/)).

Ces données sont disponibles dans la base de données de paléoclimatologie de la NOAA, sous l'étude [10437](https://www.ncei.noaa.gov/access/paleo-search/study/10437).

Le jeu de données est également stocké sous un format texte, utilisant des tabulations comme séparateurs, et comprend 23 colonnes pour 1005 lignes. Il contient l'année d'enregistrement, de 1000 à 2004, et trois valeurs principales : l'enregistrement à Law Dome (LD), l'enregistrement à Dronning Maud Land (DML) et l'enregistrement moyen sur ces deux sites. Chacune de ces valeurs est lissée à l'aide de splines sur une plage de 50 à 200 ans, avec un intervalle de 25 ans.

1. Le fichier du jeu de données se situe [ici](https://www.ncei.noaa.gov/pub/data/paleo/contributions_by_author/frank2010/smoothedco2.txt).
Chargez le dans une table nommée `df_indus`



```
file_indus = 'smoothedco2.txt'
df_indus = pd.read_csv(file_indus, sep='\t')
# display(df_indus)
```

En regardant le tableau, on choisit d'étudier `ALL_50_full` qui est la moyenne entre les sites LD et DML lissées sur une plage de 50 ans. Elle ne contient pas de valeurs manquantes car les données ont été traitées par les auteurs de l'étude.

2. Sélectionnez les colonnes d'interet et décrivez votre jeu de données.



```
df_ALL_50_full = df_indus[['Year', 'ALL_50_full'] ]
df_ALL_50_full.describe()
```


```
plt.plot(df_ALL_50_full['Year'], df_ALL_50_full['ALL_50_full'], label='Moyenne mobile lissées sur 50 ans entre les sites LD et DML')
plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.legend()
plt.show()
```

<span style="color:green">
    
Votre réponse ici:
- On constate une concentration assez stable en co2 entre les annees 1000 a 1750, puis hausses vertigineuse des concentration en co2 amorcée autour des annees 1800 jusqu'a 2004 (fin du graphe).

3. Ces valeurs vont jusqu'en 2004, et les valeurs moyennes ont enregistrées à Mauna Loa depuis 1974.
Les concentrations en CO2 entre 1974 et 2004 corrèlent elles entre les deux jeux de données ? Expliquez quelles colonnes de vos jeux de données vous avez décider de comparer.



```
df_mlo.rename(columns={'year': 'Year'}, inplace=True)

df_corr = pd.merge(df_mlo[['Year', 'value_rollmean']], df_indus[['Year', 'ALL_50_full']], on='Year', how='inner' )

correlation = df_corr[['value_rollmean', 'ALL_50_full']].corr()
display(correlation)
```


```
fig, ax1 = plt.subplots()

ax1.plot(df_corr['Year'], df_corr['ALL_50_full'], label='Moyenne lissées sur 50 ans entre les sites LD et DML')
ax1.set_xlabel('Annee')
ax1.set_ylabel('Concentration en CO2 ( en ppm )')
ax1.tick_params(axis='y', labelcolor='blue')

ax2 = ax1.twinx()
ax2.plot(df_corr['Year'], df_corr['value_rollmean'], label='Moyenne lissées sur 11 mois (Mauna Loa)', color='red')
ax2.tick_params(axis='y', labelcolor='red')
fig.legend(loc="upper left")

plt.show()
```

<span style="color:green">
    
Votre réponse ici:
- ALL_50_full est une moyenne de la concentration en co2 des 2 sites lissee sur 50ans, donc j'ai choisi de prendre value_rollmean qui est egalement une moyenne lissee (sur 11 mois), pour le site de Mauna Loa.
- En prennant ces deux colonnes sur la periode 1974-2004, on obtiens une correlation de 0.998302, en superposant les courbes fournies par la colonne ALL_50_full et value_rollmean sur la meme periode on voit bien qu'elle se superposent presque parfaitement, d'ou une telle correlation.

4. Créez une table `df_indus_new` qui conserve les valeurs des carottes glaciaires de 1000 à 1974 et utilisent ensuite les valeurs de Mauna Loa de 1974 jusqu'à maintenant.



```
# votre code ici
df_indus_before_1974 = df_indus[df_indus['Year'] <= 1974]
df_mlo_after_1974 = df_mlo[df_mlo['Year'] >= 1974 ]

df_indus_new = pd.concat([df_indus_before_1974, df_mlo_after_1974], ignore_index=True)

# display(df_indus_new)
```

5. Faites une figure qui représente les enregistrements de CO2 atmosphérique de l'an 1000 jusqu'à aujourd'hui. Comparez les dynamiques ou du moins l'étendue des valeurs avant versus après 1800 (date approximative de la révolution industrielle).



```
#votre code ici

# ancienne concentration obtenue a partir de la carrote glaciere
plt.plot(df_indus_new['Year'], df_indus_new['ALL_50_full'], label='Concentrations de CO2 paleoclimatiques (carrotes glaciere)', color='blue')

# concentration a partir de 1974 de Mauna Loa
plt.plot(df_mlo['Year'], df_mlo['value_rollmean'], label='Concentrations en CO2 (Mauna Loa)', color='red')

# droite indiquant l'annee 1800
plt.axvline(x=1800, color='grey', linestyle='--', label='revolution industrielle en 1800')

plt.title('Concentrations de CO2 amtospherique de 1000 a aujourd’hui')
plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.legend()

plt.show()
```


```
plage_pre_1800 = df_indus_new[df_indus_new['Year'] < 1800]
plage_pre_1800.describe()
```


```
plage_post_1800 = df_indus_new[df_indus_new['Year'] >= 1800]
plage_post_1800.describe()
```

<span style="color:green">
    
Votre réponse ici: 
En prenant en compte la colonne ALL_50_full puis value_rollmean pour la periode de 1974 a maintenant on a :
- pendant la periode pre 1800 on avait des concentration en co2 allant de 275.45 a 282.63 ppm
- pendant ala periode post 1800, on a des concentration de 280.98 a 418.52 ppm pour df_indus_new
#### Les données encore (!) plus anciennes

En 2008, les carottes de glace de l'Antarctique Vostok et EPICA Dome C ont fourni un enregistrement composite des niveaux de CO2 atmosphérique au cours des 800 000 dernières années ([Lüthi et al., 2008](https://pubmed.ncbi.nlm.nih.gov/18480821/)).

Le jeu de données est une fois de plus stocké dans un format texte. Il utilise également des tabulations comme séparateurs et comprend 2 colonnes pour 1096 lignes. Il contient l'année avant le présent, ce qui signifie [avant 1950](https://www.artobatours.com/articles/archaeology/bp-bc-bce-ad-ce-cal-mean/), et les enregistrements de CO2. Cela signifie que, par exemple, la première année étant 137 BP correspond en réalité à l'année 1813.

1. Le jeu de données est à cette [adresse](https://www.ncei.noaa.gov/pub/data/paleo/icecore/antarctica/epica_domec/edc3-composite-co2-2008-noaa.txt)
Chargez le jeu de données dans la table `df_icecore` et modifiez l'année  afin que le tracé puisse être affiché correctement et comparé aux autres jeux de données



```
file_icecore = 'edc3-composite-co2-2008-noaa.txt'
df_icecore = pd.read_csv(file_icecore, sep='\t', comment='#')

df_icecore['gas_ageBP'] = 1950 - df_icecore['gas_ageBP']
df_icecore.rename(columns={'gas_ageBP': 'Annee'}, inplace=True)
df_icecore.rename(columns={'CO2': 'Concentration en CO2'}, inplace=True)

# display(df_icecore)
```

2. Visualisez les trois jeux de données sur une même figure (avec les années en axe des x et la concentration de CO2 en y). 



```
plt.figure(figsize=(20,10))
plt.plot(df_mlo['time_decimal'], df_mlo['value_rollmean'], label='Concentrations en CO2 (Mauna Loa)', color='green')
plt.plot(df_indus['Year'], df_indus['ALL_50_full'], label='Concentrations de CO2 paleoclimatiques (carrotes glaciere)', color='red')
plt.plot(df_icecore['Annee'], df_icecore['Concentration en CO2'], label='Concentrations en CO2 a partir de la carotte EPICA Dome C', color='blue')

plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.title('Concentrations de CO2 mesurees sur nos 3 sites')
plt.legend()

plt.show()
```

3. Zoomez sur la période entre 1000 et 2023 où plusieurs jeux de donénes se superposent.



```
plt.figure(figsize=(20,10))

plt.plot(df_mlo['time_decimal'], df_mlo['value_rollmean'], label='Concentrations en CO2 (Mauna Loa)', color='green')
plt.plot(df_indus['Year'], df_indus['ALL_50_full'], label='Concentrations de CO2 paleoclimatiques (carrotes glaciere)', color='red')
plt.plot(df_icecore['Annee'], df_icecore['Concentration en CO2'], label='Concentrations en CO2 a partir de la carotte EPICA Dome C', color='blue')

plt.xlim(1000, 2023)
plt.xlabel('Annee')
plt.ylabel('Concentration en CO2 ( en ppm )')
plt.title('Comparaison des concentrations de CO2 mesurees sur nos 3 sites sur la periodes 1000-2023')
plt.legend()

plt.show()
```

## Conclusion

Indiquez ci-dessous les conclusions que vous estimez pertinentes. Pour vous aider voici une liste (non exhaustive) de questions:

- Les données récentes sont-elles compatibles avec l'analyse de températures du TP1
- Les différentes méthodes concordent-elles ?
- Y a t il une période durant laquelle la concentration en CO2 est particulièrement plus élevée ? Est-ce qu'il existe une corrélation (pas forcément une causalité) avec les activités humaines ? Pourriez vous proposer une hypothèse d'interprétation ?
- Avez-vous des suggestions pour faire d'autres analyses complémentaires ?

<span style="color:green">
    
Votre réponse ici:
- Ces donnees d'augmentation des concentrations du co2 sont coherentes avec les augmentation de temperatures que nous avons trouvé au precedent tp.
- Depuis 1750-1800, on constate une explosion des concentration de co2, soit a partir de la revolution industriel il y a donc une correlation evidente.
Ceci dit correlation n'implique pas causalite, mais en regardant d'autres facteurs comme la consommation/combustion d'ernergie fossiles par l'etre humain sur la meme periode on se rends compte que l'activite humaine par l'usage de ces energie fossibles a signification augmenter les emission de co2. A cela si on ajoute la deforestation, on se rends compte qu'il existe aussi un certain rapport de causalite entre les activites humaines et l'augmentation de co2 atmospherique. 
