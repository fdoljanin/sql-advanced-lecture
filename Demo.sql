-- 1.1: komentari s imenom pjesme i korisnika; s i bez joina
SELECT s.Title, u.Name, c.Content FROM Comments c
JOIN Songs s ON s.Id = c.SongId
JOIN Users u ON u.Id = c.UserId
LIMIT 10

SELECT c.Content,
(SELECT MAX(Title) FROM Songs WHERE Id = c.SongId) AS Title
FROM Comments c
LIMIT 10

--1.2: pjesme s nazivom autora
SELECT s.Title, m.Name FROM Songs s
JOIN SongMusicians sm ON sm.SongId = s.Id
JOIN Musicians m ON m.Id = sm.MusicianId
LIMIT 10

--1.2.1: pjesme s nazivima autora u drugoj ćeliji
SELECT s.Title,
(SELECT STRING_AGG(Name, ', ') FROM Musicians m WHERE
	(SELECT Count(*) FROM SongMusicians sm WHERE sm.MusicianId = m.Id AND sm.SongId = s.Id) > 0)
AS Musicians
FROM Songs s
LIMIT 10

--1.3: broj streamanih pjesama ove godine
SELECT DISTINCT Value FROM Grades
LIMIT 10

SELECT COUNT(DISTINCT SongId) FROM Streams
WHERE DATE_PART('year', CreatedAt) = DATE_PART('year', NOW())

--1.4: autori streamani protekli mjesec
SELECT DISTINCT m.Name FROM Streams st
JOIN Songs sg ON sg.Id = st.SongId
JOIN SongMusicians sm ON sg.Id = sm.SongId
JOIN Musicians m ON m.Id = sm.MusicianId
WHERE st.CreatedAt >= NOW() - INTERVAL '1 month'

--2.1: ocjena 1-5 tekstualno
SELECT DISTINCT Value,
CASE
	WHEN Value <= 2 THEN 'Bad'
	WHEN Value <=4 THEN 'Ok'
	WHEN Value = 5 THEN 'Great' END
FROM Grades

--2.2: popularnost pjesme po broju streamova
SELECT Title,
CASE
WHEN (SELECT COUNT(*) FROM Streams st WHERE st.SongId = sg.Id) > 100
	THEN 'Popular'
	ELSE 'Unpopular' END
AS Popularity
FROM Songs sg

--2.3:  posljednji stream svakog autora; ako ga nema, onda None
SELECT m.Name,
	COALESCE(CAST((SELECT MAX(st.CreatedAt) FROM Streams st
	JOIN Songs sg ON sg.Id = st.SongId
	JOIN SongMusicians sm ON sg.Id = sm.SongId
	WHERE sm.MusicianId = m.Id) AS varchar), 'None') AS LastStream
FROM Musicians m

--2.4: svi streamovi na pjesme koje nemaju komentar
SELECT * FROM Streams sm
JOIN Songs sg ON sm.SongId = sg.Id
WHERE NOT sg.Id = ANY(SELECT SongId FROM Comments)

--3.1: broj pjesama po žanru
SELECT DISTINCT Genre, COUNT(*) FROM Songs
GROUP BY Genre

--3.2: pjesme sortirane po broju streamova
SELECT DISTINCT sg.Id, Title, COUNT(*) AS Count FROM Songs sg
JOIN Streams sm ON sm.SongId = sg.Id
GROUP BY sg.Id
ORDER BY Count DESC

--3.3: pjesme sortirane po prosječnoj ocjeni ako je veća od 3
SELECT DISTINCT sg.Id, Title, ROUND(AVG(g.Value)*2, 2) AS AverageGrade FROM Songs sg
JOIN Grades g ON g.SongId = sg.Id
GROUP BY sg.Id
HAVING ROUND(AVG(g.Value), 2) > 3
ORDER BY AverageGrade

--3.3.1: autori i žanrovi po prosječnoj ocjeni
SELECT DISTINCT m.Name,Genre, ROUND(AVG(g.Value), 2) AS AvgGrade FROM Songs sg
JOIN Grades g ON g.SongId = sg.Id
JOIN SongMusicians sm ON sm.SongId = sg.Id
JOIN Musicians m ON m.Id = sm.MusicianId
GROUP BY Genre, m.Id
ORDER BY m.Name, AvgGrade

--3.4: top 3 slušatelja čiji je račun iz 2014. glazbenika Cardi B
SELECT DISTINCT u.Id, u.Name, COUNT(*) AS StreamCount FROM Users u
JOIN Streams st ON st.UserId = u.Id
JOIN Songs sg ON sg.Id = st.SongId
JOIN SongMusicians sm ON sg.Id = sm.SongId
JOIN Musicians m ON m.Id = sm.MusicianId
WHERE m.Name = 'Cardi B'
GROUP BY u.Id
HAVING DATE_PART('year', u.RegisterTime) = 2014
ORDER BY StreamCount DESC
LIMIT 3

--3.5: naziv i datum prve pjesma svakog autora
SELECT DISTINCT ON (m.Id) m.Id, m.Name, s.Title, s.ReleaseTime FROM Musicians m
JOIN SongMusicians sm ON sm.MusicianId = m.Id
JOIN Songs s ON sm.SongId = s.Id
ORDER BY m.Id, s.ReleaseTime

--razno
CREATE PROCEDURE UpdateSong(SongId int, NewTitle varchar)
LANGUAGE SQL
AS $$
UPDATE Songs
SET Title = NewTitle
WHERE Id = SongId
$$

CALL UpdateSong(2, 'Songg')

CREATE INDEX song_title_optimized ON Songs(title)