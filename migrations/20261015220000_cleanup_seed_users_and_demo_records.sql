-- migrate:up
-- Eliminar usuario de prueba carlos.perez@talentus.app para evitar envíos a buzones inexistentes y rebotes de correo.
-- La eliminación en cascada purga atletas, consentimientos, suscripciones y transacciones dependientes.
DELETE FROM users WHERE email = 'carlos.perez@talentus.app';

-- migrate:down
-- No se restaura usuario semilla de pruebas para evitar rebotes de correo.
