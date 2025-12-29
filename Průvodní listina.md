# Zadání projektu

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. 

Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit **robustní datové podklady**, ve kterých bude možné vidět **porovnání dostupnosti potravin** na základě průměrných příjmů za určité časové období.
Jako dodatečný materiál připravte i **tabulku s HDP, GINI koeficientem a populací dalších evropských států** ve stejném období, jako primární přehled pro ČR. 

*Moje poznámka: Porovnání s dalšími evropskými státy není předmětem žádné výzkumné otázky*.


## Datové sady, které je možné požít pro získání vhodného datového podkladu


### Primární tabulky

1. *czechia_payroll* – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
2. *czechia_payroll_calculation* – Číselník kalkulací v tabulce mezd.
3. *czechia_payroll_industry_branch* – Číselník odvětví v tabulce mezd.
4. *czechia_payroll_unit* – Číselník jednotek hodnot v tabulce mezd.
5. *czechia_payroll_value_type* – Číselník typů hodnot v tabulce mezd.
6. *czechia_price* – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
7. *czechia_price_category* – Číselník kategorií potravin, které se vyskytují v našem přehledu.


### Číselníky sdílených informací o ČR:

1. *czechia_region* – Číselník krajů České republiky dle normy CZ-NUTS 2.
2. *czechia_district* – Číselník okresů České republiky dle normy LAU.

### Dodatečné tabulky:

1. *countries* - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
2. *economies* - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

 
## Výzkumné otázky

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

 
## Výstupy z projektu

