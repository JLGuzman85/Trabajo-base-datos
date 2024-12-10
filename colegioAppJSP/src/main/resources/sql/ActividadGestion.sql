-- Active: 1733526205898@@127.0.0.1@3306@colegio


--Dado el software colegioAPPJSP y su base de datos:
-- Armar tabla de auditoria y triggers para auditar los movimientos del software (insert-delete-update),
-- Usando Triggers, interceptar las acciones de delete físico y mover registros borrados a una tabla alternativa.
use colegio;

DROP TABLE IF EXISTS control_auditoria;
CREATE TABLE control_auditoria(
    id int AUTO_INCREMENT PRIMARY KEY,
    tabla varchar(50) not null,
    evento ENUM ('INSERT','DELETE','UPDATE') NOT NULL,
    id_registro INT,
    fecha date,
    hora time,
    usuario VARCHAR(50)
);

-------------------        Auditoria de insert cursos        -------------------
DROP TRIGGER IF EXISTS TR_cursos_insert;
CREATE TRIGGER TR_cursos_insert
AFTER INSERT ON cursos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('cursos','INSERT', NEW.id, CURDATE(), CURTIME(),
                USER());
    END; 

INSERT INTO cursos(titulo,profesor,dia,turno)VALUES
('GestionBaseDatos','Jonatan','Lunes','Mañana'),
('AdministracionBaseDatos','Leonel','Miercoles','Tarde'),
('ProgramacionOrientadaObjetos','Guzman','Viernes','Tarde');

select * from cursos;
select * from control_auditoria;  

-------------------        Auditoria de Delete cursos        -------------------

DROP TRIGGER IF EXISTS TR_cursos_delete;
CREATE TRIGGER TR_cursos_delete
AFTER DELETE ON cursos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('cursos','DELETE', OLD.id, CURDATE(), CURTIME(),
                USER());
    END; 

delete from cursos where id=6;
select * from control_auditoria;

-------------------        Auditoria de update cursos        -------------------

DROP TRIGGER IF EXISTS TR_cursos_update;
CREATE TRIGGER TR_cursos_update
AFTER UPDATE ON cursos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('cursos','UPDATE', OLD.id, CURDATE(), CURTIME(),
                USER());
    END; 

update cursos set profesor='Jonatan' where id=2;
select * from control_auditoria;


-------------------        Auditoria de insert Alumnos        -------------------

DROP TRIGGER IF EXISTS TR_alumnos_insert;
CREATE TRIGGER TR_alumnos_insert
AFTER INSERT ON alumnos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('alumnos','INSERT', NEW.id, CURDATE(), CURTIME(),
                USER());
    END; 

INSERT INTO alumnos(nombre,apellido,edad,id_curso)VALUES
('Marcelo','Tinelli',64,7),
('Adrian','Suar',56,8),
('Chato','Prada',54,9);
 
select * from alumnos;
select * from control_auditoria;  

-------------------        Auditoria de Delete Alumnos        -------------------

DROP TRIGGER IF EXISTS TR_alumnos_delete;
CREATE TRIGGER TR_alumnos_delete
AFTER DELETE ON alumnos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('alumnos','DELETE', OLD.id, CURDATE(), CURTIME(),
                USER());
    END; 

delete from alumnos where id=28;
select * from control_auditoria;

-------------------        Auditoria de update Alumnos        -------------------

DROP TRIGGER IF EXISTS TR_alumnos_update;
CREATE TRIGGER TR_alumnos_update
AFTER UPDATE ON alumnos FOR EACH ROW
    BEGIN
        INSERT INTO control_auditoria 
            (tabla, evento, id_registro, fecha, hora, usuario)
            VALUES
            ('alumnos','UPDATE', OLD.id, CURDATE(), CURTIME(),
                USER());
    END; 

update alumnos set nombre='Marcelo' where id=1;
select * from control_auditoria;
select * from alumnos;

----------------        Tabla alternativa Registro Eliminados (cursos)    -------------------

DROP TABLE IF EXISTS cursos_eliminados;
CREATE TABLE cursos_eliminados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_registro int,
    titulo VARCHAR(25),
    profesor VARCHAR(25),
    dia VARCHAR(25),
    turno VARCHAR(25)
);

DROP TRIGGER IF EXISTS TR_cursos_delete_alternativo;
CREATE TRIGGER TR_cursos_delete_alternativo
BEFORE DELETE ON cursos
FOR EACH ROW
BEGIN
    INSERT INTO cursos_eliminados (id_registro, titulo, profesor, dia, turno)
    VALUES 
    (OLD.id, OLD.titulo, OLD.profesor, OLD.dia, OLD.turno);
END;

select * from cursos;
delete from cursos where id=2;
SELECT * FROM cursos_eliminados;

---------------      Tabla alternativa Registro Eliminados (alumnos)     ------------------------

DROP TABLE IF EXISTS alumnos_eliminados;
CREATE TABLE alumnos_eliminados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_registro int,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    edad INT,
    id_curso INT
);


DROP TRIGGER IF EXISTS TR_alumnos_delete_alternativo;
CREATE TRIGGER TR_alumnos_delete_alternativo
BEFORE DELETE ON alumnos
FOR EACH ROW
BEGIN
    INSERT INTO alumnos_eliminados (id_registro, nombre, apellido, edad, id_curso)
    VALUES 
    (OLD.id, OLD.nombre, OLD.apellido, OLD.edad, OLD.id_curso);
END;

select * from alumnos;
delete from alumnos where id=30;
SELECT * FROM alumnos_eliminados;