const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static uploads (foto selfie presensi dan bukti surat izin)
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

// Prefix API
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'PresensiKu API Service',
    version: '1.0.0',
    status: 'Running Active',
    serverTime: new Date().toISOString()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`=========================================`);
  console.log(` PresensiKu API Server is running!`);
  console.log(` URL: http://localhost:${PORT}`);
  console.log(` Network URL: http://0.0.0.0:${PORT}`);
  console.log(`=========================================`);
});
