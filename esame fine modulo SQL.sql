/*
Task 4
*/

-- 1) Verificare che i campi definiti come PK siano univoci. In altre parole, scrivi una query per determinare l’univocità dei valori di ciascuna PK (una query per tabella implementata).

select
CodiceCategoria
, count(*) as PK
from categoria
group by CodiceCategoria
having count(*) > 1;

select 
CodiceProdotto
, count(*) as PK
from prodotti
group by CodiceProdotto
having count(*) > 1;

select 
CodicePaese
, count(*) as PK
from regioni
group by CodicePaese
having count(*) > 1;

select 
NumeroOrdineVendita
, LineaOrdineVendita
, count(*) as PK
from sales
group by NumeroOrdineVendita, LineaOrdineVendita
having count(*) > 1;

-- Commento: Per poter capire se un campo possa essere definito chiave primaria ha eseguito una query andando a raggruppare la colonna che viene definita come chiave primaria, 
-- andando a contare quanto volte il dato veniva ripetuto attraverso la funzione (having). 
-- Se il risultato fosse stato maggiore di uno allora quel campo non poteva venire considerato chiave primaria.


-- 2) Esporre l’elenco delle transazioni indicando nel result set il codice documento, la data, il nome del prodotto, la categoria del prodotto, il nome dello stato, 
-- il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati più di 180 giorni dalla data vendita o meno.

select 
s.NumeroOrdineVendita
, s.DataOrdine
, p.NomeProdotto
, c.NomeCategoria
, r.NomePaese
, r.NomeRegione
from categoria as c
inner join prodotti as p
on c.CodiceCategoria = p.CodiceCategoria
inner join sales as s
on p.CodiceProdotto = s.CodiceProdotto
inner join regioni as r
on s.CodicePaese = r.CodicePaese;

-- Commento: per arrivare a mostrare i dati richiesti ho eseguito in questo cosa tre inner join, così facendo posso andare a recuperare tutti i dati che mi servivano dalle diverse tabelle.


-- 3) Esporre l’elenco dei prodotti che hanno venduto, in totale, una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito.
-- (ogni valore della condizione deve risultare da una query e non deve essere inserito a mano). 
-- Nel result set devono comparire solo il codice prodotto e il totale venduto.

select 
CodiceProdotto
, sum(PrezzoVendita) as totalevenduto
from sales
group by 
CodiceProdotto
having 
totalevenduto > (
select
avg(PrezzoVendita)
from sales
where
year(DataOrdine) = (SELECT MAX(YEAR(DataOrdine)) FROM sales)
);

-- Commento: Per poter riuscire a mostrare il fatturato totale di un determinato prodotto è necessario come prima cosa raggruppare il dato per cui si vuole sapere il fatturato e 
-- successivamente tramite la funzione sum si è in grado di calcolare il fatturato. 


-- 4)	Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno. 

select 
p.NomeProdotto
, year(DataOrdine) as DataOrdine
, sum(s.PrezzoVendita) as Fatturatototale
from prodotti as p
inner join sales as s
on p.CodiceProdotto = s.CodiceProdotto
group by 
p.NomeProdotto
, year(DataOrdine)
order by 
year(DataOrdine) asc;

-- Commento: In questo caso ho eseguito una inner join tra la tabella prodotti e quella sales e successivamente ho raggruppato il nome del prodotto e l'anno per poter eseguire una sum,
-- in modo tale da poter visualizzare il fatturato di ogni prodotto per anno.


-- 5)	Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.

select 
r.NomePaese
, r.NomeRegione
, year(DataOrdine) as DataOrdine
, sum(s.PrezzoVendita) as FatturatoTotale
from regioni as r
left outer join sales as s
on r.CodicePaese = s.CodicePaese
group by
r.NomePaese
, r.NomeRegione
, year(DataOrdine)
order by
year(DataOrdine) asc
, FatturatoTotale desc;

-- Commento: Come per l'eserizio precedente ho eseguito una join, e successivamente raggruppato per nome del paese e della regione e per anno 
-- ed infine eseguito una sum e ordinato l'anno, il fatturato per poter avere una visione migliore dei risultati di ogni paese ogni anno.


-- 6)	Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?

select 
c.NomeCategoria
, year(DataOrdine)
, count(QuantitaOrdine) as QuantitàOrdine
, sum(PrezzoVendita) as FatturatoTotale
from sales as s
inner join categoria as c
on s.CodiceCategoria = c.CodiceCategoria
group by 
c.NomeCategoria
, year(DataOrdine)
order by
year(DataOrdine) asc
, FatturatoTotale desc;

-- Commento: Per poter capire quale categoria sia quella che vende di più è necessario eseguire una join, 
-- raggruppare le categorie e se si vuole anche anche gli anni per poter avere una visione migliore dei dati,
-- ed infine calcolare il fatturato totale e/o le quantità vendute ordinandole come più si preferisce. 


-- 7)	Rispondere alla seguente domanda: quali sono i prodotti invenduti? Proponi due approcci risolutivi differenti.

select 
p.NomeProdotto
, p.CodiceProdotto
, s.CodiceProdotto
from prodotti as p
left outer join sales as s
on p.CodiceProdotto = s.CodiceProdotto
where s.CodiceProdotto is null;

select 
CodiceProdotto
from prodotti
where CodiceProdotto not in (
select
CodiceProdotto
from sales);

-- Commento: Per poter mostrare quali sono stati i prodotti che non sono stati venduti io ho utilizzato due metodi, 
-- il primo metodo in cui ho adottato una join normale tra le tabelle prodotti e sales e successivamente ho applicato un filtro per mostrare solo i prodotti che avevano come risultato null,
-- mentre il secondo ho eseguito una query normale senza join ma nel filtro ho eseguito una subquery per farmi vedee quili fossero i prodotti che non erano all'interno della tabella sales.


-- 8)	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni utili (codice prodotto, nome prodotto, nome categoria)

create view InfoProdotti as (
select 
p.CodiceProdotto
, p.NomeProdotto
, c.NomeCategoria
from prodotti as p
inner join categoria as c
on p.CodiceCategoria = c.CodiceCategoria
order by 
p.CodiceProdotto asc);

select *
from InfoProdotti;

-- 9)	Creare una vista per le informazioni geografiche

create view InfoRegioni as (
select 
r.NomePaese
, r.NomeRegione
, year(DataOrdine)
, sum(PrezzoVendita) as FatturatoTotale
from regioni as r
inner join sales as s
on r.CodicePaese = s.CodicePaese
group by
r.NomePaese
, r.NomeRegione
, year(DataOrdine)
order by
year(DataOrdine) asc);

select *
from inforegioni;
