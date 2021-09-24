CREATE DATABASE Pizzeria

CREATE TABLE Pizza(
IdPizza INT IDENTITY(1,1) PRIMARY KEY,
Nome NVARCHAR(50) UNIQUE NOT NULL,
Prezzo DECIMAL(3,2) NOT NULL CHECK (Prezzo > 0)
)

CREATE TABLE Ingrediente(
IdIngrediente INT IDENTITY(1,1) PRIMARY KEY,
Nome NVARCHAR(50) UNIQUE NOT NULL,
Costo DECIMAL(3,2) NOT NULL CHECK (Costo > 0),
Scorte INT NOT NULL CHECK (Scorte >= 0)
)

CREATE TABLE PizzaIngrediente(
IdPizza INT,
IdIngrediente INT,
CONSTRAINT FK_Pizza FOREIGN KEY (IdPizza) REFERENCES Pizza(IdPizza),
CONSTRAINT FK_Ingred FOREIGN KEY (IdIngrediente) REFERENCES Ingrediente(IdIngrediente)
)

INSERT INTO Pizza VALUES
('Margherita', 5),
('Bufala', 7),
('Diavola', 6),
('Quattro stagioni', 6.50),
('Porcini', 7),
('Dioniso', 8),
('Ortolana', 8),
('Patate e salsiccia', 6),
('Pomodorini', 6),
('Quattro formaggi', 7.50),
('Caprese', 7.50),
('Zeus', 7.50)

INSERT INTO Ingrediente VALUES
('Pomodoro', 3, 20),
('Mozzarella', 4, 10),
('Mozzarella di bufala', 5, 9),
('Spianata piccante', 6, 11),
('Funghi', 4.5, 15),
('Carciofi', 4, 13),
('Cotto', 6, 10),
('Olive', 3.5, 14),
('Funghi porcini', 6, 8),
('Stracchino', 5.3, 4),
('Speck', 4, 6),
('Rucola', 2.5, 7),
('Grana', 4, 5),
('Verdure di stagione', 3, 5),
('Salsiccia', 4, 12),
('Pomodorini', 3.5, 17),
('Ricotta', 5, 2),
('Provola', 5, 4),
('Gorgonzola', 5.5, 3),
('Pomodoro fresco', 2, 22),
('Basilico', 1.5, 25),
('Bresaola', 6, 12),
('Patate', 2, 31)

INSERT INTO PizzaIngrediente VALUES
(1,1),(1,2), --Margherita
(2,1),(2,3), --Bufala
(3,1),(3,2),(3,4), --Diavola
(4,1),(4,2),(4,5),(4,6),(4,7),(4,8), --Quattro stagioni
(5,1),(5,2),(5,9), --Porcini
(6,1),(6,2),(6,10),(6,11),(6,12),(6,13), --Dioniso
(7,1),(7,2),(7,14), --Ortolana
(8,2),(8,23),(8,15), --Patate e salsiccia
(9,2),(9,16),(9,17), --Pomodorini
(10,2),(10,18),(10,19),(10,13), --Quattro formaggi
(11,2),(11,20),(11,21), --Caprese
(12,2),(12,22),(12,12) --Zeus


-- ESERCITAZIONE - SI IMPLEMENTINO LE SEGUENTI QUERY:

--1. Estrarre tutte le pizze con prezzo superiore a 6 €
SELECT *
FROM Pizza
WHERE Prezzo > 6

--2. Estrarre la pizza più costosa
SELECT *
FROM Pizza
WHERE Prezzo = (SELECT MAX(Prezzo) FROM Pizza)

--3. Estrarre le pizze "bianche"
SELECT Nome
FROM Pizza
EXCEPT
SELECT p.Nome
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.Nome = 'Pomodoro'

--4. Estrarre le pizze che contengono funghi (di qualsiasi tipo)
SELECT p.Nome
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.Nome LIKE 'Funghi%'


-- ESERCITAZIONE - IMPLEMENTARE SUL DB APPENA COSTRUITO LE SEGUENTI PROCEDURE:

--1. Inserimento di una nuova pizza (parametri: nome, prezzo)
CREATE PROCEDURE InserisciPizza
@nome NVARCHAR(50),
@prezzo DECIMAL(3,2)
AS
INSERT INTO Pizza VALUES(@nome, @prezzo)
GO

EXEC InserisciPizza @nome = 'Rucola e grana', @prezzo = 6.5

--2. Assegnazione di un ingrediente a una pizza (parametri: nome pizza, nome ingrediente)
CREATE PROCEDURE AssegnaIngrediente
@nomePizza NVARCHAR(50),
@nomeIngrediente NVARCHAR(50)
AS
INSERT INTO PizzaIngrediente VALUES 
((SELECT IdPizza FROM Pizza WHERE Nome=@nomePizza),(SELECT IdIngrediente FROM Ingrediente WHERE Nome=@nomeIngrediente))
GO

