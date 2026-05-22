require('dotenv').config();
const db = require('./src/db/connection');

async function setup() {

  // ── Tabelas do sistema ──
  await db.query(`
    CREATE TABLE IF NOT EXISTS usuarios (
      id INT AUTO_INCREMENT PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      senha_hash VARCHAR(255) NOT NULL,
      nome VARCHAR(255) NULL,
      foto MEDIUMTEXT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  console.log('✔ usuarios');

  await db.query(`
    CREATE TABLE IF NOT EXISTS historico (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      pergunta TEXT NOT NULL,
      sql_gerado TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )
  `);
  console.log('✔ historico');

  await db.query(`
    CREATE TABLE IF NOT EXISTS tokens_recuperacao (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      token CHAR(6) NOT NULL,
      expira_em TIMESTAMP NOT NULL,
      usado BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )
  `);
  console.log('✔ tokens_recuperacao');

  // ── Tabelas SAP ──
  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_mara (
      MATNR VARCHAR(18) PRIMARY KEY,
      MATKL VARCHAR(9),
      MTART VARCHAR(4),
      MEINS VARCHAR(3),
      MAKTX VARCHAR(40),
      NTGEW DECIMAL(13,3),
      ERSDA DATE
    )
  `);
  console.log('✔ sap_mara');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_mard (
      MATNR VARCHAR(18),
      WERKS VARCHAR(4),
      LGORT VARCHAR(4),
      LABST DECIMAL(13,3),
      PRIMARY KEY (MATNR, WERKS, LGORT)
    )
  `);
  console.log('✔ sap_mard');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_mseg (
      MBLNR VARCHAR(10),
      ZEILE VARCHAR(4),
      BWART VARCHAR(3),
      MATNR VARCHAR(18),
      WERKS VARCHAR(4),
      LGORT VARCHAR(4),
      MENGE DECIMAL(13,3),
      DMBTR DECIMAL(13,2),
      BUDAT DATE,
      PRIMARY KEY (MBLNR, ZEILE)
    )
  `);
  console.log('✔ sap_mseg');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_afko (
      AUFNR VARCHAR(12) PRIMARY KEY,
      MATNR VARCHAR(18),
      WERKS VARCHAR(4),
      GAMNG DECIMAL(13,3),
      GMEIN VARCHAR(3),
      GSTRI DATE,
      GETRI DATE,
      GSTRS DATE,
      GETRS DATE,
      AUFART VARCHAR(4)
    )
  `);
  console.log('✔ sap_afko');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_vbrk (
      VBELN VARCHAR(10) PRIMARY KEY,
      FKART VARCHAR(4),
      FKDAT DATE,
      KUNAG VARCHAR(10),
      NETWR DECIMAL(15,2),
      MWSBP DECIMAL(15,2),
      WAERK VARCHAR(5),
      VKORG VARCHAR(4)
    )
  `);
  console.log('✔ sap_vbrk');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_vbrp (
      VBELN VARCHAR(10),
      POSNR VARCHAR(6),
      MATNR VARCHAR(18),
      FKIMG DECIMAL(13,3),
      NETWR DECIMAL(15,2),
      WERKS VARCHAR(4),
      PRIMARY KEY (VBELN, POSNR)
    )
  `);
  console.log('✔ sap_vbrp');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_ekko (
      EBELN VARCHAR(10) PRIMARY KEY,
      BSART VARCHAR(4),
      LIFNR VARCHAR(10),
      EKORG VARCHAR(4),
      BEDAT DATE,
      WAERS VARCHAR(5)
    )
  `);
  console.log('✔ sap_ekko');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_ekpo (
      EBELN VARCHAR(10),
      EBELP VARCHAR(5),
      MATNR VARCHAR(18),
      WERKS VARCHAR(4),
      MENGE DECIMAL(13,3),
      NETPR DECIMAL(11,2),
      WAERS VARCHAR(5),
      EINDT DATE,
      PRIMARY KEY (EBELN, EBELP)
    )
  `);
  console.log('✔ sap_ekpo');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_kna1 (
      KUNNR VARCHAR(10) PRIMARY KEY,
      NAME1 VARCHAR(35),
      ORT01 VARCHAR(35),
      REGIO VARCHAR(3),
      LAND1 VARCHAR(3),
      STCD1 VARCHAR(16)
    )
  `);
  console.log('✔ sap_kna1');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_lfa1 (
      LIFNR VARCHAR(10) PRIMARY KEY,
      NAME1 VARCHAR(35),
      ORT01 VARCHAR(35),
      REGIO VARCHAR(3),
      LAND1 VARCHAR(3),
      STCD1 VARCHAR(16)
    )
  `);
  console.log('✔ sap_lfa1');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_aufk (
      AUFNR VARCHAR(12) PRIMARY KEY,
      AUART VARCHAR(4),
      WERKS VARCHAR(4),
      EQUNR VARCHAR(18),
      ERDAT DATE,
      GSTRP DATE,
      GETRP DATE,
      KOSTL VARCHAR(10)
    )
  `);
  console.log('✔ sap_aufk');

  await db.query(`
    CREATE TABLE IF NOT EXISTS sap_qmel (
      QMNUM VARCHAR(12) PRIMARY KEY,
      QMART VARCHAR(2),
      MATNR VARCHAR(18),
      WERKS VARCHAR(4),
      QMTXT VARCHAR(40),
      ERDAT DATE,
      STAT VARCHAR(5)
    )
  `);
  console.log('✔ sap_qmel');

  console.log('\nTodas as tabelas criadas com sucesso!');
  process.exit(0);
}

setup().catch(err => {
  console.error('Erro:', err.message);
  process.exit(1);
});