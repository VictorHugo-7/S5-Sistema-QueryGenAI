require('dotenv').config();
const db = require('./src/db/connection');

async function alter() {
  try {
    await db.query(`ALTER TABLE usuarios ADD COLUMN nome VARCHAR(255) NULL`);
    console.log('✔ Coluna nome adicionada');
  } catch (err) {
    if (err.code === 'ER_DUP_FIELDNAME') console.log('⚠ Coluna nome já existe');
    else throw err;
  }

  try {
    await db.query(`ALTER TABLE usuarios ADD COLUMN foto MEDIUMTEXT NULL`);
    console.log('✔ Coluna foto adicionada');
  } catch (err) {
    if (err.code === 'ER_DUP_FIELDNAME') {
      await db.query(`ALTER TABLE usuarios MODIFY COLUMN foto MEDIUMTEXT NULL`);
      console.log('✔ Coluna foto alterada para MEDIUMTEXT');
    } else {
      throw err;
    }
  }

  console.log('Concluído!');
  process.exit(0);
}

alter().catch(err => {
  console.error('Erro:', err.message);
  process.exit(1);
});