Pomozte kolegům s daným úkolem. Výstupem by měly být **dvě tabulky v databázi**, ze kterých se požadovaná data dají získat. 
Tabulky pojmenujte:
 *t_{jmeno}_{prijmeni}_project_SQL_primary_final* (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a 
 *t_{jmeno}_{prijmeni}_project_SQL_secondary_final* (pro dodatečná data o dalších evropských státech).

Dále připravte **sadu SQL**, které z vámi připravených tabulek získají datový podklad k odpovězení na vytyčené výzkumné otázky. 
Pozor, otázky/hypotézy mohou vaše výstupy podporovat i vyvracet! Záleží na tom, co říkají data.
Na svém GitHub účtu **vytvořte veřejný repozitář**, kam uložíte všechny informace k projektu – hlavně SQL skript generující výslednou tabulku, popis mezivýsledků (průvodní listinu) ve formátu markdown (.md) a informace o výstupních datech (například kde chybí hodnoty apod.).
**Neupravujte data v primárních tabulkách!** Pokud bude potřeba transformovat hodnoty, dělejte tak až v tabulkách nebo pohledech, které si nově vytváříte.

# Vypracování projektu

## Tvorba tabulek

### Primary table 
Primary table *t_jana_vraspirova_project_SQL_primary_final* je vytvořena z primárních tabulek.

Sloupce jsem vybrala na základě výzkumných otázek. Další kritérium byla srozumitelnost pro uživatele.

#### Postup:

1. **Nejprve jsem vytvořila dvě views**

*primary_czechia_payroll* a *primary_czechia_price*

kde jsem si otestovala sloupce, které potřebuji.

Výslednou primary table jsem vytvořla za pomocí **CTE**. Vytvořená views mi pomohla k napsání výsledné query.

2. **Úpravy, problémy a otázky**

    1. V *primary_czechia_payroll* jsem se rozhodovala, zda použiji přepočet podle sloupce *calculation_code* **fyzický nebo přepočtený**. 
    Rozhodla jsem se pro fyzický, protože mi připadá, že lépe reflektuje realitu.

    2. V *primary_czechia_price* jsem **vytvořila sloupec year** na propojení s *primary_czechia_payroll*.

    3. Dále jsem zjistila, že v *primary_czechia_payroll* jsou dostupné roky už **od roku 2000**, zatímco v *primary_czechia_price* až **od roku 2006**. Zvažovala jsem, jestli ve výsledné tabulce nechám pro payroll všechny dostupné roky, nebo vyfiltruji roky podle tabulky price. Protože první výzkumná otázka pracuje pouze s údaji pro payroll, rozhodla jsem se v tabulce ponechat všechny roky a pro další otázky filtrovat až pomocí query.

    4. Další problém byly **nulové hodnoty** v tabulce *primary_czechia_payroll* ve sloupci *industry*. Ověřila jsem si, zda se nejedná o chybu query a potvrdila jsem si, že query je v pořádku. **Nulové hodnoty se vyskytují už v původní tabulce**, jedná se tedy o **chybějící data**. Proto jsem přidala podmínku **IS NOT NULL**, abych pracovala jen s kompletními řádky.

    5. Jako poslední jsem zjistila, že musím zohlednit to, že **každá industry má v každém roce přiřazené všechny food categories**. Toto jsem vyřešla groupováním.



### Secondary table

Secondary table *t_jana_vraspirova_project_SQL_secondary_final*

Když jsem si pročetla zadání všech výzkumných otázek, zjistila jsem, že mi stačí pouze slupec *gdp* (a sloupec *year* na propojení) z tabulky *economies*. Nevím, zda máme **jiné zadání, než bylo dříve**, ale z tabulky countries jsem nepotřebovala nic. V rámci procvičení jsem použila alespoň *currency*.

Protože **HDP se počítá s daty z předchozího roku**, v tabulce jsem použila data **od roku 2005**, abych měla výsledky od roku 2006, kdy mám kompletní data v *t_jana_vraspirova_project_SQL_primary_final*.

## Výzkumné otázky

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
K této otázce nabízím tři pohledy (3 SQL query):

#### Následující odvětví zažila pokles mzdy alespoň jednou v letech 2009 -2021:
*	Těžba a dobývání
*	Veřejná správa a obrana; povinné sociální zabezpečení
*	Kulturní, zábavní a rekreační činnosti
*	Ubytování, stravování a pohostinství
*	Činnosti v oblasti nemovitostí
*	Profesní, vědecké a technické činnosti
*	Stavebnictví
*	Velkoobchod a maloobchod; opravy a údržba motorových vozidel
*	Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu
*	Vzdělávání
*	Zemědělství, lesnictví, rybářství
*	Peněžnictví a pojišťovnictví
*	Zpracovatelský průmysl
*	Informační a komunikační činnosti
*	Zásobování vodou; činnosti související s odpady a sanacemi

Tento pohled je doplněný o konkrétní mzdy a roky pro srovnání. 

#### Které odvětví zažilo pokles mezd nejčastěji?
*	Těžba a dobývání zažila pokles mezd 4x v letech 2009 -2021

#### Které odvětví zažilo pokles mzdy v nejvíce následujících letech po sobě

Následující dvě odvětví zažila pokles mezd ve 3 po sobě následujících letech: 

*	Veřejná správa a obrana; povinné sociální zabezpečení
*	Těžba a dobývání

Z této analýzy plyne, že odvětví **Těžba a dobývání** bylo v letech 2009 -2021 nejvíce zasažené poklesem mezd **(4x)** a navíc utrpělo pokles mezd **ve 3 letech následujících po sobě**.

###  2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

* První srovnatelné období je **rok 2006**.

    * V tomto roce bylo možné si koupit za průměrnou mzdu **1262 kg chleba a 1409 l mléka**.
    * Za medián mzdy bylo možné koupit **1129 kg chleba a 1260 l mléka**.

* Poslední srovnatelné období je **rok 2018**.

    * V tomto roce bylo možné si koupit za průměrnou mzdu **1319 kg chleba a 1614 l mléka**.
    * Za medián mzdy bylo možné koupit **1190 kg chleba a 1455 l mléka**.

Průměrná kupní síla obyvatel tedy **mezi lety 2006 a 2018 vzrostla**, i když v mediánovém srovnání méně, než když se díváme na průměrnou mzdu.

Níže v přehledných tabulkách:

## Srovnání podle průměrné mzdy

|Potravina      | Rok 2006      |Rok 2018  |
| -------------  |:-----------:|:---------:|
| chleba (kg)    | 1262        |1319       | 
| mléko   (l)    | 1409        |1614       |  


## Srovnání podle mediánu mzdy

|Potravina      | Rok 2006      |Rok 2018  |
| -------------  |:-----------:|:---------:|
| chleba (kg)    | 1129        |1190      | 
| mléko   (l)    | 1260       |1455    |  



###  3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Nejnižší percentuální meziroční nárůst ceny je u kategorie **Cukr krystalový.**
Zde je naopak pokles o **-1.92 %**. 
Pokles ceny je také u kategorie **Rajská jablka červená kulatá**, a to o **-0,74 %.**

###  4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

* V období let 2007 – 2018 nebyl **žádný rok**, ve kterém by nárůst cen potravin byl o více než 10% vyšší než růst mezd. 
* **Nejvyšší meziroční rozdíl** byl v roce **2013** a to **6,79%**. V tomto roce cena potravin vzrostla o **6,01 %** a průměrný plat se snížil o **0,78%**.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

* Nejsilnější souvislost je mezi **nárůstem HDP a růstem mezd v následujícím roce (0,67)**. 
    * To znamená, že pokud vzroste HDP v jednom roce, můžeme predikovat nárůst mezd v následujícím roce.
    * Takzvaný *lagged effect = změna jedné proměnné má dopad až po určité době*.

* Vztah mezi nárůstem HDP a nárůstem ceny potravin v následujícím roce je **zanedbatelný (0,05)**. Současný ekonomický růst nedokáže predikovat nárůst cen potravin v následujícím roce.

* Nárůst HDP má **střední vliv** na nárůst potravin a mezd **ve stejném roce (0,43 resp. 0,47)**. Mají tendenci růst společně, ale ne výrazně.