EXEC AssegnaIngrediente @nomePizza='Rucola e grana',@nomeIngrediente='Pomodoro'
EXEC AssegnaIngrediente @nomePizza='Rucola e grana',@nomeIngrediente='Mozzarella'
EXEC AssegnaIngrediente @nomePizza='Rucola e grana',@nomeIngrediente='Rucola'
EXEC AssegnaIngrediente @nomePizza='Rucola e grana',@nomeIngrediente='Grana'

--3. Aggiornamento del prezzo di una pizza (parametri: nome e nuovo prezzo)
CREATE PROCEDURE CambiaPrezzo
@nome NVARCHAR(50),
@nuovoPrezzo DECIMAL(3,2)
AS
UPDATE Pizza SET Prezzo = @nuovoPrezzo WHERE Nome=@nome
GO

EXEC CambiaPrezzo @nome='Margherita',@nuovoPrezzo=4.5

--4. Eliminazione di un ingrediente da una pizza (parametri: nome pizza, nome ingrediente)
CREATE PROCEDURE CancellaIngrediente
@nomePizza NVARCHAR(50),
@nomeIngrediente NVARCHAR(50)
AS
DELETE FROM PizzaIngrediente WHERE IdPizza IN(
	SELECT p.IdPizza
	FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
	WHERE p.Nome=@nomePizza AND i.Nome=@nomeIngrediente)
	AND
	IdIngrediente IN(
	SELECT i.IdIngrediente
	FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
	WHERE p.Nome=@nomePizza AND i.Nome=@nomeIngrediente)

EXEC CancellaIngrediente @nomePizza='Margherita',@nomeIngrediente='Pomodoro'

--5. Incremento del 10% del prezzo delle pizze contenenti un ingrediente (parametro: nome ingrediente)
CREATE PROCEDURE Aumenta10
@nomeIngrediente NVARCHAR(50)
AS
UPDATE Pizza SET Prezzo = Prezzo+((Prezzo*10)/100)
			 WHERE IdPizza IN(
				SELECT p.IdPizza
				FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			                 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
				WHERE i.Nome = @nomeIngrediente)

EXEC Aumenta10 @nomeIngrediente='Cotto'

-- ESERCITAZIONE - SI IMPLEMENTINO LE SEGUENTI FUNZIONI:

--1. Tabella listino pizze (nome, prezzo) ordinato alfabeticamente (parametri: nessuno)
CREATE FUNCTION ListaPizzeAB()
RETURNS TABLE
AS
RETURN
SELECT Nome, Prezzo
FROM Pizza

SELECT *
FROM ListaPizzeAB()
ORDER BY Nome

--2. Tabella listino pizze (nome, prezzo) contenenti un ingrediente (parametri: nome ingrediente)
CREATE FUNCTION ListaPizze_Ing(@nomeIng NVARCHAR(50))
RETURNS TABLE
AS
RETURN
SELECT p.Nome, p.Prezzo
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.Nome=@nomeIng

SELECT *
FROM ListaPizze_Ing('Mozzarella di bufala')

--3. Tabella listino pizze (nome, prezzo) che non contengono un certo ingrediente (parametri: codice ingrediente)
CREATE FUNCTION ListaPizzeNotIng(@idIng INT)
RETURNS TABLE
AS
RETURN
SELECT Nome, Prezzo
FROM Pizza
EXCEPT
SELECT p.Nome, p.Prezzo
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.IdIngrediente = @idIng

SELECT *
FROM ListaPizzeNotIng(2)

--4. Calcolo numero pizze contenenti un ingrediente (parametri: nome ingrediente)
CREATE FUNCTION NumPizzeConIngrediente(@nomeIngrediente NVARCHAR(50))
RETURNS INT
AS
BEGIN
DECLARE @output INT
SELECT @output = COUNT(p.IdPizza)
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.Nome = @nomeIngrediente
RETURN @output
END

SELECT dbo.NumPizzeConIngrediente('Cotto')

--5. Calcolo numero pizze che non contengono un ingrediente (parametri: codice ingrediente)
CREATE FUNCTION NumPizzeSenzaIngrediente(@idIngrediente INT)
RETURNS INT
AS
BEGIN
DECLARE @output INT
SELECT @output =
(SELECT COUNT(IdPizza)
FROM Pizza)
-
(SELECT COUNT(p.IdPizza)
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE i.IdIngrediente = @idIngrediente)
RETURN @output
END

SELECT dbo.NumPizzeSenzaIngrediente(2)

--6. Calcolo numero ingredienti contenuti in una pizza (parametri: nome pizza)
CREATE FUNCTION ContaIngredienti(@nomePizza NVARCHAR(50))
RETURNS INT
AS
BEGIN
DECLARE @output INT
SELECT @output = COUNT(i.IdIngrediente) 
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
WHERE p.Nome=@nomePizza
RETURN @output
END

SELECT dbo.ContaIngredienti('Quattro stagioni')

--5. Realizzare una view che rappresenta il menù con tutte le pizze
CREATE VIEW MenuPizze (Pizza, Prezzo, Ingredienti)
AS(
SELECT p.Nome, p.Prezzo, i.Nome
FROM Pizza p JOIN PizzaIngrediente r ON p.IdPizza=r.IdPizza
			 JOIN Ingrediente i ON r.IdIngrediente=i.IdIngrediente
)