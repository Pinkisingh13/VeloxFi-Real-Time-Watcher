const express = require("express");
require("dotenv").config();
const cors = require("cors");
const https = require("https");
const { default: axios } = require("axios");

const app = express();

app.use(cors());

const API_KEY = process.env.COIN_CAP_API_KEY;

let cachedData = [];
let requestCount = 0;

const REFRESH_INTERVAL = 900000;
const MAX_REQUESTS_PER_SESSION = 100;

const httpsAgent = new https.Agent({
  keepAlive: true,
  keepAliveMsecs: 10000,
});

const apiClient = axios.create({
  baseURL: 'https://rest.coincap.io/v3',
  httpsAgent: httpsAgent,
  headers: {
    'Authorization': `Bearer ${API_KEY}`,
    'Accept-Encoding': 'gzip,deflate,compress'
  }
});

const fetchData = async () => {
  if (requestCount >= MAX_REQUESTS_PER_SESSION) {
    console.log("🛑 Safety Limit Reached! Stopping background updates.");
    return;
  }

  try {
    const start = Date.now();
    console.log(`🔄 [Req #${requestCount + 1}] Fetching background update...`);

    const response = await apiClient.get("/assets?limit=30");

    cachedData = response.data.data;
    requestCount++;

    const latency = Date.now() - start;
    console.log(`✅ Success! Cache updated in ${latency}ms.`);

    setTimeout(fetchData, REFRESH_INTERVAL);

  } catch (error) {
    console.error("❌ Error fetching data:", error.message);
    setTimeout(fetchData, REFRESH_INTERVAL);
  }
}

fetchData();

app.get('/api/live', (req, res) => {
  if (requestCount >= MAX_REQUESTS_PER_SESSION) {
    return res.json({
      success: true,
      limitReached: true,
      data: cachedData
    });
  }

  res.json({
    success: true,
    limitReached: false,
    data: cachedData
  });
});

const port = process.env.PORT || 8000;
app.listen(port, () =>
  console.log(`🚀 Server listening at http://localhost:${port}`)
);
