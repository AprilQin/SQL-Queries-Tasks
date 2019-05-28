--for debug
SELECT distinct M.title
FROM Movie M, Studio S
WHERE M.studioID = S.studioID AND S.studioName = 'FOX'


--Queries.sql

--a)
SELECT A1.name, Count (DISTINCT M.studioID) as numStudios 
FROM Actors A1, ActedIn A2, Movie M
WHERE A1.name = A2.name AND A2.title = M.title
GROUP BY A1.name
ORDER BY numStudios ASC


--b)
SELECT A1.name, COUNT(*) AS numMovies
FROM Actors A1, ActedIn A2
WHERE A1.name = A2.name
GROUP BY A1.name 
HAVING COUNT(*) >= 2
ORDER BY numMovies DESC

--c)
SELECT A.stdID, COUNT(*) numActors
FROM ActedIn inner join (
	SELECT M.studioID stdID, title
	FROM Movie M inner join (
		SELECT studioID
		FROM Movie	
		WHERE year>= 1950 AND year <= 1999
		GROUP BY studioID
		HAVING COUNT(*) >= 14 
	) AS studios on M.studioID = studios.studioID 
	where M.year>= 1950 AND M.year <= 1999
)  as A on ActedIn.title = A.title
GROUP BY A.stdID

--d)
SELECT M.title, MAX(S.[duration(sec)])
FROM Movie M inner join Soundtrack S on M.title = S.title 
WHERE M.genre = 'action' 
Group by M.title

--e)
Select studioName, numActors, numMovies
FROM (
	(SELECT S.studioName, S.studioID
	FROM Studio S
	WHERE S.est > 1930) N
		
	inner join

	(SELECT COUNT(distinct A.name) AS numActors, M.studioID
	FROM ActedIn A inner join Movie M
	on A.title = M.title
	GROUP BY M.studioID) A on N.studioID = A.studioID 
		
	inner join

	(SELECT COUNT(*) AS numMovies, Studio.studioID
	FROM Movie, Studio
	WHERE Movie.studioID = Studio.studioID
	GROUP BY Studio.studioID) M on A.studioID = M.studioID
) 

--f)
SELECT R.title, R.avgRank
FROM (
	SELECT M.title, AVG(S.rank) AS avgRank
	FROM Movie M, Keywords K, Soundtrack S
	WHERE M.title = K.title and M.title = S.title AND (K.keyword = 'arson' OR K.keyword = 'arsonist') 
	GROUP BY M.title
) AS R

