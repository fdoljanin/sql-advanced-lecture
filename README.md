# Zadatci s predavanja
Zadatci se odnose na bazu Šrotify čiji sam [backup](ŠrotifyBackup.sql) priložio. Svakako prije rješavanja proučite strukturu baze pomoću ERD.

#### Demo
Join i distinct
- komentari s imenom pjesme i korisnika; sa i bez joina
- pjesme s nazivom autora
- pjesme s nazivima autora u drugoj ćeliji
- broj streamanih pjesama ove godine
- autori streamani protekli mjesec

Case i coalesce
- ocjena 1-5 opisno
- popularnost pjesme po broju streamova
- posljednji stream svakog autora; ako ga nema, onda _None_
- svi streamovi na pjesme koje nemaju komentar

Group by i distinct on
- broj pjesama po žanru
- pjesme sortirane po broju streamova
- pjesme sortirane po prosječnoj ocjeni ako je veća od 3
- autori i žanrovi po prosječnoj ocjeni
- top 3 slušatelja (čiji je račun iz 2014.) glazbenika Cardi B
- naziv i datum prve pjesma svakog autora

#### Vježba
Join i distinct
- imena pjesama i korisnika koje su streamali u prosincu; ako nisu streamane, prikaži ih jednom
- komentare koje su dobili glazbenici čije ime počinje na c
- imena streamanih autora u 2020.
- pjesmu i u drugi red izlistane ocjene

Case i coalesce
- za svakog slušatelja koliko je strog gledajući prosječnu ocjenu koju je dao
- za svaku pjesmu ispiši posljednu ocjenu veću od 3 koju je dobila; ako nikada nije, onda ispiši _Nema_

Group by i distinct on
- proječnu i najveću ocjenu koju je svaki korisnik dao
- pjesmu s najvećim brojem komentara po žanru
- autora s najvećom prosječnom ocjenom po žanru + godini izlaska i uz njega ime najpopularnije mu pjesme te kategorije; u slučaju da je ocjena kategorije manja od 2 - ne prikazuj, ako je <=3 - _Popular_, u suprotnom - _Best of_