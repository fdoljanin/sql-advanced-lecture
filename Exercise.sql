--V1.1: imena pjesama i korisnika koje su streamali u prosincu; ako nisu streamane, prikaži ih jednom
SELECT DISTINCT sg.Title, stu.Name FROM Songs sg
LEFT JOIN (
	SELECT * FROM Streams st
	JOIN Users u ON u.Id = st.UserId
	WHERE DATE_PART('month', st.CreatedAt) = 12
) stu
ON stu.SongId = sg.Id
ORDER BY sg.Title

--V1.2: komentare koje su dobili glazbenici čije ime počinje na c
SELECT m.Name, c.Content FROM Comments c
JOIN SongMusicians sm ON sm.SongId = c.SongId
JOIN Musicians m ON m.Id = sm.MusicianId
WHERE LOWER(m.Name) LIKE 'c%'

--V1.3: imena streamanih autora u 2020
SELECT DISTINCT m.Name FROM Musicians m
JOIN SongMusicians sm ON sm.MusicianId = m.Id
JOIN Streams st ON st.SongId = sm.SongId
WHERE DATE_PART('year', st.CreatedAt) = 2020

--V1.4: pjesmu i u drugi red izlistane ocjene
SELECT s.Title,
	(SELECT STRING_AGG(CAST(g.Value AS VARCHAR), ',') FROM Grades g
	WHERE g.SongId = s.Id) AS Grades
FROM Songs s

--V2.1: za svakog slušatelja koliko je strog gledajući prosječnu ocjenu koju je dao
SELECT u.Name,
	CASE
		WHEN (SELECT AVG(g.Value) FROM Grades g WHERE g.UserId = u.Id) < 2.5 THEN 'Strict'
		ELSE 'Okay'
	END AS Strictness
FROM Users u

--V2.2: za svaku pjesmu ispiši posljednu ocjenu veću od 3 koju je dobila; ako nije, onda ispiši ‘Nema’
SELECT s.Id, s.Title,
	COALESCE(CAST(
		(SELECT g.Value FROM Grades g
	 	WHERE g.SongId = s.Id AND g.Value > 3
	 	ORDER BY g.CreatedAt DESC
	 	LIMIT 1) AS VARCHAR), 'Nema')
FROM Songs s

--V3.1: proječnu i najveću ocjenu koju je svaki korisnik dao
SELECT u.Id, u.Name, ROUND(AVG(g.Value), 2), MAX(g.Value) FROM Users u
LEFT JOIN Grades g ON g.UserId = u.Id
GROUP BY u.Id
ORDER BY u.Id

--V3.2: pjesmu s najvećim brojem komentara po žanru
SELECT DISTINCT ON (s.Genre) s.Genre, s.Title, COUNT(*) CommentCount FROM Songs s
JOIN Comments c ON c.SongId = s.Id
GROUP BY s.Id
ORDER BY s.Genre, CommentCount DESC

--V3.3: autora s najvećom prosječnom ocjenom po žanru i godini izlaska i uz njega najpopularniju mu pjesmu te kategorije
--u slučaju da je ocjena manja od 2, ne prikazuj, a inače napiši “popular” ako je avg<=3, u suprotnom “best of”
SELECT DISTINCT ON (s.Genre, RelTime)
	RelTime AS ReleaseTime,
	s.Genre,
	m.Name,
	ROUND(AVG(g.Value), 3) AvgGrade,
	(SELECT sg.Title FROM Songs sg
	 	JOIN Streams st ON st.SongId = sg.Id
	 	JOIN SongMusicians sgm ON sgm.SongId = sg.Id 
	 	WHERE sgm.MusicianId = m.Id AND sg.Genre = s.Genre
	 		AND DATE_PART('year', sg.ReleaseTime) = RelTime
	 	GROUP BY sg.Id
	 	ORDER BY COUNT(*) DESC
	 	LIMIT 1) AS CategoryMostPopularSong,
	 CASE
	 	WHEN AVG(g.Value) < 2 THEN NULL
		WHEN AVG(g.Value) <=3 THEN 'Popular'
		ELSE 'Best of' END AS AuthorCategoryQuality
FROM Musicians m
JOIN SongMusicians sm ON sm.MusicianId = m.Id
JOIN (SELECT *, DATE_PART('year', ReleaseTime) RelTime FROM Songs) s ON s.Id = sm.SongId
JOIN Grades g ON g.SongId = s.Id
GROUP BY m.Id, s.Genre, RelTime
ORDER BY RelTime, s.Genre, AvgGrade DESC