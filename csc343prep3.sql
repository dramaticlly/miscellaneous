csc343prep3.sql

#DDL
#country(code, name, continent, population)
#	: each tuple represents a country with a three-letter code, a name, the continent it is on, and its population.
#countrylanguage(countrycode, countrylanguage, isofficial, percentage)
#	: 'countrycode' refers to the code attribute of a country, 'countrylanguage' is a language spoken in that country, 
#	'isofficial' is a boolean representing whether or not 'countrylanguage' is the official language of the country, 
#	and 'percentage' is the percentage of the country's population that speaks that language.


#Report the code of the country named 'Canada'.
select code from country where name = 'Canada'

#Report the code of every country where 'French' is the official language.
select countrycode from countrylanguage where countrylanguage = 'French'and isofficial = True

#Report the name and continent (in that order) of all countries where 'German' is spoken, 
#not necessarily as the official language.
select name, continent 
from country Inner JOIN countrylanguage 
on countrylanguage.countrycode = country.code 
where countrylanguage = 'German';

#Report the name and population of each country in 'Europe', ordered by their population, 
#with the most-populated country appearing first.
select name, population from country where continent ='Europe' order by population DESC;

#Report the code of every country where at least two different languages are spoken. 
#Rename the column to be named "bilingualcode".
select a.countrycode as bilingualcode 
from countrylanguage a, countrylanguage b 
where a.countrycode = b.countrycode and a.countrylanguage != b.countrylanguage;

#Report the code of every country where at least two different languages are spoken. 
#Rename the column to be named "bilingualcode".
select distinct a.countrycode as bilingualcode 
from countrylanguage a, countrylanguage b 
where a.countrycode = b.countrycode and a.countrylanguage != b.countrylanguage;


#\d show all tables

#search path
# set search_path to university;
# ctrl a to begin of line
# select sid, ave(grade) from took group by sid
# select sid, grade from took order by sid